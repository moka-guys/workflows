version 1.1

# Run for samples with 'HD200' in the sample name
# Compare with the HD200 known variants to generate recall statistics

task sompy_v1_2 {
    input {
        File truthVCF
        Array[File]+ queryVCF
        Boolean varscan
        Boolean TSO
        Boolean skip
    }
    meta {
        title: "sompy_v1.2"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-G9yPb780jy1p660k6yBvQg07",
                        version: "v1.2",
                        release_status: "released"
        }
    }
    command <<< >>>
    output {
        Array[File]+ sompy_output = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                    id: "applet-G9yPb780jy1p660k6yBvQg07",
                    name: "sompy_v1.2"
                }
    }
}