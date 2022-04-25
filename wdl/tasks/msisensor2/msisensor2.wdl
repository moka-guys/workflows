version 1.0

task MsiSensor2 {
    input {
        File? input_bam
        File? input_bam_index
        String model
        Int? coverage_threshold
        Boolean? homopolymer_only = false
        Boolean? microsatellite_only = false
        String sample_name
    }

    parameter_meta {
        model:{
            help: "model",
            choices: ["hg19_GRCh37","b37_HumanG1Kv37","hg38"],
            default: "hg38"
        }
    }
    String output_file = '~{sample_name}.tumor.prefix'

    command <<<
        if [ ~{homopolymer_only} = true ] ; then
            homopolymer_parameter=1
        else
            homopolymer_parameter=0
        fi 

        if [ ~{microsatellite_only} = true ] ; then
            microsatelite_parameter=1
        else
            microsatelite_parameter=0
        fi 

        msisensor2 msi -M '/msisensor2/models_'~{model} \
            -t ~{input_bam} \
            -c ~{coverage_threshold} \
            -b $(nproc) \
            -x ${homopolymer_parameter} \
            -y ${microsatelite_parameter} \
            -o ~{output_file}
            true

    >>>

    output {
        File? output_report = "${output_file}"
        File? output_report_dis = "${output_file}_dis"
        File? output_report_somatic = "${output_file}_somatic"

    }

    runtime {
        docker: "dx://file-G60XzGj0jy5vbvjk9pV0kFKv"
        dx_instance_type: "mem2_ssd1_v2_x16"
    }
}
