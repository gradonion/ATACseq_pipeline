#Snakefile for ATAC-seq peak count generation

import glob
import os

pd = config["proj_dir"]
bam_dir = config["bam_dir"]
celltype = config["celltype"]
def getNames(dir,exts):
	fnames = glob.glob('{total_dir}/*{extension}'.format(total_dir=dir,extension=exts))
	snames = list()
	for name in fnames:
		name = name.split('/')[-1]
		name = name[0:(len(name)-len(exts))]
		snames.append(name)
	return(snames)
# returns sample names contained in a directory with similar files 
samples = getNames(bam_dir,".bam")
print(samples)

cleanbam_dir = config["cleanbam_dir"]
bedfile_dir = "bedfiles/"
peak_outdir = "peakcalling/"
count_dir = "count/"

dir_log = "log"
if not os.path.isdir(dir_log):
    os.mkdir(dir_log)


rule all:
	input:
		expand(count_dir + "{celltype}_per_sample_count.txt",celltype=celltype)

rule align_bam_sort:
	input:
		bam_dir + "{samples}.bam"
	output:
		cleanbam_dir + '{samples}.sorted.bam'
	threads: config['alignment_params']['ncpus']
	shell:
		'samtools sort -@ {threads} -m 4G -o {output} {input}'

rule align_bam_index:
	input:
		cleanbam_dir + '{samples}.sorted.bam'
	output:
		cleanbam_dir + '{samples}.sorted.bam.bai'
	shell:
		'samtools index {input}'

rule remove_duplicated_reads:
	input:
		cleanbam_dir + '{samples}.sorted.bam'
	output:
		cleanbam_dir + '{samples}.bam'
	params:
		config['alignment_params']['clean_cmd']
	shell:
		'python scripts/do_remove_dup_reads.py \
		--i {input} \
		--o {output} \
		--cmd "{params[0]}"'

rule bam2bed:
	input:
		cleanbam_dir + "{samples}.bam"
	output:
		bedfile_dir + "{samples}.sorted.bed"
	shell:
		"bedtools bamtobed -i {input} | awk '!($1 ~ /_/) {{print}}' | sort -k1,1V -k2,2n > {output}"


rule poolbed:
	input:
		expand(bedfile_dir + "{samples}.sorted.bed", samples = samples)
	output:
		bedfile_dir + celltype + "_pooled.bed.gz"
	shell:
		"cat {input} | gzip > {output}"

rule peakcalling:
	input:
		bedfile_dir + celltype + "_pooled.bed.gz"
	params:
		macs2_dir = config["macs2_dir"],
		fdr = config["peak_fdr"],
		slocal = config["small_length"],
		llocal = config["large_length"],
		output_prefix = celltype + "_pooled_cutsite",
		output_dir = peak_outdir
	output:
		peak_outdir + celltype + "_pooled_cutsite_peaks.narrowPeak"
	shell:
		"{params.macs2_dir} callpeak -t <(zcat {input}) -n {params.output_prefix} --outdir {params.output_dir} \
		-f BED -g hs --nomodel --shift -100 --extsize 200 --keep-dup all --call-summits -B \
		--slocal {params.slocal} --llocal {params.llocal} --qvalue {params.fdr}"

rule peakformatting:
	input:
		peak_outdir + celltype + "_pooled_cutsite_peaks.narrowPeak"
	output:
		peak_outdir + celltype + "_pooled_cutsite_peaks.formatted.bed"
	shell:
		"bedtools merge -i {input} -c 4,5,6 -o first,max,distinct | sort -k1,1V -k2,2n > {output}"

rule countpersample:
	input:
		peak_outdir + celltype + "_pooled_cutsite_peaks.formatted.bed",
		bedfile_dir + "{samples}.sorted.bed"		
	output:
		count_dir + "{samples}.count"
	shell:
		"cat <(echo {wildcards.samples}) <(bedtools intersect -a {input[0]} -b {input[1]} -sorted -c | cut -f7) > {output}"


rule countmatrix:
	input:
		peak_outdir + celltype + "_pooled_cutsite_peaks.formatted.bed",		
		expand(count_dir + "{samples}.count", samples=samples)
	params:
		header = 'chr'+'\t'+'start'+'\t'+'end'+'\t'+'peak_name'
	output:
		count_dir + celltype +"_per_sample_count.txt"
	shell:
		'''
		cat <(echo {params.header}) <(cut -f1-4 {input[0]}) > {celltype}_pooled_cutsite_peaks.txt
		#paste -d'\t' {celltype}_pooled_cutsite_peaks.txt {input[1]} > {output}
		paste -d'\t' {celltype}_pooled_cutsite_peaks.txt {count_dir}*count > {output}
		'''




