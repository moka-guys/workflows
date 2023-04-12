version 1.1

task upload_multiqc_v1_4_0 {
    input {
        File multiqc_html
        Array[File]+ multiqc_data_input
        Boolean upload_data_files = true
    }
    meta {
        title: "upload_multiqc_v1_4_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-G2XY8QQ0p7kzvPZBJGFygP6f",
                        version: "v1.4.0",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ upload_multiqc = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                    id: "applet-G2XY8QQ0p7kzvPZBJGFygP6f",
                    name: "upload_multiqc_v1.4.0"
                }
    }
}