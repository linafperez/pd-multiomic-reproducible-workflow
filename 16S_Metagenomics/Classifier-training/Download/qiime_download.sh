#!/bin/bash
#SBATCH --job-name=Qiime2-download
#SBATCH --output=Qiime2-download_%j.out
#SBATCH --error=Qiime2-download_%j.err
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
# 1. Download SILVA 138.2 full-length reference sequences + taxonomy
###############################################################################
qiime rescript get-silva-data \
  --p-version 138.2 \
  --p-target SSURef_NR99 \
  --p-include-species-labels \
  --o-silva-sequences silva-138.2-ssu-nr99-seqs.qza \
  --o-silva-taxonomy silva-138.2-ssu-nr99-tax.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "All completed in $runtime seconds"
