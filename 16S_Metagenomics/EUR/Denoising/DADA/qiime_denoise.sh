#!/bin/bash
#SBATCH --job-name=Qiime2-dada2
#SBATCH --output=Qiime2-dada2_%j.out
#SBATCH --error=Qiime2-dada2_%j.err
#SBATCH --nodelist=pujnodo5
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

# Run DADA2 denoising on paired-end reads
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs ../Cutadapt/PD-demux-trimmed.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 300 \
  --p-trunc-len-r 228 \
  --p-n-threads 12 \
  --o-representative-sequences PD-rep-seqs.qza \
  --o-table PD-table.qza \
  --o-denoising-stats PD-stats.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "DADA2 completed in $runtime seconds"
