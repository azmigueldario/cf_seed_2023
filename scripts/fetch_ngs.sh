#!/bin/bash                                 # she bang
#SBATCH --mem-per-cpu=6G                    # GB of memory per cpu core - max 120GBper node
#SBATCH --time=00:10:00                     # walltime
#SBATCH --cpus-per-task=4                   # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="sra_download"           # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/          # change directory before executing optional)
#SBATCH --output=giardia_download_data.out       # output_file specification (optional)

######################################################################################################

# load necessary modules
module load singularity nextflow

# path to SRA_tools container
SRA_IMG="/project/60005/cidgoh_share/singularity_imgs/sra-tools_3.0.0.sif"
# path to accession list
ACC_LIST="/project/60005/mdprieto/cf_seed_2023/ncbi_accessions/trial_accessions.csv"

# if necessary to prepare all dependencies
nf-core download fetchngs \
    --container singularity \
    --outdir "/scratch/mdprieto/nfcore-fetchngs-1.9" \
    --singularity-cache-only

# test run from nf-core
nextflow run nf-core/fetchngs \
    -profile test,singularity \
    --outdir /project/60005/mdprieto/cf_seed_2023/raw_data

# test run with my data
nextflow run nf-core/fetchngs -r 1.9 \
    --input "$ACC_LIST" \
    -profile singularity \
    --outdir /project/60005/mdprieto/cf_seed_2023/raw_data