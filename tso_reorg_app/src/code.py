#!/usr/bin/env python3
import json, dxpy, time, re, sys
from datetime import datetime

def msg_handler(string, logfile_path):
    """ Dxpy logging seems to interfere with the usual behaviour of python logging module to create a logfile so
    this function is used as an alternative """
    message = "{} - {}".format(datetime.now(), string)
    print(message)
    with open(logfile_path, "a") as f:
        f.write("{}\n".format(message))


@dxpy.entry_point('main')
def main(reorg_conf___=None, reorg_status___=None):
    """the outputs of native apps are handled within the app therefore are not included in the custom reorg app"""

    logfile_path = datetime.now().strftime('/home/dnanexus/custom_reorg_%H%M_%d%m%Y.log')

    # download and parse `reorg_conf___`
    conf_file = list(dxpy.find_data_objects(
        classname="file",
        name="conf.json",
        name_mode="exact",
        project="project-G76q9bQ0PXfP7q972fVf2X19",
        folder="/"
    ))
    # download conf.json file
    # conf.json format: <key_file_type>: [<output_dir>, <search_string>, <search_mode>]
    # search_modes:
        # "end": file name ends with <search_string>
        # "in": file name contains <search_string>
        # "regex": search file name by submitting regular expression pattern as <search_string>
    dxpy.download_dxfile(conf_file[0]['id'], "conf.json")
    with open('conf.json') as f:
        file_types = json.load(f)

    # find the output stage of the current analysis
    analysis_id = dxpy.describe(dxpy.JOB_ID)["analysis"]
    # describe the analysis in a loop until dependsOn is empty
    # or contains only this reorg job's ID
    while True:
        analysis_desc = dxpy.describe(analysis_id)
        depends_on = analysis_desc.get("dependsOn")
        msg_handler("DEPENDS ON: {}".format(depends_on), logfile_path)
        if not depends_on or depends_on == [dxpy.JOB_ID]:
            break
        else:
            time.sleep(3)

    stages = analysis_desc["stages"]


    # retrieve the dictionary containing outputs, where key is the name of output and value is the link to the file.
    output_map = [x['execution']['output'] for x in stages if x['id'] == 'stage-outputs'][0]

    # collect output file IDs - finds all unique file IDS in output map
    out = list(set(re.findall('file-[a-zA-Z0-9]{24}', str(output_map))))

    filenames = [dxpy.DXFile(x).describe(fields={'name'}) for x in out]
    msg_handler("COLLECTED FILES: {}".format(filenames), logfile_path)

    # Loops through all files and groups files with the same suffix or containing the same string
    # Removes them from the list of filenames for use by the next step as have already been successfully matched
    # Search mode given as 3 element in conf.json
    files = {}

    for f_type in file_types:
        msg_handler('Searching for files of type: {}'.format(f_type), logfile_path)
        indices = []
        ids = []
        try:
            if file_types[f_type][2] == 'end':
                # collect ids of files that match so they can be removed from the list of filenames for searching
                for idx, x in enumerate(filenames):
                    if x["name"].endswith(file_types[f_type][1]):
                        ids.append(x['id'])
                        indices.append(idx)
                        msg_handler("MATCH for type {}: {}".format(f_type, x), logfile_path)
            elif file_types[f_type][2] == 'in':
                # collect ids of files that match so they can be removed from the list of filenames for searching
                for idx, x in enumerate(filenames):
                    if file_types[f_type][1] in x["name"]:
                        ids.append(x['id'])
                        indices.append(idx)
                        msg_handler("MATCH for type {}: {}".format(f_type, x), logfile_path)
            elif file_types[f_type][2] == 'regex':
                for idx, x in enumerate(filenames):
                    try:
                        re_result = re.findall(file_types[f_type][1], x["name"])
                        if x["name"] == re_result[0]:
                            ids.append(x['id'])
                            indices.append(idx)
                            msg_handler("MATCH for type {}: {}".format(f_type, x), logfile_path)
                    # there is no regex match
                    except:
                        pass

            # add file ids to files dictionary and remove filename from filenames list using indices list
            files[f_type] = ids
            filenames = [v for i, v in enumerate(filenames) if i not in indices]

        except Exception as err:
            msg_handler("{}, {}".format(f_type, err), logfile_path)
            pass

    if filenames:
        msg_handler("NO REGEX MATCH FOR: {}".format(filenames), logfile_path)
    else:
        msg_handler("ALL FILES SUCCESSFULLY MATCHED TO DESTINATION FOLDERS: {}".format(files), logfile_path)

    # create a dictionary of output folders
    file_folders={}
    for file in files:
        file_folders[file]=file_types[file][0]

    # get the container instance
    dx_container = dxpy.DXProject(dxpy.PROJECT_CONTEXT_ID)

    # create folders
    for folder in file_folders:
        dx_container.new_folder(file_folders[folder], parents=True)

    # move files into folders
    for file_list in files:
        msg_handler("moving {}, {} to {}".format(file_list, file, file_folders[file_list]), logfile_path)
        try:
            for file in files[file_list]:
                dx_container.move(
                    destination=file_folders[file_list],
                    objects=[file]
                )
        except Exception as err:
            msg_handler("move error: {}, {}, {}".format(err, file_list, file), logfile_path)
            pass

    # create array to populate 'outputs' in OutputSpec in dxapp.json
    out_array=[]
    for item in out:
        file_dict = {'$dnanexus_link': item}
        out_array.append(file_dict)

    # Specify the outputs
    output= {"logfile": dxpy.dxlink(dxpy.upload_local_file(logfile_path)), "outputs": out_array}

    return output

dxpy.run()