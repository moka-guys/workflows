version 1.0

task moka_picard_v1_1 {
  input {
    File? sorted_bam
    File fasta_index
    File vendor_exome_bedfile
    String Capture_panel
  }

  command <<< >>>

  output {
    Array[File]+ moka_picard_stats = ["placeholder.txt"]
  }

  runtime {
    dx_app: object {
      type: "applet",
      id: "applet-FPv2Q1Q0jy1pBk9bG7GZ5zQp",
      name: "moka_picard_v1.1"
    }
  }
}