#!/bin/bash
#SBATCH --job-name=Trans
#SBATCH --output=Trans_%j.out
#SBATCH --error=Trans_%j.err
#SBATCH --nodelist=pyky-w001
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=150G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"
THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input paths
# -----------------------------
WORKDIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Transcript_prediction/TransDecoder"
TRANSCRIPTS="$WORKDIR/Data/transcripts.fasta"
OUTPUT_DIR="$WORKDIR/Results"

mkdir -p "$OUTPUT_DIR"

# -----------------------------
# 2. Temporary folders
# -----------------------------
TMP_BASE="/tmp/transdecoder"
TMP_DATA="$TMP_BASE/Data"
TMP_OUTPUT="$TMP_BASE/Results"

mkdir -p "$TMP_BASE" "$TMP_DATA" "$TMP_OUTPUT" "$OUTPUT_DIR"

# Copy transcript file to local node
echo "Copying transcripts to local node..."
rsync -a --info=progress2 "$TRANSCRIPTS" "$TMP_DATA/"

# -----------------------------
# 3. Run TransDecoder
# -----------------------------
echo "Running TransDecoder.LongOrfs..."
TransDecoder.LongOrfs \
  -t "$TMP_DATA/$(basename "$TRANSCRIPTS")" \
  -m 30 \
  -O "$TMP_OUTPUT"

echo "Running TransDecoder.Predict..."
TransDecoder.Predict \
  -t "$TMP_DATA/$(basename "$TRANSCRIPTS")" \
  --single_best_only \
  -O "$TMP_OUTPUT" 

echo "TransDecoder prediction completed successfully."

# -----------------------------
# 4. Copy results back
# -----------------------------
echo "Copying TransDecoder results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_BASE/" "$OUTPUT_DIR/"

# -----------------------------
# 5. Summary and cleanup
# -----------------------------
PEP_FILE="$OUTPUT_DIR/Data/$(basename "$TRANSCRIPTS").transdecoder.pep"
if [ -f "$PEP_FILE" ]; then
  ORF_COUNT=$(grep -c "^>" "$PEP_FILE")
  echo "Predicted $ORF_COUNT protein sequences."
else
  echo "Warning: No .pep output file found."
fi

RESULT_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
echo "Generated $RESULT_COUNT result files."

echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"
echo "Results available in: $OUTPUT_DIR"
