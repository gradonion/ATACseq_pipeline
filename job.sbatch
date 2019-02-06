#!/bin/bash

#SBATCH --job-name=snakemake
#SBATCH --output=snakemake.out
#SBATCH --error=snakemake.err
#SBATCH --time=24:00:00
#SBATCH --partition=partition_name
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --account=account_name
#SBATCH --mem-per-cpu=4G

module load Anaconda3
source activate peakcalling
module load java
#snakemake --configfile config.yaml -j 4

bash Submit_snakemake.sh "-s Snakefile" "--configfile config.yaml" $*
