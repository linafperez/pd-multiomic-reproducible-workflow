#!/bin/bash
#SBATCH --job-name=Qiime2-curate
#SBATCH --output=Qiime2-curate_%j.out
#SBATCH --error=Qiime2-curated_%j.err
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
# 2. Curate reference sequences
#    - Remove short/long or poor-quality sequences
#    - Dereplicate to eliminate redundancy
###############################################################################
qiime rescript cull-seqs \
  --i-sequences ../Download/silva-138.2-ssu-nr99-seqs.qza \
  --o-clean-sequences silva-138.2-ssu-nr99-seqs-clean.qza

qiime rescript dereplicate \
  --i-sequences silva-138.2-ssu-nr99-seqs-clean.qza \
  --i-taxa ../Download/silva-138.2-ssu-nr99-tax.qza \
  --p-mode uniq \
  --o-dereplicated-sequences silva-138.2-ssu-nr99-seqs-derep.qza \
  --o-dereplicated-taxa silva-138.2-ssu-nr99-tax-derep.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "All completed in $runtime seconds"
