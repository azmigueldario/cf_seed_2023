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

## Creating an appropriate .biom file

First, we create kraken style reports in bracken as a requisite for the `kraken-biom` tool

```sh
# apply to both diseases
for disease in {cf,ncfb}
    do
    # nested for loop to apply bracken to every file in the corresponding disease path
    for report in $(ls /scratch/mdprieto/results/cf_seed/taxprof_${disease}/kraken2/k2_db/*)
        do
            # define naming prefix based on sample_id
        SAMPLE=$(basename $report | sed -E 's/_SRX.*//')
            # run bracken specifying 
        singularity exec /mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-bracken-2.7--py39hc16433a_0.img bracken \
            -d /mnt/cidgoh-object-storage/database/kraken2 \
            -i $report \
            -o /scratch/mdprieto/results/cf_seed/taxprof_${disease}/bracken/k2_reports/${SAMPLE}_to_delete \
            -w /scratch/mdprieto/results/cf_seed/taxprof_${disease}/bracken/k2_reports/${SAMPLE}_report.txt \
            -r 100 \
            -l G \
            -t 10
        done
    done

# delete unnecessary output
rm /scratch/mdprieto/results/cf_seed/taxprof_{cf,ncfb}/bracken/k2_reports/*_to_delete
```

We now use `kraken-biom v1.2.0` to produce **.biom** files to export in r

```sh
cd /project/60006/mdprieto/cf_seed_2023/processed_data
for disease in {cf,ncfb}
    do 
    singularity exec /mnt/cidgoh-object-storage/images/kraken-biom_1.2.0.sif kraken-biom \
        --fmt json \
        --min G \
        -o ${disease}_bracken.biom \
        /scratch/mdprieto/results/cf_seed/taxprof_${disease}/bracken/k2_reports/* 

    done

    # Biom no added name/rank data
TAXPASTA_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-taxpasta-0.4.1--pyhdfd78af_0.img"
for disease in {cf,ncfb}
    do 
    singularity exec $TAXPASTA_IMG taxpasta merge \
        --profiler bracken \
        --output ${disease}_taxpasta.biom \
        --summarise-at genus \
        --output-format biom \
        --taxonomy /mnt/cidgoh-object-storage/database/kraken2/taxdump \
        --add-lineage \
        /scratch/mdprieto/results/cf_seed/taxprof_${disease}/bracken/k2_db/*
    done

```

## Troubleshoot poor de-hosting in NCFB samples

May be due to unspecified reference genome the step was missed

```sh
# ENV variables
SAMPLE_SHEET_NCFB="/project/60006/mdprieto/cf_seed_2023/processed_data/samplesheets/pilot_taxprof.csv"
DB_CSV="/project/60006/mdprieto/cf_seed_2023/processed_data/samplesheets/db_taxprof.csv"
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
    --run_bracken \
    --run_kraken2 \
    --run_centrifuge \
    --run_profile_standardisation \
    --save_hostremoval_index
    
    
    #bowtie index
02/4c0c2913266400ce138f010bbf9516
```
