#!/bin/bash
#SBATCH --job-name=Qiime2-extract
#SBATCH --output=Qiime2-extract_%j.out
#SBATCH --error=Qiime2-extract_%j.err
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

###############################################################################
# 3. Extract just your amplicon region (V4–V5, primers 515F / 926R)
#    - Expected product size ~400 bp
###############################################################################
qiime feature-classifier extract-reads \
  --i-sequences ../../../Classifier-training/Curate/silva-138.2-ssu-nr99-seqs-derep.qza \
  --p-f-primer GTGYCAGCMGCCGCGGTAA \
  --p-r-primer CCGYCAATTYMTTTRAGTTT \
  --p-min-length 240 \
  --p-max-length 420 \
  --o-reads silva-138.2-v45-ref-seqs.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "All completed in $runtime seconds"
