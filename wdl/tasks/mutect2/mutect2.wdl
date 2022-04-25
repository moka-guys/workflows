version 1.0

task Mutect2 {
    input {
        String sample_name
        String output_dir
        File? mappings_bam
        File? mappings_bai
        File reference
        File intervals
        String dockerImage
    }

    command <<<
        touch ~{mappings_bai}
        mkdir genome
        tar zxf ~{reference} -C genome  # => genome/<ref>, genome/<ref>.ann, genome/<ref>.bwt, etc.
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa
        mkdir -p ~{output_dir}
        gatk --java-options "-Xmx2g" Mutect2 \
        -R $fa \
        -I ~{mappings_bam} \
        -tumor ~{sample_name} \
        --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
        -L ~{intervals} \
        --interval-padding 50 \
        -O ~{output_dir}/~{sample_name}_mutect2.vcf \
        -bamout ~{output_dir}/~{sample_name}_m2.bam
        true
    >>>

    output {
        File? vcf = "~{output_dir}/~{sample_name}_mutect2.vcf"
        File? bam = "~{output_dir}/~{sample_name}_m2.bam"
        File? bai = "~{output_dir}/~{sample_name}_m2.bai"
        File? stats= "~{output_dir}/~{sample_name}_mutect2.vcf.stats"
    }

    runtime {
        docker: "~{dockerImage}"
        memory: "8 GB"
        cpu: 4
        continueOnReturnCode: true
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
        String dockerImage
    }

    command <<<
        mkdir genome
        tar zxf ~{reference} -C genome 
        fa=`ls genome/*.fa`
        mkdir -p ~{output_dir}
        gatk FilterMutectCalls \
        -R $fa \
        --stats ~{stats} \
        --max-events-in-region 15 \
        -V ~{unfiltered_vcf} \
        -O ~{output_dir}/~{sample_name}_mutect2_filt.vcf
        true
    >>>

    output {
        File? vcf = "~{output_dir}/~{sample_name}_mutect2_filt.vcf"
    }

    runtime {
        docker: "~{dockerImage}"
        memory: "8 GB"
        cpu: 4
        continueOnReturnCode: true
    }
}
