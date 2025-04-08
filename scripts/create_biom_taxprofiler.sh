#!/bin/bash                                 
#SBATCH --mem-per-cpu=8G
#SBATCH --time=01:30:00                             
#SBATCH --cpus-per-task=8                         
#SBATCH --job-name="create_biom"            
#SBATCH --chdir=/scratch/mdprieto/                  
#SBATCH --output=jobs_output/%x_%j.out  

###################################  setup  ############################################

# load modules
module load apptainer 

# SINGULARITY IMAGES
BRACKEN_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-bracken-2.7--py39hc16433a_0.img"
TAXPASTA_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-taxpasta-0.4.1--pyhdfd78af_0.img"

# CF input and output
CF_IN="/scratch/mdprieto/results/cf_seed/taxprof_cf/kraken2/k2_db/*"
CF_OUT="/scratch/mdprieto/results/cf_seed/taxprof_cf/bracken/k2_reports/"

# NCFB input and output
NCFB_IN="/scratch/mdprieto/results/cf_seed/taxprof_ncfb/kraken2/k2_db/*"
NCFB_OUT="/scratch/mdprieto/results/cf_seed/taxprof_ncfb/bracken/k2_reports/"

################################### pipeline ###########################################

####### Bracken to produce kraken style reports for both diseases

    # CF      
for report in $(ls $CF_IN)
    do
        # define naming prefix based on sample_id
    SAMPLE=$(basename $report | sed -E 's/_SRX.*//')
        # run bracken specifying -w for kraken_style report output
        # read_length of 100 (-r 100) and summarize at genus level (-l G)
    echo singularity exec $BRACKEN_IMG bracken \
        -d /mnt/cidgoh-object-storage/database/kraken2 \
        -i $report \
        -o $CF_OUT/${SAMPLE}_to_delete \
        -w $CF_OUT/${SAMPLE}_report.txt \
        -r 100 \
        -l G \
        -t 10
        # remove unnecessary files
    rm $CF_OUT/*_to_delete
    done

    # CF      
for report in $(ls $NCFB_IN)
    do
    SAMPLE=$(basename $report | sed -E 's/_SRX.*//')
    echo singularity exec $BRACKEN_IMG bracken \
        -d /mnt/cidgoh-object-storage/database/kraken2 \
        -i $report \
        -o $NCFB_OUT/${SAMPLE}_to_delete \
        -w $NCFB_OUT/${SAMPLE}_report.txt \
        -r 100 \
        -l G \
        -t 10
        # remove unnecessary files
    rm $NCFB_OUT/*_to_delete
    done

####### Use taxpasta tool to create biom file

    # CF
echo singularity exec $TAXPASTA_IMG taxpasta merge \
    --profiler bracken \
    --output ncfb_taxpasta.biom \
    --summarise-at genus \
    --output-format biom \
    --taxonomy /mnt/cidgoh-object-storage/database/kraken2/taxdump \
    --add-lineage \
    $CF_OUT/*
    echo
    echo
    done