version 1.1

task fastp_v1_0 {
    input {
        String sample_name
        File fastq_file_1
        File fastq_file_2
    }
    meta {
        title: "fastp_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
            runtime_docker_image: "swglh/fastp-tabix:0.21.0",
            applet_version: "v1_0",
            release_status: "unreleased"
            }
    }
    command <<<
        set -exo pipefail
        /fastp \
        -i ~{fastq_file_1} \
        -I ~{fastq_file_2} \
        -o ~{sample_name}.trimmed.R1.fastq.gz \
        -O ~{sample_name}.trimmed.R2.fastq.gz \
        --adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
        --adapter_sequence_r2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
        --json ~{sample_name}.metrics.fastp.json \
        --html ~{sample_name}.metrics.fastp.html \
        --report_title "~{sample_name} trimming report" \
        --umi \
        --umi_loc per_read \
        --umi_len 7 \
        --umi_skip 2
    >>>
    output {
        File fastp_report = "${sample_name}.metrics.fastp.html"
        File fastp_json = "${sample_name}.metrics.fastp.json"
        File trimmed_fastq_R1 = "${sample_name}.trimmed.R1.fastq.gz"
        File trimmed_fastq_R2 = "${sample_name}.trimmed.R2.fastq.gz"
        String filename_stem = "${sample_name}.trimmed"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKybB700PXfPfv3QGf3qQV34"
        memory: "4 GB"
        cpu: 2
        disks: "local-disk ~{ceil(2*size([fastq_file_1, fastq_file_2], "GiB")) + 10} SSD"
        dx_instance_type: "mem1_ssd1_v2_x4"
    }
}