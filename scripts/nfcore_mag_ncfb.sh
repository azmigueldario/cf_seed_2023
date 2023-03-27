#!/bin/bash                                 
#SBATCH --mem-per-cpu=10G                           # GB of memory per cpu core - max 120GBper node
#SBATCH --time=04:30:00                             # walltime
#SBATCH --cpus-per-task=8                           # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="mag_pipeline_ncfb"              # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/                  # change directory before executing optional)
#SBATCH --output=./jobs_output/cfseed_ncfb_mag.out      

######################################################################################################

# load modules
module load singularity nextflow

# ENV variables
NCFB_FASTQ="/project/60005/mdprieto/cf_seed_2023/raw_data/ncfb_data/fastq"
KRAKEN2_DB="/home/mdprieto/object_database/kraken2/k2_standard_20221209.tar.gz"


# pipeline

nextflow run nf-core/mag -r 2.3.0 \
    -profile singularity \
    -resume \
    --input "$NCFB_FASTQ/SRX*_{1,2}.fastq.gz" \
    --outdir /scratch/mdprieto/cf_seed_results/nf-mag \
    --host_genome GRCh38 \
    --kraken2_db $KRAKEN2_DB \
    --skip_prodigal \
    --skip_prokka \
    --skip_krona \
    --skip_spades \
    --skip_megahit \
    --skip_binning \
    --max_memory 77GB \
    --max_cpus 8