# Metagenomics preliminary analysis for non-Cystic Fibrosis Bronchiectasis (NCFB) project

## Feedback questions, to do afterwards

- Does having a predominance of _Pseudomonas_ spp. reduces the diversity per-se, having only 70% of the sample left for diversity.
  - I can see if other species also have the same effect on diversity; also try to reduce the threshold to see if the effect of predominance is sustained

## General information

### Rationale

- A comparison of results with CF may be helpful to establish feasibility in the CIHR project.
- Christina Thornton will get 20 CF sputum and 20 non-CF bronchiectasis (NCFB) sputum (each group contains 10 with _Pseudomonas_ spp. and 10 without it)  
- What happens in the microbiome. There is a decrease in diversity as CF individuals age that is faster when _Pseudomonas_ spp. is present.  

### Objective

1. To define if predominance of _Pseudomonas_ spp. affects the alpha and beta diversity of the lung microbiome in bronchiectasis
2. To explore if predominance of _Pseudomonas_ spp. modifies the virulence profile of the microbial community

### Repository/folder structure

The project is divided in four main subdirectories and inside a github repository: <https://github.com/azmigueldario/cf_seed_2023>. The **_testing_** branch is mainly for developing purposes and testing in eagle.

- The `README.md` in the base folder describes the final pipeline.
- **notebook:** contains the `markdown notebook` file that documents all the advances and troubleshooting.
- **output:** contains final results from analysis.
- **processed_data:** contains sample-sheets, input datasets, and relevant information to run the pipeline.
  - The _raw data_ is saved outside the repository to prevent accidental sharing.
- **scripts:** contains all analytical scripts and workflows developed for this project

```sh
.
├── notebook
├── processed_data
├── results
└── scripts
```

#### Available datasets

Available projects were searched in the ENA and NCBI repositories (March 17, 2023). Eligibility criteria were shotgun metagenomic studies from the lung in humans for NCFB or CF.

```sh
# search criteria CF 
((cystic fibrosis lung) AND "metagenomic"[Source] ) NOT ("amplicon"[Strategy] OR "rna seq"[Strategy] OR "abi solid"[Platform] OR "bgiseq"[Platform] OR "capillary"[Platform] OR "helicos"[Platform] OR "ls454"[Platform] OR "pcr"[Selection] )
```

##### NCFB

The dataset of the project [PRJNA590225](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA590225) seems to contain actual metagenomic information and not just Amplicon sequencing results. The primary article can be found here: [Mac Aogáin et al. 2021](https://www.nature.com/articles/s41591-021-01289-7).

- Metagenomic data was processed from sputum  
- Sample size of 166 participants in a single time-point - includes a few blank samples (total n = 176)
- Recruited in Singapore, Malaysia, UK and Italy  

No other papers in the ENA or NCBI seem to contain metagenomic data for bronchiectasis by March, 2023.

##### CF

The project [PRJNA516870](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA516870) was selected for analysis. Further data is available in the primary article by [Bacci et al. 2020](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7409339/).

- Samples processed from spontaneous sputum  
- Recruited in three Italian CF centers
- Sample size of 78, represents repetitive data from 26 patients

**Note:** The study PRJEB52317 has a larger sample of CF patients, but the available data seems to lack one of the paired-end reads.

### Environment setup

```sh
################################ Eagle ###########################

# singularity cache dir, set up in `.bashrc` options
NXF_SINGULARITY_CACHEDIR="/project/60005/cidgoh_share/singularity_imgs/"

# directory with scripts for project
SCRIPTS="/project/60005/mdprieto/cf_seed_2023/scripts" 

# interactive 
salloc --time=02:00:00 --ntasks=1 --cpus-per-task=8  --mem-per-cpu=8G 
```

## Notebook of advances

### 20230309

- Downloaded singularity image for the sra toolkit
- Configured tool using `vdb-config -i` and setting a temporary directory to prefetch data in the `/scratch` directory
- Suggestion by Amy: <https://www.bv-brc.org/app/MetagenomicReadMapping>. Helps to map virulence in metagenomes

```sh
SRA_IMG="/project/60005/cidgoh_share/singularity_imgs/sra-tools_3.0.0.sif"
```

### 20230317

- Searched and selected a proper CF dataset for lung shotgun metagenomesq
- Cleaned design of laboratory notebook
- Prepared accession list and metadata files in Github repo
- Created, troubleshooted and ran script to download all raw data files
  - fasterq-dump requires accession as parameter
  - to run multiples accessions by fasterq-sump use `cat accessions | xargs fasterq-dump`

### 20230320

- **SRA tools** is having issues while downloading and it produces a single fastq file instead of two (R1 and R2)
- Unfortunately, it seems like the CF project PRJEB52317 has only a read uploaded in the repositories and failed to make **reads_2** available

#### Downloading data effectively

- Tried using **nf-core** modules to retrieve data
  - Installed using (`pip install nf-core`)
  - Prepared containers and workflow by calling `nf-core download <pipeline_name>` which interactively downloads necessary dependencies and pipeline
  - To keep a centralized container repository and not download in pipeline folder I add the flag `--singularity-cache-only`
  - Accession list must be in `.csv` format  
  - Eliminate empty spaces at the end of accession list, may produce error as input of pipeline
- Download of 10 samples took less than 10 minutes, so I will ask for 3 hours of wall time for the complete dataset (n= 200)

### 20230322 - Exploring nfseqqc pipeline

- Decided to download data for CF and NCFB into separate directories for downstream analysis later on
- Evaluating CIDGOH pipeline for reads qc
- Working, still have to review pertinence of report
- How to calculate diversity from reads, what is the necessary input?

```sh
OUTPUT_QC="/project/60005/mdprieto/cf_seed_2023/results/ngs_qc"
SEQQC_NF="/scratch/mdprieto/nf-seqqc/main.nf"
TRIAL_SHEET="/project/60005/mdprieto/cf_seed_2023/raw_data/ncfb_data/samplesheet/trial_ncfb_samplesheet.csv"

NFCORE_IMG="/project/cidgoh-object-storage/images/nf-core_2.7.2.sif"

export NXF_SINGULARITY_CACHEDIR="/project/cidgoh-object-storage/images"

nextflow run $SEQQC_NF \
    -profile singularity \
    -resume \
    -c eagle \
    --outdir $OUTPUT_QC \
    --input $TRIAL_SHEET \
    --skip_assembly \
    --skip_assembly_qc \
    --skip_confindr \
    --skip_subsampling \
    --max_memory 50GB \
    --max_cpus 8 \
    --fasta /project/cidgoh-object-storage/database/test_fasta/GCF_009858895.2_ASM985889v3_genomic.200409.fna.gz 
```

### 20230326 - Running metagenome analysis on Cedar or Eagle

- **nf-core:MAG** input needs to be on quotes when specifying path 'PATH/FASTQ_FILES'
- Minimum cpu requires for bowtie while de-hosting is 10 by default

```sh
# install dependencies for mag pipeline
singularity exec -B /scratch,/etc $NFCORE_IMG nf-core download mag -r 2.3.0 --singularity-cache-only --container singularity --force

NCFB_FASTQ="/project/60005/mdprieto/cf_seed_2023/raw_data/ncfb_data/fastq"
KRAKEN2_DB="/home/mdprieto/object_database/kraken2/k2_standard_20221209.tar.gz"

# trial with 10 samples
nextflow run nf-core/mag -r 2.3.0 \
    -profile singularity \
    -resume \
    --input "$NCFB_FASTQ/SRX900293*_{1,2}.fastq.gz" \
    --outdir /scratch/mdprieto/cf_seed_results/nf-mag \
    --host_genome GRCh38 \
    --kraken2_db $KRAKEN2_DB \
    --skip_prodigal \
    --skip_prokka \
    --skip_krona \
    --skip_spades \
    --skip_megahit \
    --skip_binning \
    --max_memory 50GB \
    --max_cpus 8

# all ncfb data
nextflow run nf-core/mag -r 2.3.0 \
    -profile singularity \
    -resume \
    --input "$NCFB_FASTQ/SRX*_{1,2}.fastq.gz" \
    --outdir /scratch/mdprieto/cf_seed_results/nf-mag \
    --host_genome GRCh38 \
    --kraken2_db $KRAKEN2_DB \
    --skip_prodigal \
    --skip_prokka \
    --skip_krona \
    --skip_spades \
    --skip_megahit \
    --skip_binning \
    --max_memory 77GB \
    --max_cpus 8
    
```

### 20230327 - nf_core tax profiler

- Requires a pretty specific sample sheet with the following columns `sample,run_name_accession,platform(ILLUMINA),fastq_1,fastq_2,fasta`
- I create it for now manually, and if necessary will build a python script to make it automatically ([Useful base script](https://github.com/nf-core/rnaseq/blob/master/bin/fastq_dir_to_samplesheet.py))
- To run, most options are opt-in. For now, I will explore only a few samples and try to produce results exclusively with Kraken2

```sh
KRAKEN2_DB="/home/mdprieto/object_database/kraken2/k2_standard_20221209.tar.gz"
SAMPLE_SHEET="/project/60005/mdprieto/cf_seed_2023/scripts/samplesheet_taxprof_ncfb.csv"
DB_CSV="/project/60005/mdprieto/cf_seed_2023/scripts/databases_taxprof.csv"

# test run    
nextflow run nf-core/taxprofiler -r 1.0.0 \
    -profile singularity \
    -resume \
    --input /project/60005/mdprieto/cf_seed_2023/scripts/trial_samplesheet.csv \
    --databases $DB_CSV \
    --outdir /scratch/mdprieto/cf_seed_results/taxprof \
    --perform_shortread_qc \
    --perform_shortread_hostremoval \
    --hostremoval_reference /project/cidgoh-object-storage/database/reference_genomes/human/GRCh38.p14/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna \
    --shortread_hostremoval_index /project/cidgoh-object-storage/database/bowtie_GRCh38 \
    --run_bracken \
    --run_kraken2 \
    --max_cpus 8 \
    --max_memory 60GB  
```

- Multiple errors while working with bracken and kraken databases, they seem to be the same name and path, so I will duplicate them. It is a pretty resource intensive process as the file is more than 48 GB.

### 20230808 - Restarting to troubleshoot the taxprofiler pipeline

- Preparation for nf-taxprofiler includes defining the `sample_sheet.csv` and `database.csv` as well as putting the Bowtie2 index for human samples inside the folder with the reference genome
  - To improve efficiency, I uncompress(untar) the **Kraken/Bracken database** so the pipeline does not have to do it for every run
- Created snippet for `sample_sheet.csv` creation
- After setting up the required databases and correcting specification of PATHs for eagle, the pipeline is working. I created a `custom.config` to specify resources available in the Eagle HPC and minimize the burden for other lab members.

### 20230811 - Completed taxprofiler pipeline for NCFB and CF shotgun sample

- Run CF data in taxprofiler using Slurm as executor over a couple of days.
  - Had error in taxpasta module standardization due to poor quality sample (**cf_sample69**), not an issue with the pipeline apparently
- Prepared and run a similar script for Shotgun MGS data in NCFB.

### 20230814 - Preparing downstream analysis of taxonomic classification

- Updated container for `taxpasta` in taxprofiler to latest version to avoid errors in low complexity samples that do not add up to 100% in taxonomical classification of reads.
- New script for downstream analysis describes organization of files required for R and preliminary steps
- I also use the latest version of `taxpasta` to produce **biom** format files for import to R as required for processing using the `phyloseq` package
- Some of the final results from taxprofiler were moved into the `/results` folder in the repository of the project
  - Krona plots for taxonomic distribution in every sample
  - Aggregated taxonomy classification of bracken

### 20230816 - Creating proper .biom files for phyloseq

- I will modify the taxprofiler pipeline to produce kraken-style (all taxa assigned reads) output later
  - Meanwhile I ran bracken manually for all files using the `kraken2` ouput of `taxprofiler`
  - I classified down to **Genus** as this is the interest of the study and will limit read_length to 100
- The output is used in `kraken-biom v1.2.0` (avoids errors) with options to produce `.json` formatted files
  - Succesfully imported to R

```sh
# apply to both diseases
for disease in {cf,ncfb}
    do
    # nested for loop to apply bracken to every file in the corresponding disease path
    for report in $(ls /scratch/mdprieto/results/cf_seed/taxprof_${disease}/kraken2/k2_db/*)
        do
            # define naming prefix based on sample_id
        SAMPLE=$(basename $report | sed -E 's/_SRX.*//')
            # run bracken specifying level (-l) genus and read_length (-r) of 100
            # option -w produces kraken style reports
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

## 20230822 - Correcting de-hosting issue with NCFB data

- I do a pilot run with NCFB producing krona plots to see if by specifying adequately the reference human genome and **Bowtie2** indexes we get a better result
  - **Result:** no changes, seems like initial de-hosting was done adequately
- As necessary for this analysis, the **database_samplesheet** is modified to summarize bracken at the genus level
- The custom config file was modified to produce kraken_style output for bracken too, this way the output can be used to create the **.biom** file
