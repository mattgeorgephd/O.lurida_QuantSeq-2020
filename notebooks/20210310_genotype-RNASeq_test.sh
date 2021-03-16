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
#SBATCH --chdir=/gscratch/srlab/lhs3/jobs/20210310_QuantSeq-Genotype/

# Set program paths 
bowtie2="/gscratch/srlab/programs/bowtie2-2.1.0/"
gatk="/gscratch/srlab/programs/gatk-4.1.9.0/gatk"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

# Here are various important paths
# trimmed QuantSeq fastq files: /gscratch/srlab/lhs3/data/QuantSeq2020
# O.lurida genome: /gscratch/srlab/lhs3/data/Olurida_QuantSeq2020-trimmed/
# Aligned QuantSeq reads: /gscratch/srlab/lhs3/jobs/20210310_QuantSeq-Genotype/mapped/
# gatk files:  /gscratch/srlab/lhs3/jobs/20210310_QuantSeq-Genotype/gatk/

homedir="/gscratch/srlab/lhs3/"

# Move to gatk directory and execute gatk tools 
cd ${homedir}jobs/20210310_QuantSeq-Genotype/gatk/

# create interval list (just a list of all contigs in genome)
echo "Creating intervals list"
awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' ${homedir}data/Olurida_v081_concat_rehead.fa.fai > intervals.bed 

# Aggregate single-sample GVCFs into GenomicsDB
# Note: the intervals file requires a specific name - e.g. for .bed format, it MUST be "intervals.bed"
echo "Aggregating single-sample GVCFs into GenomicsDB"
${gatk} GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB/ \
-L intervals.bed \
--sample-name-map sample_map.txt \
--reader-threads 40

# Joint genotype 
echo "Joint genotyping"
${gatk} GenotypeGVCFs \
-R ${homedir}data/Olurida_v081_concat_rehead.fa \
-V gendb://GenomicsDB \
-O Olurida_QuantSeq2020_genotypes.vcf.gz

# Hard filter variants 
echo "Hard filtering variants"
${gatk} VariantFiltration \
-R ${homedir}data/Olurida_v081_concat_rehead.fa \
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
--filter "AF < 0.30"

# Select only SNPs that pass filtering
echo "Selecting SNPs that pass fitering"
${gatk} SelectVariants \
-R ${homedir}data/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-filtered.vcf.gz \
--exclude-filtered TRUE \
--select-type-to-include SNP \
-O Olurida_QuantSeq2020_genotypes-filtered-true.vcf.gz

echo "complete!"