#!/bin/bash
#SBATCH --job-name=Qiime2-extract
#SBATCH --output=Qiime2-extract_%j.out
#SBATCH --error=Qiime2-extract_%j.err
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
# 3. Extract just your amplicon region (V3–V4, primers 341F / 785R)
#    - Expected product length ~ 440 bp
#    - Adjust min/max if your data quality plots show different sizes
###############################################################################
qiime feature-classifier extract-reads \
  --i-sequences ../../../Classifier-training/Curate/silva-138.2-ssu-nr99-seqs-derep.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GACTACHVGGGTATCTAATCC \
  --p-min-length 300 \
  --p-max-length 500 \
  --o-reads silva-138.2-v34-ref-seqs.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "All completed in $runtime seconds"
