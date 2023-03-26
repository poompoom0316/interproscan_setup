#!/usr/bin/env bash

#setup script
mamba create -c bioconda interproscan -n interproscan
mamba install -c bioconda pftools=3.2.12

cd tools
python3 setup.py -f interproscan.properties

# test
fasta_path="/home/tomoaki-hori/anaconda3/envs/interproscan/share/InterProScan/test_proteins.fasta"
interproscan.sh -i ${fasta_path} -f tsv

# trial
conda activate interproscan
prot_fasta_path="xxx.fasta"
interproscan.sh -i ${prot_fasta_path} -f tsv -d "Analysis/symc_g" --cpu 7

