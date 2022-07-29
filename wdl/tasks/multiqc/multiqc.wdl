version 1.0

task multiqc_v1_15_0 {
  input {
    String project_for_multiqc
    String coverage_level
  }

  command <<< >>>

  output {
    Array[File]+ multiqc = ["placeholder.txt"]
    File multiqc_report = "placeholder.txt"
  }

  runtime {
    dx_app: object {
              type: "applet",
              id: "applet-G7QB6zj0jy1z1ZV1P5VZBj9p",
              name: "multiqc_v1.15.0"
            }
  }
}