version 1.1

task multiqc_v1_15_0 {
    input {
        String project_for_multiqc
        String coverage_level
    }
    meta {
        title: "multiqc_v1_15_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-G7QB6zj0jy1z1ZV1P5VZBj9p",
                        version: "v1.15",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ multiqc = ["placeholder.txt"]
        File multiqc_report = "placeholder.txt"
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: 
            object {
                    type: "applet",
                    project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                    id: "applet-G7QB6zj0jy1z1ZV1P5VZBj9p",
                    name: "multiqc_v1.15.0"
                }
    }
}