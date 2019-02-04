#!/bin/bash

snakemake \
    -kp \
    --ri \
    -j 20 \
    --cluster-config /project2/xinhe/ATAC-seq_10252018/test_pipeline/ATACseq_pipeline/cluster.json \
    -c "sbatch \
        --mem={cluster.mem} \
        --nodes={cluster.n} \
        --tasks-per-node={cluster.tasks} \
        --partition=mengjiechen \
	--account=pi-mengjiechen \
        --job-name={cluster.name} \
	--output={cluster.logfile}" \
    $*
