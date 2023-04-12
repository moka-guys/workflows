# Get file IDs
fastq_file1_proj="$(dx describe ~{fastq_file_1} --json | jq -r .project)"
fastq_file1_id="$(dx describe ~{fastq_file_1} --json | jq -r .id)"
fastq_file2_proj="$(dx describe ~{fastq_file_2} --json | jq -r .project)"
fastq_file2_id="$(dx describe ~{fastq_file_2} --json | jq -r .id)"
bedfile_proj="$(dx describe ~{bedfile} --json | jq -r .project)"
bedfile_id="$(dx describe ~{bedfile}  --json | jq -r .id)"
coverage_bedfile_proj="$(dx describe ~{coverage_bedfile} --json | jq -r .project)"
coverage_bedfile_id="$(dx describe ~{coverage_bedfile} --json | jq -r .id)"


# Determine whether the sample is a control (if it is, workflow runs sompy)
if [[ "~{sample_name}" =~ .*"HD200".* ]];
then
    HD200=true
else
    HD200=false
fi

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
            "stage-common.project": "~{project_name}",
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

#        --stage-output-folder fastqc_v1_4_0 QC \

workflow_cmd="dx run project-G76q9bQ0PXfP7q972fVf2X19:/TSO500_workflow/TSO500_workflow -y \
        -f ~{sample_name}_inputs.json \
        --dest=~{project_name}:/ \
        --stage-relative-output-folder fastp_v1_0 preprocessing \
        --stage-output-folder bwa_mem_v1_3 alignment \
        --stage-relative-output-folder UMICollapse_v1_0 postprocessing \
        --stage-relative-output-folder VarDict_v1_0 variant_calling \
        --stage-relative-output-folder Mutect2_v1_0 variant_calling \
        --stage-relative-output-folder GATK_FilterMutectCalls_v1_0 variant_calling \
        --stage-relative-output-folder GATK_MergeVcfs_v1_0 variant_calling \
        --stage-relative-output-folder vtNormalize_Decompose_v1_0 variant_calling \
        --stage-relative-output-folder MsiSensor2_v1_0 variant_calling \
        --stage-output-folder verify_bam_id_v1_1_1 QC \
        --stage-output-folder chanjo_sambamba_coverage_v1_13 QC \
        --stage-output-folder moka_picard_v1_2 QC \
        --stage-output-folder 'if (HD200)' QC \
        --detach \
        --brief \
        --auth-token $API_KEY
        "