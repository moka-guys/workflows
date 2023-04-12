version 1.1

task fastqc_v1_4_0 {
    input {
        Array[File]+ reads
        File? contaminants_txt
        File? adapters_txt
        File? limits_txt
        String? format
        Int? kmer_size
        Boolean? nogroup
        String? extra_options
    }
    meta {
        title: "fastqc_v1_4_0"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-GKXqZV80jy1QxF4yKYB4Y3Kz",
                        version: "v1.4.0",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ report_html = ["placeholder.txt"]
        Array[File]+ stats_txt = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                    id: "applet-GKXqZV80jy1QxF4yKYB4Y3Kz",
                    name: "fastqc_v1.4.0"
                }
    }
}