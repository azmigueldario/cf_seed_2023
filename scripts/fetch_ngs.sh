#!/bin/bash                                 
#SBATCH --mem-per-cpu=6G                    # GB of memory per cpu core - max 120GBper node
#SBATCH --time=04:30:00                     # walltime
#SBATCH --cpus-per-task=4                   # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="sra_download"           # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/          # change directory before executing optional)
#SBATCH --output=cfseed_download_data.out       # output_file specification (optional)

######################################################################################################

# load necessary modules
module load singularity nextflow

# ENV variables
NCFB_ACC="/project/60005/mdprieto/cf_seed_2023/ncbi_accessions/ncfb_PRJNA590225.csv"
CF_ACC="/project/60005/mdprieto/cf_seed_2023/ncbi_accessions/cf_PRJNA516870.csv"
DATA_DIR="/project/60005/mdprieto/cf_seed_2023/raw_data"

# download NCFB
nextflow run nf-core/fetchngs -r 1.9 \
    --input "$NCFB_ACC" \
    -profile singularity \
    -resume \
    --outdir $DATA_DIR/ncfb_data

# download CF
nextflow run nf-core/fetchngs -r 1.9 \
    --input "$CF_ACC" \
    -profile singularity \
    -resume \
    --outdir $DATA_DIR/cf_data