#!/bin/bash                                 
#SBATCH --mem-per-cpu=6G
#SBATCH --time=24:30:00                             
#SBATCH --cpus-per-task=2                         
#SBATCH --job-name="ncfb_full_taxprof"            
#SBATCH --chdir=/scratch/mdprieto/                  
#SBATCH --output=jobs_output/%x_%j.out  

###################################  setup  #######################################################

# load modules
module load apptainer nextflow

# ENV variables
SAMPLE_SHEET_NCFB="/project/60006/mdprieto/cf_seed_2023/processed_data/samplesheets/taxprof_ncfb.csv" `#make sure to use NCFB sample sheet`
DB_CSV="/project/60006/mdprieto/cf_seed_2023/processed_data/samplesheets/db_taxprof.csv"
HUMAN_REFGENOME="/mnt/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40"
EAGLE_CONFIG="/project/60006/mdprieto/cf_seed_2023/scripts/eagle.config"

################################### pipeline ###########################################

nextflow run nf-core/taxprofiler -r 1.0.1 \
    -profile singularity \
    -resume \
    -c $EAGLE_CONFIG \
    -work-dir /project/60006/mdprieto/nf_work_project \
    --input  $SAMPLE_SHEET_NCFB \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/results/cf_seed/taxprof_ncfb \
    --perform_shortread_qc \
    --perform_shortread_complexityfilter \
    --perform_shortread_hostremoval \
    --hostremoval_reference $HUMAN_REFGENOME \
    --shortread_hostremoval_index $HUMAN_REFGENOME \
    --run_bracken \
    --run_kraken2 \
    --run_centrifuge \
    --run_profile_standardisation 
    