#!/bin/bash
#SBATCH --job-name=Qiime2-train
#SBATCH --output=Qiime2-train_%j.out
#SBATCH --error=Qiime2-train_%j.err
#SBATCH --nodelist=pujnodo4
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

###############################################################################
# 4. Train Naive Bayes classifier for V4–V5
###############################################################################
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads ../Extract/silva-138.2-v34-ref-seqs.qza \
  --i-reference-taxonomy ../../../Classifier-training/Curate/silva-138.2-ssu-nr99-tax-derep.qza \
  --o-classifier silva-138.2-v34-classifier.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "All completed in $runtime seconds"
