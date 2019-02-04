## ATAC-seq Pipeline

This ATAC-seq Snakemake pipeline is designed to process ATAC-seq data from bam files to a peak count matrix: peakcalling is conducted on reads pooled from all samples (suppose that they are alll of the same cell type), and then the number of reads that fall into each peak is tabulated for each sample, resulting in a peak by sample matrix.

Peak calling is conducted by program MACS2 (Model-based Analysis of ChIP-Seq, Zhang et al), which is based on python 2.7, and thus couldn't be installed in the virtual environment (in conflict with the installation of snakemake which requires python 3). The user has to install MACS2 separately and provide its executable directory in the `config.yaml` file.

The dependencies between jobs are demonstrated in a directed graph `pipeline_dag.svg` (using 2 bam files as input data).

Each experiment differs and the pipeline might need to be adjusted to accommodate such individual differences (such as adding read alignment steps to obtain bam files).

## Usage

#### 1. Create a virtual environment using conda (this step can be skipped when re-running an analysis)

The environment needs to be created only once. It will be activated when running the ATAC-seq pipeline.

```bash
module load Anaconda3

conda env create --file environment.yaml
```

To update the environment (if you need extra programs), you can run the following command:
```bash
conda env update --file environment.yaml
```

#### 2. Edit the configuration file config.yaml with the parameters of your choice

Edit the `config.yaml` file to set your specific configurations, such as:

* `bam_dir`: where all your sample bam files are located
* `celltype`: what cell type/tissue your samples came from
* `macs2_dir`: directory of the executable MACS2
* `peak_fdr`: what fdr level you want to use for MACS2 peak calling
* ...

#### 3. Run the Snakemake pipeline

Add  `Snakefile` and the edited configuration file `config.yaml` to your project directory, and run the following commands:

```bash
source activate peakcalling
snakemake --configfile config.yaml
```

Or, you can submit the job on SLURM, or even adding a cluster configuration file (e.g. `cluster.json`), which allows you to specify the computational resource (such as memory usage) allocated for each snakemake rule. 

#### 4. Output

There will be 3 output folders: 
`bedfiles` stores all the .bed files converted from .bam files, `peakcalling` stores the peak calling outputs, and `count` stores peak counts for each sample.

The final peak count per sample matrix is stored in `count/{celltype}_per_sample_count.txt`.

