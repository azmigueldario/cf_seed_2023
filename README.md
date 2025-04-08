# cf_seed_2023

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

## Available datasets

Available projects were searched in the ENA and NCBI repositories (March 17, 2023). Eligibility criteria were shotgun metagenomic studies from the lung in humans for NCFB or CF.

```sh
# search criteria CF 
((cystic fibrosis lung) AND "metagenomic"[Source] ) NOT ("amplicon"[Strategy] OR "rna seq"[Strategy] OR "abi solid"[Platform] OR "bgiseq"[Platform] OR "capillary"[Platform] OR "helicos"[Platform] OR "ls454"[Platform] OR "pcr"[Selection] )
```

### NCFB

The dataset of the project [PRJNA590225](https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA590225) seems to contain actual metagenomic information and not just Amplicon sequencing results. The primary article can be found here: [Mac Aogáin et al. 2021](https://www.nature.com/articles/s41591-021-01289-7).

- Metagenomic data was processed from sputum  
- Sample size of 166 participants in a single time-point - includes a few blank samples (total n = 176)
- Recruited in Singapore, Malaysia, UK and Italy  

No other papers in the ENA or NCBI seem to contain metagenomic data for bronchiectasis by March, 2023.

#### CF

The project [PRJNA516870](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA516870) was selected for analysis. Further data is available in the primary article by [Bacci et al. 2020](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7409339/).

- Samples processed from spontaneous sputum  
- Recruited in three Italian CF centers
- Sample size of 78, represents repetitive data from 26 patients

**Note:** The study PRJEB52317 has a larger sample of CF patients, but the available data seems to lack one of the paired-end reads.

## Analyses

Order of scripts to reproduce results:

1. Obtain primary **fastq** file data: `fetch_ngs.sh`
    - Download reference genome if necessary:  `download_database.sh`
2. Run nf-core taxprofiler for both datasets using either `ncfb_taxprofiler_full.sh` or `cf_taxprofiler_full.sh`
3. Transform output into **biom** file for downstream analysis: `create_biom_taxprofiler.sh`
4. Downstream analysis in the directory `/scripts` which has `cf_seed_2023.Rproj`
5. Analyze diversity and cleanup data for presentation: `taxonomy_abundance.Rmd`
