#!/bin/bash                                 # she bang
#SBATCH --mem-per-cpu=6G                    # GB of memory per cpu core - max 120GBper node
#SBATCH --time=00:10:00                     # walltime
#SBATCH --cpus-per-task=4                   # CPU cores per task (multithread) - Max 8 
#SBATCH --job-name="sra_download"           # job_name (optional)
#SBATCH --chdir=/scratch/mdprieto/          # change directory before executing optional)
#SBATCH --output=giardia_download_data.out       # output_file specification (optional)

######################################################################################################
# load singularity
module load singularity

# path to SRA_tools container
SRA_IMG="/project/60005/cidgoh_share/singularity_imgs/sra-tools_3.0.0.sif"