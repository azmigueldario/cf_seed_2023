# Analysis of taxonomic abundance and diversity in lung microbiome

## Objectives

- Separate datasets into samples with _Pseduomonas_ spp. predominance or not
- Define if predominance of  _Pseduomonas_ spp. in the microbiome of patients with Cystic Fibrosis(CF) and Non-Cystic fibrosis bronchiectasis (NCFB) affects the measures of diversity

## Command line: preparation of files

The structure of the project repository is described below. All paths are relative to the `/script` folder where this script is located. The /processed_data folder contains all required data for downstream analysis.

```sh
cf_seed_2023
├── notebook
├── processed_data
│   └── accessions
├── results
│   ├── tax_cf
│   └── tax_ncfb
└── scripts
```

After obtaining taxonomy classification using **nf-core** `taxprofiler_1.0.1` and `kraken2/bracken`, I use `taxpasta_v0.4.1` to produce **biom** files necessary for analysis using `Phyloseq` in `R`.

```sh
    # move files to results
rsync -av --exclude "centrifuge" . ~/mdprieto_projects/cf_seed_2023/results
find . -type d -not -iname "centrifuge" -exec cp -r '{}' '~/mdprieto_projects/cf_seed_2023/results{}' ';'


  # taxpasta container is part of taxprofiler pipeline
TAXPASTA_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-taxpasta-0.4.1--pyhdfd78af_0.img"

    # Create a .biom file for downstream analysis in R
        # must call all available bracken output for CF/NCFB
        # summarize at genus to facilitate downstream analysis
singularity exec $TAXPASTA_IMG taxpasta merge \
    --profiler bracken \
    --output bracken_cf.biom \
    --summarise-at genus \
    --output-format BIOM \
    --taxonomy /mnt/cidgoh-object-storage/database/kraken2/taxdump \
    --add-name \
    --add-rank \
    /scratch/mdprieto/results/cf_seed/taxprof_cf/bracken/k2_db/CF_*
    
    # Repeat for NCFB data
singularity exec $TAXPASTA_IMG taxpasta merge \
    --profiler bracken \
    --output bracken_ncfb.biom \
    --summarise-at genus \
    --output-format BIOM \
    --taxonomy /mnt/cidgoh-object-storage/database/kraken2/taxdump \
    --add-name \
    --add-rank \
    /scratch/mdprieto/results/cf_seed/taxprof_ncfb/bracken/k2_db/NCFB_*

####################################################################################

    # define PATH to singularity container
TAXPASTA_IMG="/mnt/cidgoh-object-storage/images/depot.galaxyproject.org-singularity-taxpasta-0.4.1--pyhdfd78af_0.img"

    # Create a .biom file for downstream analysis in R
        # must call all available bracken output for CF/NCFB
        # summarize at genus to facilitate downstream analysis
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
