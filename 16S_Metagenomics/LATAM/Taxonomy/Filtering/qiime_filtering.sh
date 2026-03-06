#!/bin/bash
#SBATCH --job-name=Qiime2-filtering
#SBATCH --output=Qiime2-filtering_%j.out
#SBATCH --error=Qiime2-filtering_%j.err
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

# Filter table
qiime taxa filter-table \
  --i-table ../../Denoising/DADA/PD-table.qza \
  --i-taxonomy ../Classification/PD-taxonomy.qza \
  --p-exclude mitochondria,chloroplast,Eukaryota \
  --o-filtered-table PD-table-final.qza

# Filter sequences in sync
qiime taxa filter-seqs \
  --i-sequences ../../Denoising/DADA/PD-rep-seqs.qza \
  --i-taxonomy ../Classification/PD-taxonomy.qza \
  --p-exclude mitochondria,chloroplast,Eukaryota \
  --o-filtered-sequences PD-rep-seqs-final.qza



# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Filtering step completed in $runtime seconds"
