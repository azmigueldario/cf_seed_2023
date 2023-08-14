# Useful snippets

## Prepare nf-core pipeline dependencies

```sh
nf-core download fetchngs \
    --container singularity \
    --outdir "/scratch/mdprieto/nfcore-fetchngs-1.9" \
    --singularity-cache-only
```

## Quick job submission

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

## Create sample sheet for taxprofiler pipeline

```sh
<<'MODEL_DATA'
sample,run_accession,instrument_platform,fastq_1,fastq_2,fasta
2612,run1,ILLUMINA,2612_run1_R1.fq.gz,,
2612,run2,ILLUMINA,2612_run2_R1.fq.gz,,
2612,run3,ILLUMINA,2612_run3_R1.fq.gz,2612_run3_R2.fq.gz,
MODEL_DATA

###### NCFB #####
    # add headers
echo "sample,run_accession,instrument_platform,fastq_1,fastq_2,fasta" > full_taxprof_ncfb.csv
    # define iteration index
ITER=0
    # for loop to add variables    
for read1 in $(ls /project/60006/mdprieto/raw_data/cf_seed/ncfb_data/fastq/*_1.fastq.gz);
    do 
        # add one to iteration index
    ((ITER++)) 
        # create sample name index, printf defines leading zeroes
    sample="NCFB_$(printf "%03d" $ITER)"
        # get the basename of file and remove suffix 
    sample_acc=$(echo $read1 | xargs -n 1 basename -s '_1.fastq.gz')
        # replace string '_1' for '_2'
    read2="${read1/_1/_2}"
        # write in a new line for each sample
    echo $sample,$sample_acc,ILLUMINA,$read1,$read2, >> full_taxprof_ncfb.csv
    done

###### CF ##### 
    # add headers
echo "sample,run_accession,instrument_platform,fastq_1,fastq_2,fasta" > full_taxprof_cf.csv
    # define iteration index
ITER=0
    # for loop to add variables    
for read1 in $(ls /project/60006/mdprieto/raw_data/cf_seed/cf_data/fastq/*_1.fastq.gz);
    do 
        # add one to iteration index
    ((ITER++)) 
        # create sample name index, printf defines leading zeroes
    sample="CF_$(printf "%02d" $ITER)"
        # get the basename of file and remove suffix
    sample_acc=$(echo $read1 | xargs -n 1 basename -s '_1.fastq.gz')
        # replace string '_1' for '_2'
    read2="${read1/_1/_2}"
        # write in a new line for each sample
    echo $sample,$sample_acc,ILLUMINA,$read1,$read2, >> full_taxprof_cf.csv
    done
    
```

```sh
K2DB="~/scratch/nf_work_cache/1c/454b04c702bc27a015c9b5a9611d02"
```
