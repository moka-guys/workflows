version 1.0

task UMICollapse_v1_0 {
    input {
        File? precollapsed_bam
        File? precollapsed_bam_index
        String sample_name
        Int? min_disk_gb = 10
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
    Int disk_gb = select_first([(ceil(2*size(precollapsed_bam, "GiB")) + 20), min_disk_gb])
    command <<<
        set -x
        /umicollapse bam \
        --two-pass \
        -i ~{precollapsed_bam} \
        -o ~{sample_name}.final.bam &&
        samtools index ~{sample_name}.final.bam
        true
    >>>
    output {
        File? final_bam = "${sample_name}.final.bam"
        File? final_bam_index = "${sample_name}.final.bam.bai"
    }
    runtime {
        # build from existing dockerfile and switch to using this
        docker: "mattwherlock/umicollapse-samtools-reorg:latest"
        memory: "32 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}