version 1.1

task UMICollapse_v1_0 {
    input {
        File precollapsed_bam
        File precollapsed_bam_index
        String sample_name
    }
    meta {
        title: "UMICollapse_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
            runtime_docker_image: "mattwherlock/umicollapse-samtools-reorg:latest",
            applet_version: "v1_0",
            release_status: "unreleased"
            }
        }
    command <<<
        set -exo pipefail
        /bin/bash /umicollapse bam \
        --two-pass \
        -i ~{precollapsed_bam} \
        -o ~{sample_name}.collapsed.bam &&
        samtools index ~{sample_name}.collapsed.bam
    >>>
    output {
        File final_bam = "${sample_name}.collapsed.bam"
        File final_bam_index = "${sample_name}.collapsed.bam.bai"
        String filename_stem = "${sample_name}.collapsed"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKvF1p80PXfF03ZYBPb6xjj2"
        memory: "32 GB"
        cpu: 4
        dx_instance_type: "mem3_ssd1_v2_x4"
        disks: "local-disk ~{ceil((2*size(precollapsed_bam, "GiB")) + 10)} SSD"
    }
}