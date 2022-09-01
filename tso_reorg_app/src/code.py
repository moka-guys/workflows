#!/usr/bin/env python
import json
import dxpy
import time
import re

@dxpy.entry_point('main')
def main(reorg_conf___=None, reorg_status___=None):
    """the outputs of native apps are handled within the app therefore are not included in the custom reorg app"""

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
    print("FILE TYPES: ")
    print(file_types)

    # find the output stage of the current analysis
    analysis_id = dxpy.describe(dxpy.JOB_ID)["analysis"]
    # describe the analysis in a loop until dependsOn is empty
    # or contains only this reorg job's ID
    while True:
        analysis_desc = dxpy.describe(analysis_id)
        print("ANALYSIS ID: ")
        print(analysis_desc)
        depends_on = analysis_desc.get("dependsOn")
        print("DEPENDS ON: ")
        print(depends_on)
        if not depends_on or depends_on == [dxpy.JOB_ID]:
            break
        else:
            time.sleep(3)

    stages = analysis_desc["stages"]
    print("STAGES: ")
    print(stages)


    # retrieve the dictionary containing outputs, where key is the name of output and value is the link to the file.
    output_map = [x['execution']['output'] for x in stages if x['id'] == 'stage-outputs'][0]
    print("OUTPUT MAP: ")
    print(output_map)
    # collect output file IDs - finds all unique file IDS in output map
    out = list(set(re.findall('file-[a-zA-Z0-9]{24}', str(output_map))))
    print("OUT: ")
    print(out)
    filenames = [dxpy.DXFile(x).describe(fields={'name'}) for x in out]
    print("FILENAMES: ")
    print(filenames)

    # Loops through all files and groups files with the same suffix or containing the same string
    # Search mode given as 3 element in conf.json
    # regex in conf.json may need updating/improving
    files = {}
    for file in file_types:
        try:
            if file_types[file][2] == 'end':
                files[file] = [x['id'] for x in filenames if x["name"].endswith(file_types[file][1])]
            elif file_types[file][2] == 'in':
                files[file] = [x['id'] for x in filenames if file_types[file][1] in x["name"]]
            elif file_types[file][2] == 'regex':
                file_ids = []
                for x in filenames:
                    try:
                        re_result = re.findall(file_types[file][1], x["name"])
                        if x["name"] == re_result[0]:
                            file_ids.append(x['id'])
                    except IndexError as err:
                        print("regex error:", err, file, x)
                        pass
                files[file] = file_ids if len(file_ids) != 0 else print("regex error:", file, x)
        except Exception as err:
            print("file error:", err, file)
            pass
    print("FILES: ")
    print(files)
    # create a dictionary of output folders
    file_folders={}
    for file in files:
        file_folders[file]=file_types[file][0]
    print("FILE FOLDERS: ")
    print(file_folders)

    # get the container instance
    dx_container = dxpy.DXProject(dxpy.PROJECT_CONTEXT_ID)
    print("dx_container: ")
    print(dx_container)

    # create folders
    for folder in file_folders:
        dx_container.new_folder(file_folders[folder], parents=True)

    # move files into folders
    for file_list in files:
        try:
            for file in files[file_list]:
                print("moving", file_list, file, "to", file_folders[file_list])
                dx_container.move(
                    destination=file_folders[file_list],
                    objects=[file]
                )
        except Exception as err:
            print("move error:", err, file_list, file)
            pass
    print("OUTPUTS: ")
    print(dict(outputs=output_map))

    # create array to populate 'outputs' in OutputSpec in dxapp.json
    out_array=[]
    for item in out:
        file_dict = {'$dnanexus_link': item}
        out_array.append(file_dict)

    print(dict(outputs=out_array))

    return dict(outputs=out_array)