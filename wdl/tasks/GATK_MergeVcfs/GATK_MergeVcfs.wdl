version 1.1

task GATK_MergeVcfs_v1_0 {
    input {
        String sample_name
        File vardict_vcf
        File mutect_vcf
        File reference
    }
    meta {
        title: "GATK_CombineVCFs_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_docker_image: "broadinstitute/gatk3:3.8-1",
                        applet_version: "v1.0",
                        release_status: "unreleased"
                    }
    }
    command <<<
        set -exo pipefail
        sed -i 's/##fileformat=VCFv4.3/##fileformat=VCFv4.2/g' ~{vardict_vcf}
        mkdir genome
        tar zxvf ~{reference} -C genome
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa
        dict=`ls genome/*.dict`     # Locate a file called <ref>.dict

        gatk MergeVcfs \
        -I ~{vardict_vcf} \
        -I ~{mutect_vcf} \
        -R $fa \
        -D $dict \
        -O ~{sample_name}.combined.vcf
    >>>
    output {
        File combined_vcf = "~{sample_name}.combined.vcf"
        File combined_vcf_index = "~{sample_name}.combined.vcf.idx"
        String filename_stem = "~{sample_name}.combined"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKvgKB00PXfJjvp6434Z9YP8"
        memory: "16 GB"
        cpu: 8
        disks: "local-disk ~{(ceil(2*size(mutect_vcf, "GiB")) + 14)} SSD"
        dx_instance_type: "mem1_ssd1_v2_x4"
    }
}
