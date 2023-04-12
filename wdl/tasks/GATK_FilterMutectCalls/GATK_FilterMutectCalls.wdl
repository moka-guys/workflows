version 1.1

task GATK_FilterMutectCalls_v1_0{
    input {
        String sample_name
        File reference
        File intervals
        File unfiltered_vcf
        File stats
    }
    meta {
        title: "GATK_FilterMutectCalls_v1_0"
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
        mkdir genome
        tar zxf ~{reference} -C genome
        fa=`ls genome/*.fa`

        gatk --java-options "-Xmx2g" FilterMutectCalls \
        -R $fa \
        --stats ~{stats} \
        --max-events-in-region 15 \
        -V ~{unfiltered_vcf} \
        -O ~{sample_name}.filt.vcf
    >>>
    output {
        File vcf = "~{sample_name}.filt.vcf"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKvgKB00PXfJjvp6434Z9YP8"
        memory: "8 GB"
        cpu: 4
    }
}
