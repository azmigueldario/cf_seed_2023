# Analysis of taxonomic abundance and diversity in lung microbiome

## Objectives

- Separate datasets into samples with _Pseduomonas_ spp. predominance or not
- Define if predominance of  _Pseduomonas_ spp. in the microbiome of patients with Cystic Fibrosis(CF) and Non-Cystic fibrosis bronchiectasis (NCFB) affects the measures of diversity

## Preparation of files for downstream analysis in R

In the command line, we used a pipeline that produced estimates of abundance with Kraken/Bracken. These reports were concatenated according to pathology and need to be transformed into a **.biom** file for analysis using `Phyloseq` in `R`.

**Sample_69:SRX5286995_SRR8482121** has less than 10 species identified, and was flagged due to highly over-represented sequences in the initial `Fastqc` analysis

```sh
    # move files to results
rsync -av --exclude "centrifuge" . ~/mdprieto_projects/cf_seed_2023/results
find . -type d -not -iname "centrifuge" -exec cp -r '{}' '~/mdprieto_projects/cf_seed_2023/results{}' ';'


    # taxpasta container is part of taxprofiler pipeline
TAXPASTA_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-taxpasta-0.4.1--pyhdfd78af_0.img"

    # produce a .biom file for downstream analysis in R
singularity exec $TAXPASTA_IMG taxpasta merge \
    --profiler bracken \
    --output ../processed_data/bracken_cf.tsv \
    --summarise-at genus \
    --taxonomy /mnt/cidgoh-object-storage/database/kraken2/taxdump \
    --add-name \
    --add-rank \
    /scratch/mdprieto/results/cf_seed/taxprof_cf/bracken/k2_db/CF_*
```

```sh
    # Download singularity image of kraken-biom tool if necessary 
# singularity pull $$NXF_SINGULARITY_CACHEDIR/kraken-biom_1.2.0.sif https://depot.galaxyproject.org/singularity/kraken-biom%3A1.2.0--pyh5e36f6f_0

    # command to create biom file
singularity exec /mnt/cidgoh-object-storage/images/kraken-biom_1.2.0.sif kraken-biom \
    -k ../results/bracken_cf_combined.txt \
    --max S \
    -o /project/60006/mdprieto/cf_seed_2023/processed_data/bracken_cf.biom

    # loading R and dependencies
module load StdEnv/2020 gcc/9.3.0 r/4.3.1
```


