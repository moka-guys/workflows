version 1.0
# Accompanying extras.json file provides the required permissions to all
# workflow tasks to download files from other projects

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
import "tasks/combine_vcfs/combine_vcfs.wdl" as combine_vcfs
#import "tasks/vt/vt.wdl" as vt
#import "tasks/variant_filtration/variant_filtration.wdl" as variant_filtration_task
#import "tasks/filter_vcf_with_bedfile/filter_vcf_with_bedfile.wdl" as filter_vcf_with_bedfile
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
        call fastp.Fastp {
            input:
            output_dir = sample.output_dir,
            sample_name = sample.sample_name,
            fastq_files = [sample.fastq_file_1, sample.fastq_file_2]
        }
        # BWA MEM - alignment
        call bwa_mem.bwa_mem_fastq_read_mapper_v1_3 as bwa_mem_v1_3 {
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
        # Bristol app - UMICOLLAPSE - alignment collapse by UMI
        call umi_collapse.UMICollapse as UMICollapse {
            input:
            sample_name = sample.sample_name,
            precollapsed_bam = bwa_mem_v1_3.sorted_bam,
            precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
        }
        # calculate exon-level and gene-level coverage
        call chanjo_sambamba.chanjo_sambamba_coverage_v1_13 as chanjo_sambamba {
            input:
            coverage_level = sambamba_coverage_level,
            sambamba_bed = coverage_bedfile,
            bamfile = UMICollapse.final_bam,
            bam_index = UMICollapse.final_bam_index
        }
        # QC stats
        call moka_picard.moka_picard_v1_2 as moka_picard_v1_2 {
            input:
            sorted_bam = UMICollapse.final_bam,
            fasta_index = reference_fasta_index,
            vendor_exome_bedfile = bedfile,
            Capture_panel = Capture_panel,
            remove_chr = remove_chr
        }
        # Bristol app - ours is an old outdated version of vardict
        call vardict.VarDict as varDict {
            input:
                sampleName = sample.sample_name,
                tumorBam = UMICollapse.final_bam,
                tumorBamIndex = UMICollapse.final_bam_index,
                reference = reference_fasta_index,
                bedFile = bedfile,
                output_dir = sample.output_dir
        }
        # Bristol app
        call mutect2.Mutect2 as mutect2 {
            input:
                sample_name = sample.sample_name,
                output_dir = sample.output_dir,
                reference = reference_fasta_index,
                mappings_bam = UMICollapse.final_bam,
                mappings_bai = UMICollapse.final_bam_index,
                intervals = bedfile
        }
        # Bristol app
        call mutect2.FilterCalls as mutect2_FilterCalls {
            input:
                sample_name = sample.sample_name,
                output_dir = sample.output_dir,
                reference = reference_fasta_index,
                intervals = bedfile,
                unfiltered_vcf = mutect2.vcf,
                stats = mutect2.stats
        }
#        # Dockerhub cnvkit image
#        call cnvkit_parabricks.cnvkit_parabricks {
#            input:
#                mappings_bam = UMICollapse.final_bam,
#                mappings_bai = UMICollapse.final_bam_index,
#                reference_fasta = reference_fasta_index
#            }
        # Bristol app - MSI Sensor 2 - CPU based
        call msisensor2.MsiSensor2 as MsiSensor2 {
            input:
                input_bam = UMICollapse.final_bam,
                input_bam_index = UMICollapse.final_bam_index,
                model = MSI_model,
                coverage_threshold = MSI_coverage_threshold,
                microsatellite_only = MSI_microsatellite_only,
                sample_name = sample.sample_name
        }
        # Bristol app - combines vcfs from vardict and mutect2
        call combine_vcfs.CombineVcfs as GATK_CombineVariants {
            input:
                sample_name = sample.sample_name,
                reference = reference_fasta_index,
                vardict_vcf = varDict.vardictVcf,
                mutect_vcf = mutect2_FilterCalls.vcf
        }
#        # Bristol app - normalises variant representation in the vcf. Normalized variants may have their positions
#        # changed; in such cases, the normalized variants are reordered and output in an ordered fashion
#        call vt.vtNormalize as norm {
#            input:
#                sample_name = sample.sample_name,
#                reference = reference_fasta_index,
#                vcf = GATK_CombineVariants.combined_vcf
#        }
#        # Bristol app - decomposes multiallelic variants into biallelic variants
#        call vt.vtDecompose as decomp {
#            input:
#                sample_name = sample.sample_name,
#                vcf = norm.normalisedvcf
#        }
#        # Bristol app - Filter variant calls based on INFO and/or FORMAT annotations
#        call variant_filtration_task.variant_filtration as filter_variants {
#            input:
#                sample_name = sample.sample_name,
#                reference = reference_fasta_index,
#                vcf = decomp.decomposedvcf
#        }
#        # Trim to panel
#        call filter_vcf_with_bedfile.filter_vcf_with_bedfile as filter_with_bedfile {
#            input:
#                vcf_file = filter_variants.softfiltered_vcf
#                vcf_index = ???
#                bedfile = bedfile
#        }

    }
# THIS WORKS
    if (length(GATK_CombineVariants.is_done) == length(samples)) {
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
        Array[File?] fastp_report = Fastp.fastp_report
        Array[File?] fastp_json = Fastp.fastp_json
        Array[File?] trimmed_fastq_R1 = Fastp.trimmed_fastq_R1
        Array[File?] trimmed_fastq_R2 = Fastp.trimmed_fastq_R2
        Array[File?] precollapsed_bam = bwa_mem_v1_3.sorted_bam
        Array[File?] precollapsed_bam_index = bwa_mem_v1_3.sorted_bai
        Array[File?] final_bam = UMICollapse.final_bam
        Array[File?] final_bam_index = UMICollapse.final_bam_index
        Array[Array[File?]] chanjo_raw_output = chanjo_sambamba.chanjo_raw_output
        Array[Array[File?]] chanjo_yaml = chanjo_sambamba.chanjo_yaml
        Array[Array[File?]] chanjo_output_to_report = chanjo_sambamba.chanjo_output_to_report
        Array[Array[File?]] moka_picard_stats = moka_picard_v1_2.moka_picard_stats
        Array[File?] vardict_raw_vcf = varDict.vardictVcf
        Array[File?] mutect2_raw_vcf = mutect2.vcf
        Array[File?] mutect2_bam = mutect2.bam
        Array[File?] mutect2_bai = mutect2.bai
        Array[File?] mutect2_stats = mutect2.stats
        Array[File?] mutect2_filtered_vcf = mutect2_FilterCalls.vcf
#        Array[Array[File?]] cnvkit_output = cnvkit_parabricks.cnvkit_output
        Array[File?] msisensor_report = MsiSensor2.output_report
        Array[File?] msisensor_report_dis = MsiSensor2.output_report_dis
        Array[File?] msisensor_report_somatic = MsiSensor2.output_report_somatic
        Array[File?] combined_vcf = GATK_CombineVariants.combined_vcf
#        Array[File?] normalised_vcf = norm.normalisedvcf
#        Array[File?] normalised_decomposed_vcf = decomp.decomposedvcf
#        Array[File?] filtered_vcf = filter_variants.softfiltered_vcf
#        Array[File?] filter_with_bedfile_vcf = filter_with_bedfile.filtered_vcf
        Array[File]+? multiqc_output_file = multiqc.multiqc
        File? multiqc_report = multiqc.multiqc_report
    }
}