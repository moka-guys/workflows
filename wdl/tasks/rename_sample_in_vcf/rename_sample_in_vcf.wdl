version 1.0

task rename_sample_in_vcf {
    input {
        String sample_name
        File? vcf
        String dockerImage
        String output_dir

    }
    Int disk_gb = ceil((size(vcf, "GiB"))+ 4 + 10)
    command <<<
        set -x
        mkdir -p ~{output_dir}/genotype && \
        gatk RenameSampleInVcf \
        INPUT=~{vcf} \
        OUTPUT=~{output_dir}/genotype/~{sample_name}.Varscan.renamed.vcf \
        NEW_SAMPLE_NAME=~{sample_name}
        true
    >>>
    output {
        File? finalVcf = "${output_dir}/genotype/${sample_name}.Varscan.renamed.vcf"
    }
    runtime {
        docker: "${dockerImage}"
        memory: "8 GB"
        cpu: 4
        disks: "local-disk ${disk_gb} SSD"
        continueOnReturnCode: true
    }
}