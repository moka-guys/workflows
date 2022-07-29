version 1.0

task variant_filtration {
    input {
        File? vcf
        File reference
        String sample_name
    }
    Int disk_gb = ceil(size(vcf, "GiB")+ size(reference, "GiB") + 10)
    command <<<
        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa
        /gatk/gatk VariantFiltration \
        -R $genome_file \
        -V ~{vcf} \
        -O ~{sample_name}.combined.qcsoftfiltered.vcf \
        --filter-name 'LowDepth' \
        --filter-expression 'DP < 100.0' \
        --filter-name 'LowMapQuality' \
        --filter-expression 'MQ < 25.0'
        true
    >>>
    output {
        File? softfiltered_vcf = "${sample_name}.combined.qcsoftfiltered.vcf"
        Boolean is_done = true
    }
    runtime {
        docker: "swglh/gatk:4.2.0.0"
        memory: "1 GB"
        cpu: 2
        disks: "local-disk ${disk_gb} SSD"
    }
}
