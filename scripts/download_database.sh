#!/bin/bash                                
#SBATCH --mem-per-cpu=8G                    # GB of memory per cpu core - max 120GBper node
#SBATCH --time=00:30:00                     # walltime
#SBATCH --cpus-per-task=1                   # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="bowtie2_download"           # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/          # change directory before executing optional)
#SBATCH --output=./jobs_output/bowtie_index_download.out       # output_file specification (optional)

######################################################################################################

wget https://genome-idx.s3.amazonaws.com/bt/GRCh38_noalt_as.zip

unzip GRCh38_noalt_as.zip

mv GRCh38_noalt_as.zip /project/cidgoh-object-storage/database/bowtie_human_index