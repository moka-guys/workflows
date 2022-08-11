version 1.0
# Accompanying extras.json file provides the required permissions to all
# workflow tasks to download files from other projects

import "tasks/structs/structs.wdl"
import "tasks/fastqc/fastqc.wdl" as fastqc
import "tasks/fastp/fastp.wdl" as fastp
import "tasks/bwa_mem/bwa_mem.wdl" as bwa_mem
import "tasks/umi_collapse/umi_collapse.wdl" as umi_collapse
import "tasks/verify_bam_id/verify_bam_id.wdl" as verify_bam_id
import "tasks/chanjo_sambamba/chanjo_sambamba.wdl" as chanjo_sambamba
import "tasks/moka_picard/moka_picard.wdl" as moka_picard
import "tasks/vardict/vardict.wdl" as vardict
import "tasks/mutect2/mutect2.wdl" as mutect2
import "tasks/GATK_FilterMutectCalls/GATK_FilterMutectCalls.wdl" as GATK_FilterMutectCalls
import "tasks/msisensor2/msisensor2.wdl" as msisensor2
import "tasks/GATK_combine_VCFs/GATK_combine_vcfs.wdl" as GATK_combine_vcfs
import "tasks/vtNormalize/vtNormalize.wdl" as vtNormalize
import "tasks/vtDecompose/vtDecompose.wdl" as vtDecompose
import "tasks/multiqc/multiqc.wdl" as multiqc

workflow TSO500_workflow {
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
        File coverage_bedfile
        String Capture_panel
        Boolean remove_chr
        String MSI_model
        Boolean MSI_microsatellite_only
        Int MSI_coverage_threshold
        Boolean add_read_group
        String read_group_platform
        String read_group_platform_unit
        String read_group_library
        Boolean all_alignments
        Boolean mark_as_secondary
        String advanced_options
        }

    scatter (sample in samples) {

        # FASTQC
        call fastqc.fastqc_v1_3 as fastqc_v1_3_R1 {
            input:
            reads = sample.fastq_file_1
        }

        call fastqc.fastqc_v1_3 as fastqc_v1_3_R2 {
            input:
            reads = sample.fastq_file_2
        }
        # Bristol app - FASTP - UMI extraction
        call fastp.fastp_v1_0 as fastp_v1_0 {
            input:
            output_dir = sample.output_dir,
            sample_name = sample.sample_name,
            fastq_files = [sample.fastq_file_1, sample.fastq_file_2]
        }
        # BWA MEM - alignment
        call bwa_mem.bwa_mem_fastq_read_mapper_v1_3 as bwa_mem_v1_3 {
            input:
            read_group_sample = sample.sample_name,
            reads_fastqgz = fastp_v1_0.trimmed_fastq_R1,
            reads2_fastqgz = fastp_v1_0.trimmed_fastq_R2,
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
        # Bristol app - UMICOLLAPSE - alignment collapse by UMI
        call umi_collapse.UMICollapse_v1_0 as UMICollapse_v1_0 {
            input:
            sample_name = sample.sample_name,
            precollapsed_bam = bwa_mem_v1_3.sorted_bam,
            precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
        }
        # VerifyBamID - contamination detection
        call verify_bam_id.verify_bam_id_v1_1_1 as verify_bam_id_v1_1_1 {
            input:
                input_bam = UMICollapse_v1_0.final_bam,
                input_bam_index = UMICollapse_v1_0.final_bam_index
        }
        # calculate exon-level and gene-level coverage
        call chanjo_sambamba.chanjo_sambamba_coverage_v1_13 as chanjo_sambamba_coverage_v1_13 {
            input:
            coverage_level = sambamba_coverage_level,
            sambamba_bed = coverage_bedfile,
            bamfile = UMICollapse_v1_0.final_bam,
            bam_index = UMICollapse_v1_0.final_bam_index
        }
        # QC stats
        call moka_picard.moka_picard_v1_2 as moka_picard_v1_2 {
            input:
            sorted_bam = UMICollapse_v1_0.final_bam,
            fasta_index = reference_fasta_index,
            vendor_exome_bedfile = bedfile,
            Capture_panel = Capture_panel,
            remove_chr = remove_chr
        }
        # Bristol app - ours is an old outdated version of vardict
        call vardict.VarDict_v1_0 as VarDict_v1_0 {
            input:
                sampleName = sample.sample_name,
                tumorBam = UMICollapse_v1_0.final_bam,
                tumorBamIndex = UMICollapse_v1_0.final_bam_index,
                reference = reference_fasta_index,
                bedFile = bedfile,
                output_dir = sample.output_dir
        }
        # Bristol app
        call mutect2.Mutect2_v1_0 as Mutect2_v1_0 {
            input:
                sample_name = sample.sample_name,
                output_dir = sample.output_dir,
                reference = reference_fasta_index,
                mappings_bam = UMICollapse_v1_0.final_bam,
                mappings_bai = UMICollapse_v1_0.final_bam_index,
                intervals = bedfile
        }
        # Bristol app
        call GATK_FilterMutectCalls.GATK_FilterCalls_v1_0 as GATK_FilterCalls_v1_0 {
            input:
                sample_name = sample.sample_name,
                output_dir = sample.output_dir,
                reference = reference_fasta_index,
                intervals = bedfile,
                unfiltered_vcf = Mutect2_v1_0.vcf,
                stats = Mutect2_v1_0.stats
        }
        # Bristol app - MSI Sensor 2 - CPU based
        call msisensor2.MsiSensor2_v1_0 as MsiSensor2_v1_0 {
            input:
                input_bam = UMICollapse_v1_0.final_bam,
                input_bam_index = UMICollapse_v1_0.final_bam_index,
                model = MSI_model,
                coverage_threshold = MSI_coverage_threshold,
                microsatellite_only = MSI_microsatellite_only,
                sample_name = sample.sample_name
        }
        # Bristol app - combines vcfs from vardict and mutect2
        call GATK_combine_vcfs.GATK_CombineVCFs_v1_0 as GATK_CombineVCFs_v1_0 {
            input:
                sample_name = sample.sample_name,
                reference = reference_fasta_index,
                vardict_vcf = VarDict_v1_0.vardictVcf,
                mutect_vcf = GATK_FilterCalls_v1_0.vcf
        }
        # Bristol app - normalises variant representation in the vcf. Normalized variants may have their positions
        # changed; in such cases, the normalized variants are reordered and output in an ordered fashion
        call vtNormalize.vtNormalize_v1_0 as vtNormalize_v1_0 {
            input:
                sample_name = sample.sample_name,
                reference = reference_fasta_index,
                vcf = GATK_CombineVCFs_v1_0.combined_vcf
        }
        # Bristol app - decomposes multiallelic variants into biallelic variants
        call vtDecompose.vtDecompose_v1_0 as vtDecompose_v1_0 {
            input:
                sample_name = sample.sample_name,
                vcf = vtNormalize_v1_0.normalisedvcf
        }
    }
# THIS WORKS
    if (length(vtDecompose_v1_0.is_done) == length(samples)) {
        call multiqc.multiqc_v1_15_0 as multiqc {
            input:
                project_for_multiqc = project,
                coverage_level = sambamba_coverage_level
        }
    }

    output {
        Array[File?] fastqc_1_html = fastqc_v1_3_R1.report_html
        Array[File?] fastqc_1_stats = fastqc_v1_3_R1.stats_txt
        Array[File?] fastqc_2_html = fastqc_v1_3_R2.report_html
        Array[File?] fastqc_2_stats = fastqc_v1_3_R2.stats_txt
        Array[File?] fastp_report = fastp_v1_0.fastp_report
        Array[File?] fastp_json = fastp_v1_0.fastp_json
        Array[File?] trimmed_fastq_R1 = fastp_v1_0.trimmed_fastq_R1
        Array[File?] trimmed_fastq_R2 = fastp_v1_0.trimmed_fastq_R2
        Array[File?] precollapsed_bam = bwa_mem_v1_3.sorted_bam
        Array[File?] precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
        Array[File?] final_bam = UMICollapse_v1_0.final_bam
        Array[File?] final_bam_index = UMICollapse_v1_0.final_bam_index
        Array[Array[File]+] verifybamid_out = verify_bam_id_v1_1_1.verifybamid_out
        Array[Array[File?]] chanjo_raw_output = chanjo_sambamba_coverage_v1_13.chanjo_raw_output
        Array[Array[File?]] chanjo_yaml = chanjo_sambamba_coverage_v1_13.chanjo_yaml
        Array[Array[File?]] chanjo_output_to_report = chanjo_sambamba_coverage_v1_13.chanjo_output_to_report
        Array[Array[File?]] moka_picard_stats = moka_picard_v1_2.moka_picard_stats
        Array[File?] vardict_raw_vcf = VarDict_v1_0.vardictVcf
        Array[File?] mutect2_raw_vcf = Mutect2_v1_0.vcf
        Array[File?] mutect2_bam = Mutect2_v1_0.bam
        Array[File?] mutect2_bai = Mutect2_v1_0.bai
        Array[File?] mutect2_stats = Mutect2_v1_0.stats
        Array[File?] mutect2_filtered_vcf = GATK_FilterCalls_v1_0.vcf
        Array[File?] msisensor_report = MsiSensor2_v1_0.output_report
        Array[File?] msisensor_report_dis = MsiSensor2_v1_0.output_report_dis
        Array[File?] msisensor_report_somatic = MsiSensor2_v1_0.output_report_somatic
        Array[File?] combined_vcf = GATK_CombineVCFs_v1_0.combined_vcf
        Array[File?] normalised_vcf = vtNormalize_v1_0.normalisedvcf
        Array[File?] normalised_decomposed_vcf = vtDecompose_v1_0.decomposedvcf
        Array[File]+? multiqc_output_file = multiqc.multiqc
        File? multiqc_report = multiqc.multiqc_report
    }
}