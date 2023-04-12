version 1.1

task setoff_tso_processing_v1 {
    meta {
        developer: "Rachel Duffin"
        date: "27/08/2021"
        version: "1.0"
    }
    input{
        String project_name
        String sample_name
        String fastq_file_1
        String fastq_file_2
        String bedfile
        String coverage_bedfile
        String sambamba_coverage_level
    }

    command <<<
        set -exo pipefail
        API_KEY=tsN9cklrUfUlB1CuHqVOw7ZAqnuDzYE4

        # Override app variables so the dx run commands can be run in the project
        unset DX_WORKSPACE_ID
        dx cd "$DX_PROJECT_CONTEXT_ID"
        source ~/.dnanexus_config/unsetenv
        dx clearenv
        dx login --noprojects --token "$API_KEY"
        dx select ~{project_name}

        if [[ "~{sample_name}" =~ .*"HD200".* ]];
        then
            HD200=true
        else
            HD200=false
        fi

        # Get file IDs
        fastq_file1_proj="$(dx describe ~{fastq_file_1} --json | jq -r .project)"
        fastq_file1_id="$(dx describe ~{fastq_file_1} --json | jq -r .id)"
        fastq_file2_proj="$(dx describe ~{fastq_file_2} --json | jq -r .project)"
        fastq_file2_id="$(dx describe ~{fastq_file_2} --json | jq -r .id)"
        bedfile_proj="$(dx describe ~{bedfile} --json | jq -r .project)"
        bedfile_id="$(dx describe ~{bedfile}  --json | jq -r .id)"
        coverage_bedfile_proj="$(dx describe ~{coverage_bedfile} --json | jq -r .project)"
        coverage_bedfile_id="$(dx describe ~{coverage_bedfile} --json | jq -r .id)"

        # Inputs are provided in json format to easily output to file
        # and else the command recognises dnanexus links 'dx://' incorrectly as a dx command

        inputs_json=$( jq -n \
            --arg HD200 $HD200 \
            --arg fastq_file1_proj "$fastq_file1_proj" \
            --arg fastq_file1_id "$fastq_file1_id" \
            --arg fastq_file2_proj "$fastq_file2_proj" \
            --arg fastq_file2_id "$fastq_file2_id" \
            --arg fastq_file_2 "$fastq_file_2" \
            --arg bwa_index_proj "$bwa_index_proj" \
            --arg bwa_index_id "$bwa_index_id" \
            --arg bedfile_proj "$bedfile_proj" \
            --arg bedfile_id "$bedfile_id" \
            --arg coverage_bedfile_proj "$coverage_bedfile_proj" \
            --arg coverage_bedfile_id "$coverage_bedfile_id" \
        '{
            "stage-common.sample_name": "~{sample_name}",
            "stage-common.fastq_file_1": {
                "$dnanexus_link": {
                    "project": $fastq_file1_proj,
                    "id": $fastq_file1_id
                }
            },
            "stage-common.fastq_file_2": {
                "$dnanexus_link": {
                    "project": $fastq_file2_proj,
                    "id": $fastq_file2_id
                }
            },
            "stage-common.remove_chr": false,
            "stage-common.MSI_microsatellite_only": false,
            "stage-common.MSI_coverage_threshold": 20,
            "stage-common.sambamba_coverage_level": "~{sambamba_coverage_level}",
            "stage-common.Capture_panel": "Hybridisation",
            "stage-common.MSI_model": "hg19_GRCh37",
            "stage-common.add_read_group": true,
            "stage-common.read_group_platform": "ILLUMINA",
            "stage-common.read_group_platform_unit": "None",
            "stage-common.read_group_library": "1",
            "stage-common.all_alignments": false,
            "stage-common.mark_as_secondary": true,
            "stage-common.HD200": $HD200 | test("true"),
            "stage-common.advanced_options": "",
            "stage-common.reference_fasta_index": {
                "$dnanexus_link": {
                    "project": "project-G76q9bQ0PXfP7q972fVf2X19",
                    "id": "file-GFPGv2j0XbkxXyZZ4vVBv6v3"
                }
            },
            "stage-common.reference_bwa_index": {
                "$dnanexus_link": {
                    "project": "project-ByfFPz00jy1fk6PjpZ95F27J",
                    "id": "file-B6qq53v2J35Qyg04XxG0000V"
                }
            },
            "stage-common.bedfile": {
                "$dnanexus_link": {
                    "project": $bedfile_proj,
                    "id": $bedfile_id
                }
            },
            "stage-common.coverage_bedfile": {
                "$dnanexus_link": {
                    "project": $coverage_bedfile_proj,
                    "id": $coverage_bedfile_id
                }
            },
            "stage-common.sompy_truthVCF": {
                "$dnanexus_link": {
                    "project": "project-ByfFPz00jy1fk6PjpZ95F27J",
                    "id": "file-G7g9Pfj0jy1f87k1J1qqX83X"
                }
            }
        }'
        )
        echo $inputs_json > ~{sample_name}_inputs.json

        workflow_cmd="dx run -y \
                        project-G76q9bQ0PXfP7q972fVf2X19:/workflows/TSO500_workflow/TSO500_workflow_v1/TSO500_workflow_v1 \
                        -f ~{sample_name}_inputs.json \
                        --stage-relative-output-folder fastp_v1_0 preprocessing \
                        --stage-relative-output-folder UMICollapse_v1_0 postprocessing \
                        --stage-relative-output-folder VarDict_v1_0 variant_calling \
                        --stage-relative-output-folder Mutect2_v1_0 variant_calling \
                        --stage-relative-output-folder GATK_FilterMutectCalls_v1_0 variant_calling \
                        --stage-relative-output-folder GATK_MergeVcfs_v1_0 variant_calling \
                        --stage-relative-output-folder vtNormalize_Decompose_v1_0 variant_calling \
                        --stage-relative-output-folder MsiSensor2_v1_0 variant_calling \
                        --project=~{project_name} \
                        --name=TSO_workflow_~{sample_name} \
                        --detach \
                        --brief \
                        --auth-token $API_KEY
                        "

        echo "$workflow_cmd" > ~{sample_name}_dx_run_cmd.txt

        analysis_id=$($workflow_cmd)  # Run workflow
        echo "$analysis_id" > ~{sample_name}_analysis_id.txt
    >>>

    output{
        File analysis_id = "~{sample_name}_analysis_id.txt"
        File dx_run_cmd = "~{sample_name}_dx_run_cmd.txt"
        File inputs_json = "~{sample_name}_inputs.json"
    }
}