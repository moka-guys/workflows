version 1.1

task VarDict_v1_0 {
    input {
        String sampleName
        File tumorBam
        File tumorBamIndex
        File reference
        File bedFile
        Int chromosomeColumn = 1
        Int startColumn = 2
        Int endColumn = 3
        Int geneColumn = 4
    }
    meta {
        title: "VarDict_v1_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
            runtime_docker_image: "swglh/vardictjava:1.8",
            applet_version: "v1_0",
            release_status: "unreleased"
            }
    }
    Int disk_gb = select_first([ceil(size(tumorBam, "GiB") + size(reference, "GiB") + 10), 10])
    command <<<
        set -exo pipefail
        touch ~{tumorBamIndex}
        mkdir genome
        tar zxf ~{reference} -C genome
        genome_file=`ls genome/*.fa`     # Locate a file called <ref>.fa
        VarDict \
        -G $genome_file \
        -N ~{sampleName} \
        -b ~{tumorBam} \
        -c ~{chromosomeColumn} \
        -S ~{startColumn} \
        -E ~{endColumn} \
        -g ~{geneColumn} \
        -U \
        ~{bedFile} | \
        teststrandbias.R | \
        var2vcf_valid.pl -N ~{sampleName} \
        > ~{sampleName}.vardictsingle.vcf
        >>>
    output {
        File vardictVcf = "${sampleName}.vardictsingle.vcf"
    }
    runtime {
        docker: "dx://project-G76q9bQ0PXfP7q972fVf2X19:file-GKv3xZ00PXf7v3xk8gY0f4Xj"
        memory: "4 GB"
        cpu: 8
        dx_instance_type: "mem1_ssd1_x8"
        disks: "local-disk ${disk_gb} SSD"
    }
}
