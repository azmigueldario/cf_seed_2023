#!/bin/bash                                 
#SBATCH --mem-per-cpu=10G                           # GB of memory per cpu core - max 120GBper node
#SBATCH --time=12:30:00                             # walltime
#SBATCH --cpus-per-task=10                           # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="taxprof_pipeline_ncfb"              # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/                  # change directory before executing optional)
#SBATCH --output=./jobs_output/cfseed_taxprof_ncfb.out      

######################################################################################################

# load modules
module load singularity nextflow

# ENV variables

KRAKEN2_DB="/home/mdprieto/object_database/kraken2/k2_standard_20221209.tar.gz"
SAMPLE_SHEET="/project/60005/mdprieto/cf_seed_2023/scripts/samplesheet_taxprof.csv"
DB_CSV="/project/60005/mdprieto/cf_seed_2023/scripts/databases_taxprof.csv"


# pipeline

nextflow run nf-core/taxprofiler -r 1.0.0 \
    -profile singularity \
    -resume \
    --input $SAMPLE_SHEET \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/cf_seed_results/taxprof \
    --perform_shortread_qc \
    --perform_shortread_hostremoval \
    --hostremoval_reference /project/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna \
    --shortread_hostremoval_index /project/cidgoh-object-storage/database/bowtie_GRCh38 \
    --run_bracken \
    --run_kraken2 \
    --max_cpus 10 \
    --max_memory 95GB