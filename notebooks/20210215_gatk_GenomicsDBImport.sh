#!/bin/bash
## Job Name
#SBATCH --job-name=QuantSeq-gatk-GenomicsDBImport
## Allocation Definition 
#SBATCH --account=srlab
#SBATCH --partition=srlab
## Resources
## Nodes 
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=6-00:00:00
## Memory per node
#SBATCH --mem=100G
##turn on e-mail notification
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lhs3@uw.edu
## Specify the working directory for this job
#SBATCH --chdir=/gscratch/srlab/lhs3/inputs/20210215_gatk/

# This script Import single-sample GVCFs into GenomicsDB before joint genotyping in gatk
# All necesasry files are in the same directory. 

! /gscratch/srlab/programs/gatk-4.1.9.0/gatk GenomicsDBImport \
--genomicsdb-workspace-path GenomicsDB/ \
-L intervals_list.bed \
--sample-name-map sample_map.txt \
--reader-threads 40