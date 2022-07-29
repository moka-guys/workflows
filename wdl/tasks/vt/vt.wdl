version 1.0

task vtNormalize {
    input {
        File? vcf
        File reference
    }
    Int disk_gb = ceil(size(vcf, "GiB")+ 4 + 10)
    command <<<
        sample_string="basename
        testbasename="basename $vcf"

        $testbasename

        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa
        command = vt normalize -q -o $(basename ~{vcf} .vcf).normalised.vcf -r $genome_file ~{vcf}
        vt normalize \
        -q \
        -o $(basename ~{vcf} .vcf).normalised.vcf \
        -r $genome_file \
        ~{vcf}
        true
    >>>

    output {
        File? normalisedvcf = "$(basename ~{vcf} .vcf).normalised.vcf"
    }

    runtime {
        docker: "swglh/vtapp:v1"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}


task vtDecompose {
    input {
        File? vcf
    }

    Int disk_gb = ceil(size(vcf, "GiB") + 10)
    
    command <<<
        vt decompose \
        ~{vcf} \
        -s \
        -o $(basename ~{vcf} .vcf).decomp.vcf
        true
    >>>

    output {
        File? decomposedvcf = "$(basename ~{vcf} .vcf).decomp.vcf"
    }

    runtime { 
        docker: "swglh/vtapp:v1"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }    
}
