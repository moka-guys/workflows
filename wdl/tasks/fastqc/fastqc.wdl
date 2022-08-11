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
    meta {
        title: "fastqc_v1_3"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-FBPFfkj0jy1Q114YGQ0yQX8Y",
                        version: "v1.3",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        File report_html = "placeholder.txt"
        File stats_txt = "placeholder.txt"
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    id: "applet-FBPFfkj0jy1Q114YGQ0yQX8Y",
                    name: "fastqc_v1.3"
                }
    }
}