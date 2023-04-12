version 1.1
# Accompanying extras.json file provides the required permissions to all
# workflow tasks to download files from other projects

import "../../structs/structs.wdl"
import "../../tasks/setoff_tso_processing/setoff_tso_processing.wdl" as setoff_tso
import "../../tasks/setoff_multiqc_processing/setoff_multiqc_processing.wdl" as setoff_multiqc

workflow setoff_runprocessing_workflow_v1 {
        meta {
        developer: "Rachel Duffin"
        date: "27/08/2021"
        version: "1.0"
    }
    input{
        String project_name
        Array[Sample] samples
        String bedfile
        String coverage_bedfile
        String sambamba_coverage_level
        String runtype
    }
    # Set up in this way to easily add further workflow types as another call block with the required inputs
    # Any workflow-specific logic then goes in the respective setoff app
    scatter (sample in samples) {
        if (runtype == 'TSO500') {
            call setoff_tso.setoff_tso_processing_v1 as setoff_workflow_processing {
                input:
                    project_name = project_name,
                    sample_name = sample.sample_name,
                    fastq_file_1 = sample.fastq_file_1,
                    fastq_file_2 = sample.fastq_file_2,
                    bedfile = bedfile,
                    coverage_bedfile = coverage_bedfile,
                    sambamba_coverage_level = sambamba_coverage_level
            }
        }
    }
    call setoff_multiqc.setoff_multiqc_processing_v1 as setoff_multiqc_processing {
        input:
            project_name = project_name,
            sambamba_coverage_level = sambamba_coverage_level,
            depends_on = setoff_workflow_processing.analysis_id
    }

    output {
        Array[File?] workflow_analysis_ids = setoff_workflow_processing.analysis_id
        Array[File?] workflow_dxrun_cmds = setoff_workflow_processing.dx_run_cmd
        Array[File?] inputs_json = setoff_workflow_processing.inputs_json
        File? multiqc_analysis_id = setoff_multiqc_processing.analysis_id
        File? multiqc_dxrun_cmds = setoff_multiqc_processing.dx_run_cmd
    }
}
