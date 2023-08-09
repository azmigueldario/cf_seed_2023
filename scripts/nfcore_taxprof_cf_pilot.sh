#!/bin/bash                                 
#SBATCH --mem-per-cpu=11G                 
#SBATCH --ntasks=1
#SBATCH --time=01:30:00                             
#SBATCH --cpus-per-task=10                         
#SBATCH --job-name="taxprof_pipeline_cf"            
#SBATCH --chdir=/scratch/mdprieto/                  
#SBATCH --output=./jobs_output/taxprof_cf_cfseed.out      

###################################  setup  #######################################################

# load modules
module load singularity nextflow

# ENV variables
SAMPLE_SHEET_CF="/project/60006/mdprieto/cf_seed_2023/processed_data/pilot_taxprof.csv"
DB_CSV="/project/60006/mdprieto/cf_seed_2023/processed_data/databases_taxprof.csv"
HUMAN_REFGENOME="/mnt/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40"


################################### pipeline ###########################################

nextflow run nf-core/taxprofiler -r 1.0.1 \
    -profile singularity \
    -resume \
    --input  $SAMPLE_SHEET_CF \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/results/cf_seed/taxprof_cf \
    --perform_shortread_qc \
    --perform_shortread_complexityfilter \
    --perform_shortread_hostremoval \
    --hostremoval_reference $HUMAN_REFGENOME \
    --shortread_hostremoval_index /project/cidgoh-object-storage/database/bowtie_GRCh38 \
    --run_bracken \
    --run_kraken2 \
    --max_cpus 10 \
    --max_memory 105GB