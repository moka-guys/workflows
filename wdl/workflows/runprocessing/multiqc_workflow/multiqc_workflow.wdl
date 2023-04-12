version 1.1

import "../../../tasks/multiqc/multiqc.wdl" as multiqc
# import "../../../tasks/upload_multiqc/upload_multiqc.wdl" as upload_multiqc


workflow multiqc_workflow_v1 {
    meta {
        developer: "Rachel Duffin"
        date: "27/08/2021"
        version: "1.0"
    }
    input {
        String project_name
        String sambamba_coverage_level
        String depends_on
    }
    call multiqc.multiqc_v1_15_0 as multiqc_v1_15_0 {
        input:
            project_for_multiqc = project_name,
            coverage_level = sambamba_coverage_level
    }

#    call upload_multiqc.upload_multiqc_v1_4_0 as upload_multiqc_v1_4_0 {
#        input:
#            multiqc_html = multiqc_v1_15_0.multiqc_report,
#            multiqc_data_input = multiqc_v1_15_0.multiqc
#    }
    output {
        Array[File]+ multiqc_output_files = multiqc_v1_15_0.multiqc
        File multiqc_report = multiqc_v1_15_0.multiqc_report
#        Array[File]+ multiqc_server_index_files = upload_multiqc_v1_4_0.upload_multiqc
    }
}