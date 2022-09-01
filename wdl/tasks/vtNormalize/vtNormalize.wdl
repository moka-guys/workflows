version 1.0

task vtNormalize_v1_0 {
    input {
        String sample_name
        File? vcf
        File reference
    }
    meta {
        title: "vtNormalize_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_docker_image: "swglh/vtapp:v1",
                        applet_version: "v1.0",
                        release_status: "unreleased"
                    }
    }
    Int disk_gb = ceil(size(vcf, "GiB") + 4 + 10)
    command <<<
        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa
        vt normalize \
        -q \
        -o ~{sample_name}.normalised.vcf \
        -r $genome_file \
        ~{vcf}
        true
    >>>
    output {
        File? normalisedvcf = "~{sample_name}.normalised.vcf"
    }
    runtime {
        # build from existing dockerfile and switch to using this
        docker: "swglh/vtapp:v1"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}