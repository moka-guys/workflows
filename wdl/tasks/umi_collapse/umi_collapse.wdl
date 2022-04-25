version 1.0

task UMICollapse {
    input {
        File? precollapsed_bam
        File? precollapsed_bam_index
        String sample_name
        Int? min_disk_gb = 10
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
        docker: "mattwherlock/umicollapse-samtools-reorg:latest"
        memory: "32 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
    }
}