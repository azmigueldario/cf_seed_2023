## Nextflow

If necessary to prepare all dependencies for nf-core pipeline

```sh
nf-core download fetchngs \
    --container singularity \
    --outdir "/scratch/mdprieto/nfcore-fetchngs-1.9" \
    --singularity-cache-only
```

Quick job submission

```sh
#!/bin/bash                                 
#SBATCH --mem-per-cpu=11G                  
#SBATCH --time=01:30:00                     
#SBATCH --cpus-per-task=10                  
#SBATCH --job-name="duplicate_bracken_database"     
#SBATCH --chdir=/scratch/mdprieto/          
#SBATCH --output=jobs_output/quick_job.out       

cp /project/cidgoh-object-storage/database/kraken2/k2_standard_20221209.tar.gz /project/cidgoh-object-storage/database/bracken/bracken_k2_s_20221209.tar.gz

```