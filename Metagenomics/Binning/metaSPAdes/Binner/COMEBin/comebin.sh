#!/bin/bash
#SBATCH --job-name=COMEBin
#SBATCH --output=COMEBin_%j.out
#SBATCH --error=COMEBin_%j.err
#SBATCH --nodelist=pyky-w003
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Data
# -----------------------------
CONTIGS="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/metaSPAdes/metaSPAdes_out/contigs.fasta"
BAM_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/CoverM/Binners/SemiBin2_COMEBin/BAM_cache"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Binner/COMEBin"
OUTPUT_DIR="$WORKDIR/COMEBin_out"

CONTIGS_BASENAME=$(basename "$CONTIGS")

# -----------------------------
# 2. Temporary folders
# -----------------------------
TMP_BASE="/tmp/COMEBin"
TMP_CONTIGS="$TMP_BASE/Contigs"
TMP_BAM="$TMP_BASE/BAM_files"
TMP_OUTPUT="$TMP_BASE/COMEBin_out"

mkdir -p "$OUTPUT_DIR" "$TMP_CONTIGS" "$TMP_BAM" "$TMP_OUTPUT"

# -----------------------------
# 3. Copy inputs
# -----------------------------
echo "Copying contigs and BAM files to tmp..."
rsync -a --info=progress2 "$CONTIGS" "$TMP_CONTIGS/"
rsync -a --info=progress2 "$BAM_DIR/" "$TMP_BAM/"

# -----------------------------
# 4. Check BAM files
# -----------------------------
shopt -s nullglob
bam_files=("$TMP_BAM"/*.bam)
if [ ${#bam_files[@]} -eq 0 ]; then
    echo "No BAM files found in $TMP_BAM"
    exit 1
fi

# -----------------------------
# 5. Run COMEBin
# -----------------------------
echo "Running COMEBin..."
bash run_comebin.sh \
  -a "$TMP_CONTIGS/$CONTIGS_BASENAME" \
  -o "$TMP_OUTPUT" \
  -p "$TMP_BAM" \
  -t "$THREADS"
echo "COMEBin completed."

# -----------------------------
# 6. Copy results back
# -----------------------------
echo "Copying results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# -----------------------------
# 7. Cleanup
# -----------------------------
echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

