#!/bin/bash
#SBATCH --job-name=Qiime2-classification
#SBATCH --output=Qiime2-classification_%j.out
#SBATCH --error=Qiime2-classification_%j.err
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

# Taxonomy
qiime feature-classifier classify-sklearn \
  --i-classifier ../Train/silva-138.2-v34-classifier.qza \
  --i-reads ../../Denoising/DADA/PD-rep-seqs.qza \
  --p-n-jobs 4 \
  --p-read-orientation same \
  --p-confidence 0.7 \
  --o-classification PD-taxonomy.qza

# Visualization

qiime metadata tabulate \
  --m-input-file PD-taxonomy.qza \
  --o-visualization PD-taxonomy.qzv


# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Clasification step completed in $runtime seconds"
