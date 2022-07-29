version 1.0

task filter_vcf_with_bedfile_v1_1 {
  input {
    File vcf_file
    File vcf_index
    File bedfile
  }

  command <<< >>>

  output {
    File filtered_vcf = "placeholder.txt"
  }

  runtime {
    dx_app: object {
              type: "applet",
              id: "applet-G77X9Xj0jy1j9qgx259x37v6",
              name: "filter_vcf_with_bedfile_v1.1"
            }
  }
}