version 1.0

task GATK_FilterCalls_v1_0{
    input {
        String sample_name
        String output_dir
        File reference
        File intervals
        File? unfiltered_vcf
        File? stats
    }
    meta {
        title: "GATK_FilterCalls_v1_0"
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
        mkdir genome
        tar zxf ~{reference} -C genome
        fa=`ls genome/*.fa`
        gatk --java-options "-Xmx2g" FilterMutectCalls \
        -R $fa \
        --stats ~{stats} \
        --max-events-in-region 15 \
        -V ~{unfiltered_vcf} \
        -O ~{sample_name}_mutect2_filt.vcf
        true
    >>>
    output {
        File? vcf = "~{sample_name}_mutect2_filt.vcf"
    }
    runtime {
        # build from existing dockerfile and switch to using this
        docker: "swglh/gatk:4.2.0.0"
        memory: "8 GB"
        cpu: 4
        continueOnReturnCode: true
    }
}
