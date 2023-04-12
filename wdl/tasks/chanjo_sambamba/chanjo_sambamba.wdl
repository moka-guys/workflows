version 1.1

task chanjo_sambamba_coverage_v1_13 {
    input {
        File bamfile
        File bam_index
        File sambamba_bed
        String coverage_level
        Int? min_base_qual
        Int? min_mapping_qual
        Boolean? exclude_failed_quality_control
        Boolean? merge_overlapping_mate_reads
        Boolean? exclude_duplicate_reads
        String? additional_sambamba_flags
        String? additional_filter_commands
    }
    meta {
        title: "chanjo_sambamba_coverage_v1_13"
        summary: "ADD HEADLINE SUMMARY HERE"
        description: "ADD LONGER DESCRIPTION HERE"
        tags: ["TSO500", "WDL"]
        properties: {
                        runtime_applet: "applet-G6vyyf00jy1kPkX9PJ1YkxB1",
                        applet_version: "v1.13",
                        release_status: "released"
                    }
    }
    command <<< >>>
    output {
        Array[File]+ chanjo_raw_output = ["placeholder.txt"]
        Array[File]+ chanjo_yaml = ["placeholder.txt"]
        Array[File]+ chanjo_output_to_report = ["placeholder.txt"]
    }
    runtime {
        # Eventually switch from using DNAnexus applet
        dx_app: object {
                    type: "applet",
                    project: "project-ByfFPz00jy1fk6PjpZ95F27J",
                    id: "applet-G6vyyf00jy1kPkX9PJ1YkxB1",
                    name: "chanjo_sambamba_coverage_v1.13"
                }
    }
}