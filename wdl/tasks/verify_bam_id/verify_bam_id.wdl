version 1.0

task verify_bam_id_v1_1_1 {
    input {
        File? input_bam
        File? input_bam_index
    }
    meta {
        title: "verify_bam_id_v1_1_1"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                      runtime_applet: "applet-FXXvZ280jy1ZzV5p5PJPX9bQ",
                      version: "v1_1_1",
                      release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ verifybamid_out = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                  type: "applet",
                  id: "applet-FXXvZ280jy1ZzV5p5PJPX9bQ",
                  name: "verify_bam_id_v1.1.1"
                }
    }
}