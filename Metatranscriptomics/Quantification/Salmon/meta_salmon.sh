#!/bin/bash
#SBATCH --job-name=Salmon_MetaT
#SBATCH --output=Salmon_%j.out
#SBATCH --error=Salmon_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=80G
#SBATCH --partition=debug

set -euo pipefail
echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# =====================================================
# 0. CONFIGURATION
# =====================================================
WORKDIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon"
DATA_DIR="$WORKDIR/Data"
META_FASTA="$WORKDIR/MetaT/transcripts.fasta"
INDEX_DIR="$WORKDIR/Index"
OUTPUT_DIR="$WORKDIR/Salmon_out"

# Local scratch
TMP_BASE="/tmp/Salmon"
TMP_DATA="$TMP_BASE/Data"
TMP_INDEX="$TMP_BASE/Index"
TMP_OUTPUT="$TMP_BASE/Salmon_out"

mkdir -p "$TMP_DATA" "$TMP_INDEX" "$TMP_OUTPUT" "$INDEX_DIR" "$OUTPUT_DIR"

THREADS=$SLURM_CPUS_PER_TASK

# =====================================================
# 1. COPY INPUT DATA TO LOCAL NODE
# =====================================================
if [[ ! -d "$TMP_DATA" || -z "$(ls -A "$TMP_DATA" 2>/dev/null)" ]]; then
    echo "Copying input data to compute node..."
    cp -Lr "$DATA_DIR"/* "$TMP_DATA"/
else
    echo "Input data already exists in $TMP_DATA, skipping copy."
fi

if [[ ! -f "$TMP_INDEX/$(basename "$META_FASTA")" ]]; then
    echo "Copying MetaT FASTA reference..."
    rsync -a --info=progress2 "$META_FASTA" "$TMP_INDEX/"
else
    echo "MetaT FASTA already exists in $TMP_INDEX, skipping copy."
fi

# =====================================================
# 2. BUILD SALMON INDEX
# =====================================================
INDEX_NAME="Salmon_index"
INDEX_PATH="$TMP_INDEX/$INDEX_NAME"

if [[ ! -s "$INDEX_PATH/versionInfo.json" ]]; then
    echo "Building Salmon index..."
    salmon index \
        -t "$TMP_INDEX/transcripts.fasta" \
        -i "$INDEX_PATH" \
        -k 31 \
        -p "$THREADS"
    echo "Index built successfully."
else
    echo "Using existing index at $INDEX_PATH"
fi

# =====================================================
# 3. QUANTIFICATION (METATRANSCRIPTOMIC MODE)
# =====================================================
echo "Starting quantification..."

for fastq_R1 in "$TMP_DATA"/*_1.fastq; do
    base_name=$(basename "$fastq_R1" | sed 's/_1\.fastq$//')
    fastq_R2="$TMP_DATA/${base_name}_2.fastq"

    if [[ ! -f "$fastq_R2" ]]; then
        echo "Missing pair for $fastq_R1, skipping..."
        continue
    fi

    echo "Quantifying $base_name..."

    if ! /usr/bin/time -v salmon quant \
        -i "$INDEX_PATH" \
        -l A \
        -1 "$fastq_R1" \
        -2 "$fastq_R2" \
        -p "$THREADS" \
        --meta \
        --validateMappings \
        --recoverOrphans \
        --rangeFactorizationBins 4 \
        --seqBias --gcBias --posBias \
        --discardOrphansQuasi \
        --minScoreFraction 0.8 \
        --consensusSlack 0.05 \
        --numBootstraps 50 \
        -o "$TMP_OUTPUT/$base_name"; then
        echo "Salmon quant failed for $base_name"
        continue
    fi
done

# =====================================================
# 4. COPY RESULTS BACK TO STORAGE
# =====================================================
echo "Copying results back to storage..."
rsync -a --info=progress2 "$TMP_INDEX/" "$INDEX_DIR/"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# Optional cleanup of temporary scratch
echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

