version 1.0

task Fastp {
    input {
        String sample_name
        String output_dir
        Array[File] fastq_files
        Int? min_disk_gb = 10
    }
    meta {
        title: "fastpv1.0"
        summary: "Uses fastp v0.21.0. This applet uses the swglh fastp docker image (swglh/fastp-tabix:0.21.0), which contains fastp v0.21.0 (https://github.com/OpenGene/fastp/commit/0da2f13ae21f440b6db8de83312db8b6e99d932c)"
        description: "TEST"
        tags: ["TSO500", "WDL"]
        properties: {
            app_github_release: "unreleased",
            runtime_docker_image: "swglh/fastp-tabix:0.21.0",
            fastp_version: "v0.21.0"
            }
        }

    Int disk_gb = select_first([(ceil(2*size(fastq_files, "GiB")) + 20), min_disk_gb])
    command <<<
        set -x
        mkdir -p ~{output_dir}/Metrics &&
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
        docker: "swglh/fastp-tabix:0.21.0"
        memory: "4 GB"
        cpu: 2
        disks: "local-disk ${disk_gb} SSD"
    }
}