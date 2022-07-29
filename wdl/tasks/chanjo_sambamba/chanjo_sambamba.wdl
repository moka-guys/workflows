version 1.0

task chanjo_sambamba_coverage_v1_13 {
  input {
    Int? min_base_qual
    String coverage_level
    Int? min_mapping_qual
    Boolean? exclude_failed_quality_control
    Boolean? merge_overlapping_mate_reads
    File? bam_index
    File sambamba_bed
    Boolean? exclude_duplicate_reads
    File? bamfile
    String? additional_sambamba_flags
    String? additional_filter_commands
  }

  command <<< >>>

  output {
    Array[File]+ chanjo_raw_output = ["placeholder.txt"]
    Array[File]+ chanjo_yaml = ["placeholder.txt"]
    Array[File]+ chanjo_output_to_report = ["placeholder.txt"]
  }

  runtime {
    dx_app: object {
              type: "applet",
              id: "applet-G6vyyf00jy1kPkX9PJ1YkxB1",
              name: "chanjo_sambamba_coverage_v1.13"
            }
  }
}