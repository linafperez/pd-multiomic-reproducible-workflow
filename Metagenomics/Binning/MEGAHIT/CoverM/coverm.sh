#!/bin/bash
#SBATCH --job-name=CoverM
#SBATCH --output=CoverM_%j.out
#SBATCH --error=CoverM_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# -----------------------------
# 0. Configuration
# -----------------------------
DATA_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Data/reads"
CONTIGS="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Megahit_out/final.contigs.fa"
FINAL_OUTPUT="/data_HPC02/alexis_rojasc/Metagenomics/Binning/MEGAHIT/CoverM/Binners"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Prepare dirs
# -----------------------------

mkdir -p "$FINAL_OUTPUT/MetaBAT2"
mkdir -p "$FINAL_OUTPUT/SemiBin2_COMEBin_Vamb"

# -----------------------------
# 2. Build interleaved paired-end list
# -----------------------------
COUPLED_ARGS=""

while IFS= read -r -d '' R1; do
    if [[ "$R1" =~ _R1\.fastq ]]; then
        R2="${R1/_R1.fastq/_R2.fastq}"
        if [[ -f "$R2" ]]; then
            COUPLED_ARGS+="$R1 $R2 "
        else
            echo "WARNING: No matching R2 for $R1 — skipping." >&2
        fi
    fi
done < <(find "$DATA_DIR" -type f -name "*_R1.fastq" -print0 | sort -z)

if [[ -z "$COUPLED_ARGS" ]]; then
    echo "ERROR: No valid paired-end FASTQ files found in $DATA_DIR" >&2
    exit 1
fi

NUM_PAIRS=$(echo "$COUPLED_ARGS" | wc -w)
NUM_PAIRS=$((NUM_PAIRS / 2))
echo "Found $NUM_PAIRS paired-end samples."

# -----------------------------
# 3. Run CoverM for each binner
# -----------------------------
echo "Running CoverM for MetaBAT2..."
coverm contig \
  --coupled $COUPLED_ARGS \
  --reference "$CONTIGS" \
  --mapper minimap2-sr \
  --methods metabat \
  -t "$THREADS" \
  --output-format dense \
  --output-file "$FINAL_OUTPUT/MetaBAT2/depth.metabat.txt"

echo "Running CoverM for SemiBin2, Vamb, and COMEBin..."

BAM_CACHE="$FINAL_OUTPUT/SemiBin2_COMEBin_Vamb/BAM_cache"
mkdir -p "$BAM_CACHE"

coverm contig \
  --coupled $COUPLED_ARGS \
  --reference "$CONTIGS" \
  --mapper minimap2-sr \
  --methods mean \
  -t "$THREADS" \
  --output-format dense \
  --output-file "$FINAL_OUTPUT/SemiBin2_COMEBin_Vamb/depth.txt" \
  --bam-file-cache-directory "$BAM_CACHE"

echo "CoverM finished at: $(date +"%Y-%m-%d %H:%M:%S")"

