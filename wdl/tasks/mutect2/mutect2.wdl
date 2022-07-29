version 1.0

task Mutect2 {
    input {
        String sample_name
        String output_dir
        File? mappings_bam
        File? mappings_bai
        File reference
        File intervals
    }

    command <<<
        set -x
        touch ~{mappings_bai}
        mkdir genome
        tar zxf ~{reference} -C genome  # => genome/<ref>, genome/<ref>.ann, genome/<ref>.bwt, etc.
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa
        gatk --java-options "-Xmx2g" Mutect2 \
        -R $fa \
        -I ~{mappings_bam} \
        -tumor ~{sample_name} \
        --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
        -L ~{intervals} \
        --interval-padding 50 \
        -O ~{sample_name}_mutect2.vcf \
        -bamout ~{sample_name}_m2.bam
        true
    >>>

    output {
        File? vcf = "~{sample_name}_mutect2.vcf"
        File? bam = "~{sample_name}_m2.bam"
        File? bai = "~{sample_name}_m2.bai"
        File? stats= "~{sample_name}_mutect2.vcf.stats"
    }

    runtime {
        docker: "swglh/gatk:4.2.0.0"
        memory: "8 GB"
        cpu: 4
        continueOnReturnCode: true
        dx_access: object {
                       network: ["*"],
                       project: "CONTRIBUTE",
                       allProjects: "VIEW"
                   }
    }
}

task FilterCalls{
    input {
        String sample_name
        String output_dir
        File reference
        File intervals
        File? unfiltered_vcf
        File? stats
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
        docker: "swglh/gatk:4.2.0.0"
        memory: "8 GB"
        cpu: 4
        continueOnReturnCode: true
    }
}
