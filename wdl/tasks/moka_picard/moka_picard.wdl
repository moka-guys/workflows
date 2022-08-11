version 1.0

task moka_picard_v1_2 {
    input {
        File? sorted_bam
        File fasta_index
        File vendor_exome_bedfile
        Boolean remove_chr
        String Capture_panel
    }
    meta {
        title: "moka_picard_v1_2"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-G9yJ57j0jy1ZV0fxPZZXJ8FJ",
                        version: "v1.2",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ moka_picard_stats = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    id: "applet-G9yJ57j0jy1ZV0fxPZZXJ8FJ",
                    name: "moka_picard_v1.2"
                }
    }
}