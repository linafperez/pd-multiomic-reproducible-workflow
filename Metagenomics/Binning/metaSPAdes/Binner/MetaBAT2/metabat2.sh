#!/bin/bash
#SBATCH --job-name=MetaBat2
#SBATCH --output=MetaBat2_%j.out
#SBATCH --error=MetaBat2_%j.err
#SBATCH --nodelist=pyky-w004
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
COVERAGE="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/CoverM/Binners/MetaBAT2/depth.metabat.txt"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Binner/MetaBAT2"
OUTPUT_DIR="$WORKDIR/MetaBAT2_out"

# -----------------------------
# 2. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/MetaBAT2"
TMP_CONTIGS="$TMP_BASE/Contigs"
TMP_COVERAGE="$TMP_BASE/Coverage"
TMP_OUTPUT="$TMP_BASE/MetaBAT2_out"

mkdir -p "$OUTPUT_DIR" "$TMP_CONTIGS" "$TMP_COVERAGE" "$TMP_OUTPUT"

# -----------------------------
# 3. Copy inputs
# -----------------------------
if [ ! -s "$TMP_CONTIGS/$(basename "$CONTIGS")" ] || [ ! -s "$TMP_COVERAGE/$(basename "$COVERAGE")" ]; then
    echo "Copying contigs and coverage to local disk..."
    rsync -a --info=progress2 "$CONTIGS" "$TMP_CONTIGS/"
    rsync -a --info=progress2 "$COVERAGE" "$TMP_COVERAGE/"
else
    echo "Temporary input files already exist, skipping copy."
fi

# -----------------------------
# 4. Run MetaBAT2
# -----------------------------
echo "Running MetaBAT2..."
metabat2 \
  -i "$TMP_CONTIGS/$(basename "$CONTIGS")" \
  -a "$TMP_COVERAGE/$(basename "$COVERAGE")" \
  -o "$TMP_OUTPUT/bin" \
  -t "$THREADS"

echo "MetaBAT2 completed."

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

