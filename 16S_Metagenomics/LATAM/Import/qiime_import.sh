#!/bin/bash
#SBATCH --job-name=Qiime_import
#SBATCH --output=Qiime_import_%j.out
#SBATCH --error=Qiime_import_%j.err
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

# Run the QIIME 2
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-format PairedEndFastqManifestPhred33V2 \
  --input-path manifest.tsv \
  --output-path PD-demux.qza

# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Job completed in $runtime seconds"
