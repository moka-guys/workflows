version 1.0

import "tasks/structs/structs.wdl"
import "tasks/fastqc/fastqc.wdl" as fastqc
import "tasks/fastp/fastp.wdl" as fastp
import "tasks/bwa_mem/bwa_mem.wdl" as bwa_mem
import "tasks/umi_collapse/umi_collapse.wdl" as umi_collapse
import "tasks/chanjo_sambamba/chanjo_sambamba.wdl" as chanjo_sambamba
import "tasks/moka_picard/moka_picard.wdl" as moka_picard
import "tasks/vardict/vardict.wdl" as vardict
import "tasks/mutect2/mutect2.wdl" as mutect2
import "tasks/msisensor2/msisensor2.wdl" as msisensor2
import "tasks/variant_filtration/variant_filtration.wdl" as variant_filtration_task
import "tasks/combine_vcfs/combine_vcfs.wdl" as combine_vcfs
import "tasks/rename_sample_in_vcf/rename_sample_in_vcf.wdl" as rename_sample_in_vcf
import "tasks/vt/vt.wdl" as vt
import "tasks/multiqc/multiqc.wdl" as multiqc


workflow DNA_pipeline {
    meta {
        developer: "moka-guys/DNAnexus"
        date: "27/08/2021"
        version: "1.0"
    }
    input {
        String project
        Array[Sample] samples
        String sambamba_coverage_level
        File reference_fasta_index
        File reference_bwa_index
        File bedfile
        String Capture_panel
        String MSI_model
        Boolean? MSI_microsatellite_only
        Int? MSI_coverage_threshold
        Boolean add_read_group
        String? read_group_platform
        String? read_group_platform_unit
        String? read_group_library
        Boolean? all_alignments
        Boolean? mark_as_secondary
        String? advanced_options
        }

    parameter_meta {
        MSI_microsatellite_only: {
            default: false
        }
        MSI_coverage_threshold: {
            default: 20
        }
        add_read_group: {
            default: true
        }
        read_group_platform: {
            default: "ILLUMINA"
        }
        read_group_platform_unit: {
            default: "None"
        }
        read_group_library: {
            default: "1"
        }
        mark_as_secondary: {
            default: true
        }
        advanced_options: {
            default: ""
        }
    }


    scatter (sample in samples) {

        # FASTQC
        call fastqc.fastqc_v1_3 as fastqc_1 {
            input:
            reads = sample.fastq_file_1
        }

        call fastqc.fastqc_v1_3 as fastqc_2 {
            input:
            reads = sample.fastq_file_2
        }
        # Bristol app - FASTP - UMI extraction
        call fastp.Fastp {
            input:
            output_dir = sample.output_dir,
            sample_name = sample.sample_name,
            fastq_files = [sample.fastq_file_1, sample.fastq_file_2]
        }
        # BWA MEM - alignment
        call bwa_mem.bwa_mem_fastq_read_mapper_v1_3 as bwa_mem {
            input:
            read_group_sample = sample.sample_name,
            reads_fastqgz = Fastp.trimmed_fastq_R1,
            reads2_fastqgz = Fastp.trimmed_fastq_R2,
            genomeindex_targz = reference_bwa_index,
            add_read_group = add_read_group,
            read_group_id = sample.sample_name,
            read_group_platform = read_group_platform,
            read_group_platform_unit = read_group_platform_unit,
            read_group_library = read_group_library,
            all_alignments = all_alignments,
            mark_as_secondary = mark_as_secondary,
            advanced_options = advanced_options
        }
#        # Bristol app - UMICOLLAPSE - alignment collapse by UMI
#        call umi_collapse.UMICollapse as UMICollapse {
#            input:
#            sample_name = sample.sample_name,
#            precollapsed_bam = bwa_mem.sorted_bam
#            precollapsed_bam_index = bwa_mem.sorted_bai
#        }
#        # calculate exon-level and gene-level coverage
#        call chanjo_sambamba.chanjo_sambamba_coverage_v1_13 as chanjo_sambamba {
#            input:
#            coverage_level = sambamba_coverage_level,
#            sambamba_bed = bedfile,
#            bamfile = UMICollapse.final_bam,
#            bam_index = UMICollapse.final_bam_index
#        }
#        # QC stats
#        call moka_picard.moka_picard_v1_1 as moka_picard {
#            input:
#            sorted_bam = UMICollapse.final_bam,
#            fasta_index = reference_fasta_index,
#            vendor_exome_bedfile = bedfile,
#            Capture_panel = Capture_panel
#        }
#        # Bristol app - ours is an old outdated version of vardict
#        call vardict.VarDict as varDict {
#            input:
#                sampleName = sample.sample_name,
#                tumorBam = UMICollapse.final_bam,
#                tumorBamIndex = UMICollapse.final_bam_index,
#                reference = reference_fasta_index,
#                bedFile = bedfile,
#                output_dir = sample.output_dir,
#                dockerImage = "swglh/vardictjava:1.8"
#        }
#        # Bristol app
#        call mutect2.Mutect2 as m2 {
#            input:
#                sample_name = sample.sample_name,
#                output_dir = sample.output_dir,
#                reference = reference_fasta_index,
#                mappings_bam = UMICollapse.final_bam,
#                mappings_bai = UMICollapse.final_bam_index,
#                intervals = bedfile,
#                dockerImage = "swglh/gatk:4.2.0.0"
#        }
#        # Bristol app
#        call mutect2.FilterCalls as m2f {
#            input:
#                sample_name = sample.sample_name,
#                output_dir = sample.output_dir,
#                reference = reference_fasta_index,
#                intervals = bedfile,
#                unfiltered_vcf = m2.vcf,
#                stats = m2.stats,
#                dockerImage = "swglh/gatk:4.2.0.0"
#        }
#        # Bristol app - MSI Sensor 2 - CPU based
#        call msisensor2.MsiSensor2 as MsiSensor2 {
#            input:
#                input_bam = UMICollapse.final_bam,
#                input_bam_index = UMICollapse.final_bam_index,
#                model = MSI_model,
#                coverage_threshold = MSI_coverage_threshold,
#                microsatellite_only = MSI_microsatellite_only,
#                sample_name = sample.sample_name
#        }
#        # Bristol app - combines vcfs from vardict and mutect
#        call combine_vcfs.CombineVcfs as combiner {
#            input:
#                sample_name = sample.sample_name,
#                output_dir = sample.output_dir,
#                reference = reference_fasta_index,
#                vardict_vcf = varDict.vardictVcf,
#                mutect_vcf = m2f.vcf,
#                dockerImage = "broadinstitute/gatk3:3.8-1"
#        }
#        # Bristol app - normalises variant representation in the vcf
#        call vt.vtNormalize as norm {
#            input:
#                output_dir = sample.output_dir,
#                sampleName = sample.sample_name,
#                reference = reference_fasta_index,
#                vcf = combiner.combined_vcf,
#                dockerImage = "swglh/vtapp:v1"
#        }
#        # Bristol app - Decomposes biallelic block substitutions into its constituent SNPs
#        call vt.vtDecompose as decomp {
#            input:
#                output_dir = sample.output_dir,
#                sampleName = sample.sample_name,
#                vcf = norm.normalisedvcf,
#                dockerImage = "swglh/vtapp:v1"
#        }
#        # Bristol app - Filter variant calls based on INFO and/or FORMAT annotations
#        call variant_filtration_task.variant_filtration as filter_variants {
#            input:
#                sample_name = sample.sample_name,
#                output_dir = sample.output_dir,
#                reference = reference_fasta_index,
#                vcf = decomp.decomposedvcf,
#                dockerImage = "swglh/gatk:4.2.0.0"
#        }
    }
#
#    if (length(filter_variants.is_done) == length(samples)) {
#        call applets.multiqc_v1_15_0 as multiqc {
#            input:
#                project_for_multiqc = project,
#                coverage_level = sambamba_coverage_level
#        }
#    }

    output {
        Array[File?] fastqc_1_html = fastqc_1.report_html
        Array[File?] fastqc_1_stats = fastqc_1.stats_txt
        Array[File?] fastqc_2_html = fastqc_2.report_html
        Array[File?] fastqc_2_stats = fastqc_2.stats_txt
        Array[File?] fastp_report = Fastp.fastp_report
        Array[File?] fastp_json = Fastp.fastp_json
        Array[File?] trimmed_fastq_R1 = Fastp.trimmed_fastq_R1
        Array[File?] trimmed_fastq_R2 = Fastp.trimmed_fastq_R2
        Array[File?] precollapsed_bam = bwa_mem.sorted_bam
        Array[File?] precollapsed_bam_index = bwa_mem.sorted_bai
#        Array[File?] final_bam = UMICollapse.final_bam
#        Array[File?] final_bam_index = UMICollapse.final_bam_index
#        Array[Array[File?]] chanjo_raw_output = chanjo_sambamba.chanjo_raw_output
#        Array[Array[File?]] chanjo_yaml = chanjo_sambamba.chanjo_yaml
#        Array[Array[File?]] chanjo_output_to_report = chanjo_sambamba.chanjo_output_to_report
#        Array[Array[File?]] moka_picard_stats = moka_picard.moka_picard_stats
#        Array[File?] vardict_raw_vcf = varDict.vardictVcf
#        Array[File?] mutect2_raw_vcf = m2.vcf
#        Array[File?] mutect2_bam = m2.bam
#        Array[File?] mutect2_bai = m2.bai
#        Array[File?] mutect2_stats = m2.stats
#        Array[File?] mutect2_filtered_vcf = m2f.vcf
#        Array[File?] msisensor_report = MsiSensor2.output_report
#        Array[File?] msisensor_report_dis = MsiSensor2.output_report_dis
#        Array[File?] msisensor_report_somatic = MsiSensor2.output_report_somatic
#        Array[File?] combined_vcf = combiner.combined_vcf
#        Array[File?] normalised_vcf = norm.normalisedvcf
#        Array[File?] normalised_decomposed_vcf = decomp.decomposedvcf
#        Array[File?] filtered_vcf = filter_variants.softfiltered_vcf
#        Array[File]+? multiqc_output_file = multiqc.multiqc
#        File? multiqc_report = multiqc.multiqc_report
    }
}