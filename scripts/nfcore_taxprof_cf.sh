#!/bin/bash                                 
#SBATCH --mem-per-cpu=11G                 
#SBATCH --ntasks=2
#SBATCH --nodes=2
#SBATCH --time=01:30:00                             
#SBATCH --cpus-per-task=10                         
#SBATCH --job-name="taxprof_pipeline_cf"            
#SBATCH --chdir=/scratch/mdprieto/                  
#SBATCH --output=./jobs_output/taxprof_cf_cfseed.out      

######################################################################################################

# load modules
module load singularity nextflow

# ENV variables

SAMPLE_SHEET_CF="/project/60005/mdprieto/cf_seed_2023/scripts/samplesheet_taxprof_cf.csv"
DB_CSV="/project/60005/mdprieto/cf_seed_2023/scripts/databases_taxprof.csv"


# pipeline

nextflow run nf-core/taxprofiler -r 1.0.0 \
    -profile singularity \
    -resume \
    --input $SAMPLE_SHEET_CF \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/cf_seed_results/taxprof_cf \
    --perform_shortread_qc \
    --perform_shortread_hostremoval \
    --hostremoval_reference /project/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna \
    --shortread_hostremoval_index /project/cidgoh-object-storage/database/bowtie_GRCh38 \
    --run_bracken \
    --run_kraken2 \
    --max_cpus 10 \
    --max_memory 110GB