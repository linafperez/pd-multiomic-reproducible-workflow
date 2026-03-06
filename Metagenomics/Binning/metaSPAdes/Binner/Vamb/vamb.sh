#!/bin/bash
#SBATCH --job-name=Vamb
#SBATCH --output=Vamb_%j.out
#SBATCH --error=Vamb_%j.err
#SBATCH --nodelist=pujnodo6
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=20G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Data 
# -----------------------------
CONTIGS="/opt/data/HPC01A/alexis_rojasc2/Alexis/Metagenomics/Assembly/metaSPAdes/metaSPAdes_out/contigs.fasta"
COVERAGE="/opt/data/HPC01A/alexis_rojasc2/Alexis/Metagenomics/Binning/metaSPAdes/CoverM/Vamb_MetaBinner/depth.vamb.cleaned.txt"
WORKDIR="/opt/data/HPC01A/alexis_rojasc2/Alexis/Metagenomics/Binning/metaSPAdes/Binner/Vamb"
OUTPUT_DIR="$WORKDIR/Vamb_out"

# -----------------------------
# 2. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/Vamb"
TMP_CONTIGS="$TMP_BASE/Contigs"
TMP_COVERAGE="$TMP_BASE/Coverage"
TMP_OUTPUT="$TMP_BASE/Vamb_out"

mkdir -p "$OUTPUT_DIR" "$TMP_CONTIGS" "$TMP_COVERAGE"

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
# 4. Run Vamb
# -----------------------------
echo "Running Vamb..."
vamb bin default \
  --fasta "$TMP_CONTIGS/$(basename "$CONTIGS")" \
  --outdir "$TMP_OUTPUT" \
  -m 2000 \
  -e 100 \
  -q 25 75 \
  -p "$THREADS" \
  --abundance_tsv "$TMP_COVERAGE/$(basename "$COVERAGE")"

echo "Vamb completed."

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
