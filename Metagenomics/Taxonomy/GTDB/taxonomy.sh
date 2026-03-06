#!/bin/bash
#SBATCH --job-name=gtdbtk
#SBATCH --output=gtdbtk_%j.out
#SBATCH --error=gtdbtk_%j.err
#SBATCH --nodelist=pyky-w001
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"
THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input paths
# -----------------------------
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/dRep_out/dereplicated_genomes"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Taxonomy/GTDB"
OUTPUT_DIR="$WORKDIR/GTDBTK_out"

# -----------------------------
# 2. GTDB-Tk database
# -----------------------------
export GTDBTK_DATA_PATH="/data_HPC02/alexis_rojasc/Metagenomics/Taxonomy/GTDB/DB/release226"
echo "Using GTDB database at: $GTDBTK_DATA_PATH"

# -----------------------------
# 3. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/gtdbtk_${SLURM_JOB_ID}"
TMP_BINS="$TMP_BASE/Bins"
TMP_OUTPUT="$TMP_BASE/GTDBTK_out"

mkdir -p "$TMP_BASE" "$TMP_BINS" "$TMP_OUTPUT" "$OUTPUT_DIR"

# Count input files for logging
BIN_COUNT=$(find "$BIN_DIR" -type f -name "*.fa" | wc -l)
echo "Found $BIN_COUNT genome files to process."

# -----------------------------
# 4. Copy MAGs to local node
# -----------------------------
echo "Copying MAGs to local node..."
rsync -a --info=progress2 "$BIN_DIR/" "$TMP_BINS/"

# -----------------------------
# 5. Run GTDB-Tk classification
# -----------------------------
echo "Running GTDB-Tk classification..."
gtdbtk classify_wf \
  --genome_dir "$TMP_BINS" \
  --out_dir "$TMP_OUTPUT" \
  --extension fa \
  --cpus "$THREADS" \
  --pplacer_cpus 8 \
  --min_perc_aa 10 \
  --scratch_dir "$TMP_BASE" \
  --min_af 0.5

echo "GTDB-Tk classification completed successfully."

# -----------------------------
# 6. Copy results back
# -----------------------------
echo "Copying GTDB-Tk results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# -----------------------------
# 7. Summary and cleanup
# -----------------------------
echo "Summary of classifications:"
if [ -f "$OUTPUT_DIR/gtdbtk.bac120.summary.tsv" ]; then
  echo "Bacterial results:"
  head -n 5 "$OUTPUT_DIR/gtdbtk.bac120.summary.tsv"
fi
if [ -f "$OUTPUT_DIR/gtdbtk.ar122.summary.tsv" ]; then
  echo "Archaeal results:"
  head -n 5 "$OUTPUT_DIR/gtdbtk.ar122.summary.tsv"
fi

RESULT_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
echo "Generated $RESULT_COUNT result files."

echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"
echo "Results available in: $OUTPUT_DIR"
