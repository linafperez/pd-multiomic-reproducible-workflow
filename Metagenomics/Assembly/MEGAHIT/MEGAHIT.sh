#!/bin/bash
#SBATCH --job-name=MEGAHIT
#SBATCH --output=MEGAHIT_%j.out
#SBATCH --error=MEGAHIT_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=500G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# -----------------------------
# 0. Configuration
# -----------------------------
DATA_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/Data/reads"
FINAL_OUTPUT="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/Megahit_out"

TMP_BASE="/tmp/megahit"
TMP_DATA="$TMP_BASE/data"

THREADS=$SLURM_CPUS_PER_TASK

# Cleanup on exit
#trap "rm -rf $TMP_BASE" EXIT

# -----------------------------
# 1. Prepare tmp + output dirs
# -----------------------------

mkdir -p "$TMP_DATA" "$FINAL_OUTPUT"

# -----------------------------
# 2. Copy inputs efficiently
# -----------------------------

if [ ! -d "$TMP_DATA" ] || [ -z "$(ls -A "$TMP_DATA")" ]; then
    echo "Copying data to local disk..."
    rsync -a --info=progress2 "$DATA_DIR"/ "$TMP_DATA"/
else
    echo "TMP_DATA folder already exists with data, skipping copy."
fi

# -----------------------------
# 3. Build paired-end lists
# -----------------------------
R1_LIST=""
R2_LIST=""

while IFS= read -r -d '' R1; do
    if [[ "$R1" =~ _R1\.fastq$ ]]; then
        R2="${R1/_R1.fastq/_R2.fastq}"
    else
        continue
    fi

    if [[ -f "$R2" ]]; then
        R1_LIST+="$R1,"
        R2_LIST+="$R2,"
    else
        echo "WARNING: No matching R2 for $R1 — skipping." >&2
    fi
done < <(find "$TMP_DATA" -type f -name "*_R1.fastq" -print0 | sort -z)

# Remove trailing commas
R1_LIST="${R1_LIST%,}"
R2_LIST="${R2_LIST%,}"

if [[ -z "$R1_LIST" || -z "$R2_LIST" ]]; then
    echo "ERROR: No valid paired-end FASTQ files found in $TMP_DATA" >&2
    exit 1
fi

NUM_PAIRS=$(echo "$R1_LIST" | tr ',' '\n' | wc -l)
echo "Found $NUM_PAIRS paired-end samples."

# -----------------------------
# 4. Run MEGAHIT with monitoring
# -----------------------------
echo "Running MEGAHIT..."

megahit \
  -1 "$R1_LIST" -2 "$R2_LIST" \
  -t "$THREADS" \
  --mem-flag 1 \
  --memory 0.9 \
  --presets meta-large \
  --min-contig-len 1000 \
  -o "$TMP_BASE/Megahit_out"

echo "MEGAHIT completed."

# -----------------------------
# 5. Copy results back
# -----------------------------
echo "Copying results to: $FINAL_OUTPUT"
rsync -a --info=progress2 "$TMP_BASE/Megahit_out/" "$FINAL_OUTPUT/"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"
