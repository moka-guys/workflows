version 1.1

task verify_bam_id_v1_2_0 {
    input {
        File input_bam
        File input_bam_index
        Boolean skip = true
    }
    meta {
        title: "verify_bam_id_v1_2_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                      runtime_applet: "applet-GK8FQJj0jy1ZZKz54q1ZvYg0",
                      version: "v1_2_0",
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
                  project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                  id: "applet-GK8FQJj0jy1ZZKz54q1ZvYg0",
                  name: "verify_bam_id_v1.1.1"
                }
    }
}