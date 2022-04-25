version 1.0

task vtNormalize {
    input {
        File? vcf
        String output_dir
        File reference
        String dockerImage 
        String sampleName
    }
    Int disk_gb = ceil(size(vcf, "GiB")+ 4 + 10)
    command <<<
        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa
        mkdir -p ~{output_dir}/genotype && \
        vt normalize \
        -q \
        -o ~{output_dir}/genotype/$(basename ~{vcf} .vcf).normalised.vcf \
        -r $genome_file \
        ~{vcf} \
    >>>

    output {
        File? normalisedvcf = "${output_dir}/genotype/"+"$(basename ~{vcf} .vcf).normalised.vcf"
    }

    runtime {
        docker: "${dockerImage}"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}


task vtDecompose {
    input {
        File? vcf
        String output_dir
        String dockerImage 
        String sampleName
    }

    Int disk_gb = ceil(size(vcf, "GiB") + 10)
    
    command <<<
        mkdir -p ~{output_dir}/genotype && \
        vt decompose \
        ~{vcf} \
        -s \
        -o ~{output_dir}/genotype/$(basename ~{vcf} .vcf).decomp.vcf
        true
    >>>

    output {
        File? decomposedvcf = "${output_dir}/genotype/"+"$(basename ~{vcf} .vcf).decomp.vcf"
    }

    runtime { 
        docker: "${dockerImage}"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }    
}
