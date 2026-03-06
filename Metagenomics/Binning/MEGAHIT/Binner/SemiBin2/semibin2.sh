#!/bin/bash
#SBATCH --job-name=SemiBin2
#SBATCH --output=SemiBin2_%j.out
#SBATCH --error=SemiBin2_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=25
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Data 
# -----------------------------
CONTIGS="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Megahit_out/final.contigs.fa"
BAM_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/MEGAHIT/CoverM/Binners/SemiBin2_COMEBin/BAM_cache"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/MEGAHIT/Binner/SemiBin2"
OUTPUT_DIR="$WORKDIR/SemiBin2_out"

CONTIGS_BASENAME=$(basename "$CONTIGS")

# -----------------------------
# 2. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/SemiBin2"
TMP_CONTIGS="$TMP_BASE/Contigs"
TMP_BAM="$TMP_BASE/BAM_files"
TMP_OUTPUT="$TMP_BASE/SemiBin2_out"

mkdir -p "$OUTPUT_DIR" "$TMP_CONTIGS" "$TMP_BAM" "$TMP_OUTPUT"

# -----------------------------
# 3. Copy inputs
# -----------------------------
echo "Copying contigs and BAM files to tmp..."
rsync -a --info=progress2 "$CONTIGS" "$TMP_CONTIGS/"
rsync -a --info=progress2 "$BAM_DIR/" "$TMP_BAM/"

# List BAM files to pass to SemiBin2
BAM_LIST=("$TMP_BAM"/*.bam)
if [ ${#BAM_LIST[@]} -eq 0 ]; then
    echo "No BAM files found in $TMP_BAM"
    exit 1
fi

# -----------------------------
# 4. Run SemiBin2
# -----------------------------
echo "Running SemiBin2..."
SemiBin2 single_easy_bin \
  -i "$TMP_CONTIGS/$CONTIGS_BASENAME" \
  -b "${BAM_LIST[@]}" \
  -p "$THREADS" \
  --output "$TMP_OUTPUT"
echo "SemiBin2 completed."

# -----------------------------
# 5. Copy results back
# -----------------------------
echo "Copying results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# -----------------------------
# 6. Cleanup
# -----------------------------
echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

