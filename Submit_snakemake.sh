#!/bin/bash

snakemake \
    -kp \
    --ri \
    -j 20 \
    --cluster-config cluster.json \
    -c "sbatch \
        --mem={cluster.mem} \
        --nodes={cluster.n} \
        --tasks-per-node={cluster.tasks} \
        --partition=partition_name \
	--account=account_name \
        --job-name={cluster.name} \
	--output={cluster.logfile}" \
    $*
