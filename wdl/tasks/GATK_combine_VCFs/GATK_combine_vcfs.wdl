version 1.0

task GATK_CombineVCFs_v1_0 {
    input {
        String sample_name
        File? vardict_vcf
        File? mutect_vcf
        File reference
        String javaXmx = "4G"
        Int threads = 2
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
    Int disk_gb = ceil((2*size(mutect_vcf, "GiB")) + 4 + 10)
    command <<<
        set -x
        sed -i 's/##fileformat=VCFv4.3/##fileformat=VCFv4.2/g' ~{vardict_vcf}
        mkdir genome
        tar zxvf ~{reference} -C genome
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa
        java -Xmx~{javaXmx} -XX:ParallelGCThreads=~{threads} \
        -jar /usr/GenomeAnalysisTK.jar -T CombineVariants \
        --variant:vardict ~{vardict_vcf} \
        --variant:mutect2 ~{mutect_vcf} \
        -genotypeMergeOptions PRIORITIZE \
        -priority mutect2,vardict \
        -R $fa \
        -o ~{sample_name}.combined.vcf
        true
    >>>
    output {
        File? combined_vcf = "${sample_name}.combined.vcf"
        String filename_stem = "${sample_name}.combined"
        Boolean is_done = true
    }
    runtime {
        # Need to make my own dockerfile for this
        docker: "broadinstitute/gatk3:3.8-1"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}
