version 1.0

task CombineVcfs {
    input {
        String sample_name
        String output_dir
        File? vardict_vcf
        File? mutect_vcf
        File reference
        String javaXmx = "4G"
        Int threads = 2
        String dockerImage
    }
    Int disk_gb = ceil((2*size(mutect_vcf, "GiB")) + 4 + 10)
    command <<<
        sed -i 's/##fileformat=VCFv4.3/##fileformat=VCFv4.2/g' ~{vardict_vcf}
        mkdir genome
        tar zxvf ~{reference} -C genome
        fa=`ls genome/*.fa`     # Locate a file called <ref>.fa
        mkdir -p ~{output_dir}/genotype && \
        java -Xmx~{javaXmx} -XX:ParallelGCThreads=~{threads} \
        -jar /usr/GenomeAnalysisTK.jar -T CombineVariants \
        --variant:vardict ~{vardict_vcf} \
        --variant:mutect2 ~{mutect_vcf} \
        -genotypeMergeOptions PRIORITIZE \
        -priority mutect2,vardict \
        -R $fa \
        -o ~{output_dir}/genotype/~{sample_name}.combined.vcf
        true
    >>>
    output {
        File? combined_vcf = "${output_dir}/genotype/${sample_name}.combined.vcf"
    }
    runtime {
        docker: "${dockerImage}"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}
