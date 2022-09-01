version 1.0

task fastp_v1_0 {
    input {
        String sample_name
        String output_dir
        Array[File] fastq_files
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
    Int disk_gb = ceil((2*size(fastq_files, "GiB")) + 10)
    command <<<
        set -x
        /fastp \
        -i ~{fastq_files[0]} \
        -I ~{fastq_files[1]} \
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
        true
    >>>
    output {
        File? fastp_report = "${sample_name}.metrics.fastp.html"
        File? fastp_json = "${sample_name}.metrics.fastp.json"
        File? trimmed_fastq_R1 = "${sample_name}.trimmed.R1.fastq.gz"
        File? trimmed_fastq_R2 = "${sample_name}.trimmed.R2.fastq.gz"
    }
    runtime {
        # build from existing dockerfile and switch to using this
        docker: "swglh/fastp-tabix:0.21.0"
        memory: "4 GB"
        cpu: 2
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}