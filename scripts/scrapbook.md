## Nextflow

If necessary to prepare all dependencies for nf-core pipeline

```sh
nf-core download fetchngs \
    --container singularity \
    --outdir "/scratch/mdprieto/nfcore-fetchngs-1.9" \
    --singularity-cache-only
```