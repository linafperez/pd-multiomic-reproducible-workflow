#!/bin/bash
#SBATCH --job-name=Qiime2_cutadapt
#SBATCH --output=Qiime2_cutadapt_%j.out
#SBATCH --error=Qiime2_cutadapt_%j.err
#SBATCH --nodelist=pujnodo3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=19G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"
# Record start time
start_time=$(date +%s)

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences ../../Import/PD-demux.qza \
  \
  --p-front-f GTGYCAGCMGCCGCGGTAA \
  --p-front-r CCGYCAATTYMTTTRAGTTT \
  \
  --p-cores 12 \
  --o-trimmed-sequences PD-demux-trimmed.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Cutadapt job completed in $runtime seconds"
