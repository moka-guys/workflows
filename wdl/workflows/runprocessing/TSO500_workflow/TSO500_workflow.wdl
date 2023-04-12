version 1.1
# Accompanying extras.json file provides the required permissions to all
# workflow tasks to download files from other projects

import "../../../tasks/fastqc/fastqc.wdl" as fastqc
import "../../../tasks/fastp/fastp.wdl" as fastp
import "../../../tasks/bwa_mem/bwa_mem.wdl" as bwa_mem
import "../../../tasks/umicollapse/umicollapse.wdl" as umi_collapse
import "../../../tasks/vardict/vardict.wdl" as vardict
import "../../../tasks/mutect2/mutect2.wdl" as mutect2
import "../../../tasks/GATK_FilterMutectCalls/GATK_FilterMutectCalls.wdl" as GATK_FilterMutectCalls
import "../../../tasks/GATK_MergeVcfs/GATK_MergeVcfs.wdl" as GATK_MergeVcfs
import "../../../tasks/vtNormalize_Decompose/vtNormalize_Decompose.wdl" as vtNormalize_Decompose
import "../../../tasks/msisensor2/msisensor2.wdl" as msisensor2
import "../../../tasks/verify_bam_id/verify_bam_id.wdl" as verify_bam_id
import "../../../tasks/chanjo_sambamba/chanjo_sambamba.wdl" as chanjo_sambamba
import "../../../tasks/moka_picard/moka_picard.wdl" as moka_picard
import "../../../tasks/sompy/sompy.wdl" as sompy


workflow TSO500_workflow_v1 {
    meta {
        developer: "Rachel Duffin"
        date: "27/08/2021"
        version: "1.0"
    }
    input {
        String sample_name
        Boolean HD200
        File fastq_file_1
        File fastq_file_2
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
        File sompy_truthVCF
        }
        
    Array[File]+ fastqs = [fastq_file_1, fastq_file_2]

    call fastqc.fastqc_v1_4_0 as fastqc_v1_4_0 {
       input:
           reads = fastqs
    }
    # Bristol app - FASTP - UMI extraction
    call fastp.fastp_v1_0 as fastp_v1_0 {
        # Need to convert this so it doesn't have a frag - think its something to do with passing it an array
        input:
            sample_name = sample_name,
            fastq_file_1 = fastq_file_1,
            fastq_file_2 = fastq_file_2
    }
    # BWA MEM - alignment
    call bwa_mem.bwa_mem_fastq_read_mapper_v1_3 as bwa_mem_v1_3 {
        input:
            read_group_sample = sample_name,
            reads_fastqgz = fastp_v1_0.trimmed_fastq_R1,
            reads2_fastqgz = fastp_v1_0.trimmed_fastq_R2,
            genomeindex_targz = reference_bwa_index,
            add_read_group = add_read_group,
            read_group_id = fastp_v1_0.filename_stem,
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
            sample_name = fastp_v1_0.filename_stem,
            precollapsed_bam = bwa_mem_v1_3.sorted_bam,
            precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
    }
    # Bristol app - ours is an old outdated version of vardict
    call vardict.VarDict_v1_0 as VarDict_v1_0 {
        input:
            sampleName = sample_name,
            tumorBam = UMICollapse_v1_0.final_bam,
            tumorBamIndex = UMICollapse_v1_0.final_bam_index,
            reference = reference_fasta_index,
            bedFile = bedfile
    }
    # Bristol app
    call mutect2.Mutect2_v1_0 as Mutect2_v1_0 {
        input:
            sample_name = sample_name,
            reference = reference_fasta_index,
            mappings_bam = UMICollapse_v1_0.final_bam,
            mappings_bai = UMICollapse_v1_0.final_bam_index,
            intervals = bedfile
    }
    # Bristol app
    call GATK_FilterMutectCalls.GATK_FilterMutectCalls_v1_0 as GATK_FilterMutectCalls_v1_0 {
        input:
            sample_name = Mutect2_v1_0.filename_stem,
            reference = reference_fasta_index,
            intervals = bedfile,
            unfiltered_vcf = Mutect2_v1_0.vcf,
            stats = Mutect2_v1_0.stats
    }
    # Bristol app - combines vcfs from vardict and mutect2
    call GATK_MergeVcfs.GATK_MergeVcfs_v1_0 as GATK_MergeVcfs_v1_0 {
        input:
            sample_name = sample_name,
            reference = reference_fasta_index,
            vardict_vcf = VarDict_v1_0.vardictVcf,
            mutect_vcf = GATK_FilterMutectCalls_v1_0.vcf
    }
    # Bristol app - normalises variant representation in the vcf. Normalized variants may have their positions.
    # changed; in such cases, the normalized variants are reordered and output in an ordered fashion
    # Decomposes multiallelic variants into biallelic variants
    # Indexes the final vcf file so it can be viewed in the IGV webapp
    call vtNormalize_Decompose.vtNormalize_Decompose_v1_0 as vtNormalize_Decompose_v1_0 {
        input:
            sample_name = GATK_MergeVcfs_v1_0.filename_stem,
            reference = reference_fasta_index,
            vcf = GATK_MergeVcfs_v1_0.combined_vcf
    }
    # Bristol app - MSI Sensor 2 - CPU based
    call msisensor2.MsiSensor2_v1_0 as MsiSensor2_v1_0 {
        input:
            sample_name = sample_name,
            input_bam = UMICollapse_v1_0.final_bam,
            input_bam_index = UMICollapse_v1_0.final_bam_index,
            model = MSI_model,
            coverage_threshold = MSI_coverage_threshold,
            microsatellite_only = MSI_microsatellite_only,
    }
    # VerifyBamID - contamination detection
    call verify_bam_id.verify_bam_id_v1_2_0 as verify_bam_id_v1_2_0 {
        input:
            input_bam = UMICollapse_v1_0.final_bam,
            input_bam_index = UMICollapse_v1_0.final_bam_index,
            skip = false
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
    # Run for samples with 'HD200' in the sample name
    # Comparing it with the HD200 known variants to generate recall statistics
    if (HD200) {
        call sompy.sompy_v1_2 as sompy_v1_2 {
            input:
                truthVCF = sompy_truthVCF,
                queryVCF = [vtNormalize_Decompose_v1_0.decomposedvcf],
                varscan = false,
                TSO = true,
                skip = false
        }
    }

    output {
        Array[File] fastqc_stats = fastqc_v1_4_0.stats_txt
        Array[File] fastqc_html = fastqc_v1_4_0.report_html
        File fastp_report = fastp_v1_0.fastp_report
        File fastp_json = fastp_v1_0.fastp_json
        File trimmed_fastq_R1 = fastp_v1_0.trimmed_fastq_R1
        File trimmed_fastq_R2 = fastp_v1_0.trimmed_fastq_R2
        File precollapsed_bam = bwa_mem_v1_3.sorted_bam
        File precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
        File final_bam = UMICollapse_v1_0.final_bam
        File final_bam_index = UMICollapse_v1_0.final_bam_index
        Array[File]+ verifybamid_out = verify_bam_id_v1_2_0.verifybamid_out
        Array[File] chanjo_raw_output = chanjo_sambamba_coverage_v1_13.chanjo_raw_output
        Array[File] chanjo_yaml = chanjo_sambamba_coverage_v1_13.chanjo_yaml
        Array[File] chanjo_output_to_report = chanjo_sambamba_coverage_v1_13.chanjo_output_to_report
        Array[File] moka_picard_stats = moka_picard_v1_2.moka_picard_stats
        File vardict_raw_vcf = VarDict_v1_0.vardictVcf
        File mutect2_raw_vcf = Mutect2_v1_0.vcf
        File mutect2_bam = Mutect2_v1_0.bam
        File mutect2_bai = Mutect2_v1_0.bai
        File mutect2_stats = Mutect2_v1_0.stats
        File mutect2_filtered_vcf = GATK_FilterMutectCalls_v1_0.vcf
        File msisensor_report = MsiSensor2_v1_0.output_report
        File msisensor_report_dis = MsiSensor2_v1_0.output_report_dis
        File msisensor_report_somatic = MsiSensor2_v1_0.output_report_somatic
        File combined_vcf = GATK_MergeVcfs_v1_0.combined_vcf
        File normalised_vcf = vtNormalize_Decompose_v1_0.normalisedvcf
        File normalised_decomposed_vcf = vtNormalize_Decompose_v1_0.decomposedvcf
        File compressed_vcf = vtNormalize_Decompose_v1_0.compressed_vcf
        File compressed_vcf_index = vtNormalize_Decompose_v1_0.compressed_vcf_index
        Array[File]+? sompy_output = sompy_v1_2.sompy_output
    }
}