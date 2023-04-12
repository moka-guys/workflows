version 1.1

task Mutect2_v1_0 {
    input {
        String sample_name
        File mappings_bam
        File mappings_bai
        File reference
        File intervals
    }
    meta {
        title: "Mutect2_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
            runtime_docker_image: "swglh/gatk:4.2.0.0",
            applet_version: "v1.0",
            release_status: "unreleased"
            }
        }
    command <<<
        set -exo pipefail
        touch ~{mappings_bai}
        mkdir genome
        tar zxf ~{reference} -C genome  # => genome/<ref>, genome/<ref>.ann, genome/<ref>.bwt, etc.
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa

        gatk --java-options "-Xmx2g" Mutect2 \
        -R $fa \
        -I ~{mappings_bam} \
        -tumor ~{sample_name} \
        --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
        -L ~{intervals} \
        --interval-padding 50 \
        -O ~{sample_name}.mutect2.vcf \
        -bamout ~{sample_name}.mutect2.bam
    >>>
    output {
        File vcf = "~{sample_name}.mutect2.vcf"
        File bam = "~{sample_name}.mutect2.bam"
        File bai = "~{sample_name}.mutect2.bai"
        File stats= "~{sample_name}.mutect2.vcf.stats"
        String filename_stem = "${sample_name}.mutect2"

    }
    runtime {
        # Need to make my own dockerfile for this
        docker: "dx://file-GKvgKB00PXfJjvp6434Z9YP8"
        dx_instance_type: "mem1_ssd1_v2_x4"
        memory: "8 GB"
        cpu: 4
    }
}