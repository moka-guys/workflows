version 1.0

task fastqc_v1_3 {
  input {
    String? format
    Int? kmer_size
    File? adapters_txt
    Boolean? nogroup
    File? limits_txt
    File reads
    File? contaminants_txt
    String? extra_options
  }

  command <<< >>>

  output {
    File report_html = "placeholder.txt"
    File stats_txt = "placeholder.txt"
  }

  runtime {
    dx_app: object {
      type: "applet",
      id: "applet-FBPFfkj0jy1Q114YGQ0yQX8Y",
      name: "fastqc_v1.3"
    }
  }
}