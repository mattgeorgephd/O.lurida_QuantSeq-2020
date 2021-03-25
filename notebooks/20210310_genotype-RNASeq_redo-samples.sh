#!/bin/bash
## Job Name
#SBATCH --job-name=QuantSeq-genotyping
## Allocation Definition 
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes 
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=7-00:00:00
## Memory per node
#SBATCH --mem=100G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lhs3@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/srlab/lhs3/jobs/20210314_Olurida_QuantSeq-Genotype-all/

# Set program paths 
bowtie2="/gscratch/srlab/programs/bowtie2-2.1.0/"
gatk="/gscratch/srlab/programs/gatk-4.1.9.0/gatk"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

homedir="/gscratch/srlab/lhs3/"
jobdir="/gscratch/srlab/lhs3/jobs/20210314_Olurida_QuantSeq-Genotype-all/"
outputdir="/gscratch/scrubbed/lhs3/20210314_Olurida_QuantSeq-Genotype-all/"

##cd ${homedir}data/QuantSeq2020/
##echo "Aligning reads for redo samples" 

redo_samples="522
    523
    524
    525
    526
    527
    528
    529
    531
    532
    533
    541
    542
    543
    551
    552b
    553
    554
    561
    562
    563
    564
    565
    571"

##for file in $redo_samples
##do
##fastq="$file.trim.fastq"
##sample="$(basename -a $fastq | cut -d "." -f 1)"
##map_file="$sample.bowtie.sam"

# run Bowtie2 on each file
##${bowtie2}bowtie2 \
##--local \
##-x ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
##--sensitive-local \
##--threads 8 \
##--no-unal \
##-k 5 \
##-U $fastq \
##-S ${outputdir}mapped/$map_file; \
##done >> ${jobdir}02-bowtieout-redo.txt 2>&1

##cd ${outputdir}mapped/

# Convert sam to bam and sort  
##echo "Convert aligned .sam to .bam" 

##for sample in $redo_samples
##do

#sample="$(basename -a $sam | cut -d "." -f 1)"
##${samtools} view -b $sample.bowtie.sam | ${samtools} sort -o $sample.sorted.bam
##done >> "${jobdir}03-sam2sortedbam-redo.txt" 2>&1

# Deduplicate using picard (within gatk), output will have duplicates removed 

##echo "Deduplicating bams"
##for sample in $redo_samples
##do
#sample="$(basename -a $bam | cut -b 1,2,3)"

##${gatk} MarkDuplicates \
##I=$sample.sorted.bam \
##O="${outputdir}gatk/$sample.dedup.bam" \
##M="${outputdir}gatk/$sample.dup_metrics.txt" \
##REMOVE_DUPLICATES=true
##done >> "${jobdir}04-dedup_stout-redo.txt" 2>&1

# Move to gatk directory and execute gatk tools 
cd ${outputdir}gatk/

# Split reads spanning splicing events 
##echo "Splitting reads spanning splice junctions (SplitNCigarReads)"
##for sample in $redo_samples
##do
#sample="$(basename -a $file | cut -b 1,2,3)"

# split CigarN reads
##${gatk} SplitNCigarReads \
##-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
##-I $sample.dedup.bam \
##-O $sample.dedup-split.bam
##done >> "${jobdir}06-CigarNSplit_stout-redo.txt" 2>&1

# Add read group ID to bams (needed by gatk)
##echo "Adding read group to bams" 
##for sample in $redo_samples
##do
#sample="$(basename -a $file | cut -b 1,2,3)"

# add read group info to headers, specifying sample names 
##${gatk} AddOrReplaceReadGroups \
##I=$sample.dedup-split.bam \
##O=$sample.dedup-split-RG.bam \
##RGID=1 \
##RGLB=$sample \
##RGPL=ILLUMINA \
##RGPU=unit1 \
##RGSM=$sample
##done >> "${jobdir}07-AddReadGroup_stout-redo.txt" 2>&1

# Index the final .bam files (that have been deduplicated, split, read-group added)
##echo "Indexing variant-call ready .bam files"
##for sample in $redo_samples
##do
##${samtools} index $sample.dedup-split-RG.bam 
##done >> "${jobdir}08-index-bams-redo.txt" 2>&1

# Call variants 
##echo "Calling variants using HaplotypeCaller"
##for sample in $redo_samples
##do
#sample="$(basename -a $file | cut -b 1,2,3)"

##${gatk} HaplotypeCaller \
##-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
##-I $sample.dedup-split-RG.bam \
##-O $sample.variants.g.vcf \
##-ERC GVCF
##done >> "${jobdir}09-HaplotypeCaller_stout-redo.txt" 2>&1

# create sample map of all gvcfs
rm sample_map.txt
echo "Creating sample map of all gvcfs"
for file in *variants.g.vcf
do
sample="$(echo $file | sed 's/\..*//')"
echo -e "$sample\t$file" >> sample_map.txt
done

# create interval list (just a list of all contigs in genome)
echo "Creating intervals list"
awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa.fai > intervals.bed 

# Aggregate single-sample GVCFs into GenomicsDB
# Note: the intervals file requires a specific name - e.g. for .bed format, it MUST be "intervals.bed"
echo "Aggregating single-sample GVCFs into GenomicsDB"
rm -r GenomicsDB/ #can't already have a GenomicsDB directory, else will fail 
${gatk} GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB/ \
-L intervals.bed \
--sample-name-map sample_map.txt \
--reader-threads 40 >> "${jobdir}10-GenomicsDBImport_stout.txt" 2>&1

# Joint genotype 
echo "Joint genotyping"
${gatk} GenotypeGVCFs \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V gendb://GenomicsDB \
-O Olurida_QuantSeq2020_genotypes.vcf.gz \
>> "${jobdir}11-GenotypeGVCFs_stout.txt" 2>&1

# Hard filter variants 
echo "Hard filtering variants"
${gatk} VariantFiltration \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes.vcf.gz \
-O Olurida_QuantSeq2020_genotypes-filtered.vcf.gz \
--filter-name "FS" \
--filter "FS > 60.0" \
--filter-name "QD" \
--filter "QD < 2.0" \
--filter-name "QUAL30" \
--filter "QUAL < 30.0" \
--filter-name "SOR3" \
--filter "SOR > 3.0" \
--filter-name "DP15" \
--filter "DP < 15" \
--filter-name "DP150" \
--filter "DP > 150" \
--filter-name "AF30" \
--filter "AF < 0.30" >> "${jobdir}12-HardFiltering_stout.txt" 2>&1

# Select only SNPs that pass filtering
echo "Selecting SNPs that pass fitering"
${gatk} SelectVariants \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-filtered.vcf.gz \
--exclude-filtered TRUE \
--select-type-to-include SNP \
-O Olurida_QuantSeq2020_genotypes-filtered-true.vcf.gz \
 >> "${jobdir}13-SelectVariants_stout.txt" 2>&1

echo "complete!"