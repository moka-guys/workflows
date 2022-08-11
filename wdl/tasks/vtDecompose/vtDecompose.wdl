version 1.0

task vtDecompose_v1_0 {
    input {
        String sample_name
        File? vcf
    }
    meta {
        title: "vtDecompose_v1_0"
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
        vt decompose \
        ~{vcf} \
        -s \
        -o ~{sample_name}.decomp.vcf
        true
    >>>
    output {
        File? decomposedvcf = "~{sample_name}.decomp.vcf"
        Boolean is_done = true
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