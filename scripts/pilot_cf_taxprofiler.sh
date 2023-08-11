#!/bin/bash                                 
#SBATCH --mem-per-cpu=6G                 
#SBATCH --ntasks=1
#SBATCH --time=06:30:00                             
#SBATCH --cpus-per-task=2                         
#SBATCH --job-name="pilot_slurm_taxprof_cf"            
#SBATCH --chdir=/scratch/mdprieto/                  
#SBATCH --output=jobs_output/%x_%j.out  

###################################  setup  #######################################################

# load modules
module load apptainer nextflow

# ENV variables
SAMPLE_SHEET_CF="/project/60006/mdprieto/cf_seed_2023/processed_data/pilot_taxprof.csv"
DB_CSV="/project/60006/mdprieto/cf_seed_2023/processed_data/databases_taxprof.csv"
HUMAN_REFGENOME="/mnt/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40"
CUSTOM_CONFIG="/project/60006/mdprieto/cf_seed_2023/scripts/eagle.config"

################################### pipeline ###########################################

nextflow run nf-core/taxprofiler -r 1.0.1 \
    -profile singularity \
    -resume \
    -c $CUSTOM_CONFIG \
    -work-dir /project/60006/mdprieto/nf_work_project \
    --input  $SAMPLE_SHEET_CF \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/results/cf_seed/taxprof_cf \
    --perform_shortread_qc \
    --perform_shortread_complexityfilter \
    --perform_shortread_hostremoval \
    --hostremoval_reference $HUMAN_REFGENOME \
    --shortread_hostremoval_index $HUMAN_REFGENOME \
    --run_bracken \
    --run_kraken2 \
    --run_centrifuge \
    --run_profile_standardisation 
    
    