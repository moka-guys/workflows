version 1.0

task bwa_mem_fastq_read_mapper_v1_3 {
  input {
    File? reads_fastqgz
    File? reads2_fastqgz
    String? read_group_platform_unit
    String? read_group_platform
    File genomeindex_targz
    String? read_group_sample
    Boolean? mark_as_secondary
    String? read_group_id
    Boolean? add_read_group
    String? read_group_library
    String? advanced_options
    Boolean? all_alignments
  }

  command <<< >>>

  output {
    File sorted_bam = "placeholder.txt"
    File sorted_bai = "placeholder.txt"
  }

  runtime {
    dx_app: object {
      type: "applet",
      id: "applet-FBPv1QQ0jy1zZ3vX7jybPz9Q",
      name: "bwa_mem_fastq_read_mapper_v1.3"
    }
  }
}