version 1.1

task vtNormalize_Decompose_v1_0 {
    input {
        String sample_name
        File vcf
        File reference
    }
    meta {
        title: "vtNormalize_Decompose_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_docker_image: "swglh/vtapp:v1",
                        applet_version: "v1.0",
                        release_status: "unreleased"
                    }
    }
    Int disk_gb = ceil(size(vcf, "GiB") + 10)
    command <<<
        set -exo pipefail
        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa

        vt normalize \
        -q \
        -o ~{sample_name}.normalized.vcf \
        -r $genome_file \
        ~{vcf}

        vt decompose \
        ~{vcf} \
        -s \
        -o ~{sample_name}.normalized.decomp.vcf

        # Index final vcf file with tabix so it can be viewed in the IGV webapp
        bgzip -c ~{sample_name}.normalized.decomp.vcf > ~{sample_name}.normalized.decomp.vcf.gz
        tabix -p vcf ~{sample_name}.normalized.decomp.vcf.gz
    >>>
    output {
        File normalisedvcf = "~{sample_name}.normalized.vcf"
        File decomposedvcf = "~{sample_name}.normalized.decomp.vcf"
        File compressed_vcf = "~{sample_name}.normalized.decomp.vcf.gz"
        File compressed_vcf_index = "~{sample_name}.normalized.decomp.vcf.gz.tbi"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKvqf780PXfPK74j10Q64zz2"
        memory: "8 GB"
        cpu: 4
        dx_instance_type: "mem1_ssd1_v2_x4"
        disks: "local-disk ${disk_gb} SSD"
    }
}