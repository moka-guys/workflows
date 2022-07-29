version 1.0

task cnvkit_v0_9_8 {
    input {
        File? mappings_bam
        File? mappings_bai
        File reference_fasta
        String? more_options
    }

    command <<<
    set -x
    >>>

    output {
        Array[File?] cnvkit_output = []
    }

    runtime {
        docker: "etal/cnvkit:0.9.8"
        dx_instance_type: "mem2_ssd1_v2_x16"
    }
}