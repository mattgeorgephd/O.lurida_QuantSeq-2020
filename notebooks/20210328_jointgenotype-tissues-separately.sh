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
#SBATCH --chdir=/gscratch/srlab/lhs3/jobs/20210328_Olurida_QuantSeq/

# Set program paths 
gatk="/gscratch/srlab/programs/gatk-4.1.9.0/gatk"
samtools="/gscratch/srlab/programs/samtools-1.10/samtools"

# Here are various important paths
# trimmed QuantSeq fastq files: /gscratch/srlab/lhs3/data/QuantSeq2020
# O.lurida genome: /gscratch/srlab/lhs3/data/Olurida_QuantSeq2020-trimmed/
# Aligned QuantSeq reads: /gscratch/scrubbed/lhs3/20210314_Olurida_QuantSeq-Genotype-all/mapped/
# gatk files:  /gscratch/scrubbed/lhs3/20210314_Olurida_QuantSeq-Genotype-all/gatk/

homedir="/gscratch/srlab/lhs3/"
jobdir="/gscratch/srlab/lhs3/jobs/20210328_Olurida_QuantSeq/"
outputdir="/gscratch/scrubbed/lhs3/20210314_Olurida_QuantSeq-Genotype-all/"

cd ${outputdir}gatk/

######################### ADULTS ##########################

# Aggregate single-sample GVCFs into GenomicsDB
# Note: the intervals file requires a specific name - e.g. for .bed format, it MUST be "intervals.bed"
echo "ADULTS: aggregating single-sample GVCFs into GenomicsDB"
rm -r GenomicsDB-adult/ #can't already have a GenomicsDB directory, else will fail 
${gatk} GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB-adult/ \
-L intervals.bed \
--sample-name-map sample_map-adult.txt \
--reader-threads 40 >> "${jobdir}10-GenomicsDBImport-adult_stout.txt" 2>&1

# Joint genotype 
echo "ADULTS: joint genotyping"
${gatk} GenotypeGVCFs \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V gendb://GenomicsDB-adult \
-O Olurida_QuantSeq2020_genotypes-adult.vcf.gz \
>> "${jobdir}11-GenotypeGVCFs-adult_stout.txt" 2>&1

# Hard filter variants 
echo "ADULTS: hard filtering variants"
${gatk} VariantFiltration \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-adult.vcf.gz \
-O Olurida_QuantSeq2020_genotypes-adult-filtered.vcf.gz \
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
--filter "AF < 0.30" >> "${jobdir}12-GenotypeGVCFs-adult_stout.txt" 2>&1

# Select only SNPs that pass filtering
echo "ADULTS: selecting SNPs that pass fitering"
${gatk} SelectVariants \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-adult-filtered.vcf.gz \
--exclude-filtered TRUE \
--select-type-to-include SNP \
-O Olurida_QuantSeq2020_genotypes-adult-filtered-true.vcf.gz \
 >> "${jobdir}13-SelectVariants-adult_stout.txt" 2>&1

echo "ADULT joint genotyping complete!"

######################### LARVAE ##########################

# Aggregate single-sample GVCFs into GenomicsDB
# Note: the intervals file requires a specific name - e.g. for .bed format, it MUST be "intervals.bed"
echo "LARVAE: aggregating single-sample GVCFs into GenomicsDB"
rm -r GenomicsDB-larvae/ #can't already have a GenomicsDB directory, else will fail 
${gatk} GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB-larvae/ \
-L intervals.bed \
--sample-name-map sample_map-larvae.txt \
--reader-threads 40 >> "${jobdir}10-GenomicsDBImport-larvae_stout.txt" 2>&1

# Joint genotype 
echo "LARVAE: joint genotyping"
${gatk} GenotypeGVCFs \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V gendb://GenomicsDB-larvae \
-O Olurida_QuantSeq2020_genotypes-larvae.vcf.gz \
>> "${jobdir}11-GenotypeGVCFs-larvae_stout.txt" 2>&1

# Hard filter variants 
echo "LARVAE: hard filtering variants"
${gatk} VariantFiltration \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-larvae.vcf.gz \
-O Olurida_QuantSeq2020_genotypes-larvae-filtered.vcf.gz \
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
--filter "AF < 0.30" >> "${jobdir}12-GenotypeGVCFs-larvae_stout.txt" 2>&1

# Select only SNPs that pass filtering
echo "LARVAE: selecting SNPs that pass fitering"
${gatk} SelectVariants \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-larvae-filtered.vcf.gz \
--exclude-filtered TRUE \
--select-type-to-include SNP \
-O Olurida_QuantSeq2020_genotypes-larvae-filtered-true.vcf.gz \
 >> "${jobdir}13-SelectVariants-larvae_stout.txt" 2>&1

echo "LARVAE joint genotyping complete!"

######################### JUVENILE ##########################

# Aggregate single-sample GVCFs into GenomicsDB
# Note: the intervals file requires a specific name - e.g. for .bed format, it MUST be "intervals.bed"
echo "JUVENILE: aggregating single-sample GVCFs into GenomicsDB"
rm -r GenomicsDB-juvenile/ #can't already have a GenomicsDB directory, else will fail 
${gatk} GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB-juvenile/ \
-L intervals.bed \
--sample-name-map sample_map-juv.txt \
--reader-threads 40 >> "${jobdir}10-GenomicsDBImport-juvenile_stout.txt" 2>&1

# Joint genotype 
echo "JUVENILE: joint genotyping"
${gatk} GenotypeGVCFs \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V gendb://GenomicsDB-juvenile \
-O Olurida_QuantSeq2020_genotypes-juvenile.vcf.gz \
>> "${jobdir}11-GenotypeGVCFs-juvenile_stout.txt" 2>&1

# Hard filter variants 
echo "JUVENILE: hard filtering variants"
${gatk} VariantFiltration \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-juvenile.vcf.gz \
-O Olurida_QuantSeq2020_genotypes-juvenile-filtered.vcf.gz \
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
--filter "AF < 0.30" >> "${jobdir}12-GenotypeGVCFs-juvenile_stout.txt" 2>&1

# Select only SNPs that pass filtering
echo "JUVENILE: selecting SNPs that pass fitering"
${gatk} SelectVariants \
-R ${homedir}data/Olurida_v081_concat/Olurida_v081_concat_rehead.fa \
-V Olurida_QuantSeq2020_genotypes-juvenile-filtered.vcf.gz \
--exclude-filtered TRUE \
--select-type-to-include SNP \
-O Olurida_QuantSeq2020_genotypes-juvenile-filtered-true.vcf.gz \
 >> "${jobdir}13-SelectVariants-juvenile_stout.txt" 2>&1

echo "JUVENILE joint genotyping complete!"