#!/bin/bash
#SBATCH --job-name=Qiime2-summarize
#SBATCH --output=Qiime2-summarize_%j.out
#SBATCH --error=Qiime2-summarize_%j.err
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

# Summarize feature table
qiime feature-table summarize \
  --i-table ../DADA/PD-table.qza \
  --o-visualization PD-table.qzv

# Tabulate representative sequences
qiime feature-table tabulate-seqs \
  --i-data ../DADA/PD-rep-seqs.qza \
  --o-visualization PD-rep-seqs.qzv

# Summarize denoising stats
qiime metadata tabulate \
  --m-input-file ../DADA/PD-stats.qza \
  --o-visualization PD-stats.qzv

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Summarize completed in $runtime seconds"
