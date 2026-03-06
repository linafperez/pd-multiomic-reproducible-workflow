#!/bin/bash
#SBATCH --job-name=metaSPAdes
#SBATCH --output=metaSPAdes_%j.out
#SBATCH --error=metaSPAdes_%j.err
#SBATCH --nodelist=pyky-w004      
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=1800G
#SBATCH --partition=debug    

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# -----------------------------
# 0. Configuration
# -----------------------------
DATA_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Data/reads"
FINAL_OUTPUT="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/metaSPAdes/metaSPAdes_out"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/metaSPAdes"


TMP_BASE="/tmp/rnaSPAdes"
TMP_DATA="$TMP_BASE/data"
TMP_WORKDIR="$TMP_BASE/workdir"

THREADS=$SLURM_CPUS_PER_TASK
YAML_FILE="$WORKDIR/dataset.yaml"

# -----------------------------
# 1. Prepare tmp + output dirs
# -----------------------------
echo "Preparing temporary directories..."

#mkdir -p "$TMP_DATA" "$TMP_WORKDIR" "$FINAL_OUTPUT"
mkdir -p "$FINAL_OUTPUT"

# -----------------------------
# 2. Copy inputs efficiently
# -----------------------------
if [ ! -d "$TMP_DATA" ] || [ -z "$(ls -A "$TMP_DATA")" ]; then
    echo "Copying data from $DATA_DIR to local disk ($TMP_DATA)..."
    cp -Lr "$DATA_DIR"/* "$TMP_DATA"/
else
    echo "TMP_DATA folder already exists with data, skipping copy."
fi

# -----------------------------
# 3. Build the dataset file (JSON-style YAML)
# -----------------------------
echo "Generating dataset file..."

LEFT_LIST=($(find "$DATA_DIR" -type f -name "*_R1.fastq" | sort))

if [[ ${#LEFT_LIST[@]} -eq 0 ]]; then
    echo "ERROR: No matching '*_R1.fastq' found in $DATA_DIR" >&2
    echo "Contents of $DATA_DIR:" >&2
    ls -la "$DATA_DIR" >&2
    exit 1
fi

echo "Found ${#LEFT_LIST[@]} samples."

# Write JSON-style array
echo "[" > "$YAML_FILE"

for i in "${!LEFT_LIST[@]}"; do
    left_file="${LEFT_LIST[$i]}"
    right_file="${left_file%_R1.fastq}_R2.fastq"

    if [[ ! -f "$right_file" ]]; then
        echo "ERROR: Corresponding _R2.fastq not found for $left_file. Looking for: $right_file" >&2
        exit 1
    fi

    {
      echo "  {"
      echo "    orientation: \"fr\","
      echo "    type: \"paired-end\","
      echo "    left reads: ["
      echo "      \"$left_file\""
      echo "    ],"
      echo "    right reads: ["
      echo "      \"$right_file\""
      echo "    ]"
      if [[ $i -lt $((${#LEFT_LIST[@]} - 1)) ]]; then
        echo "  },"
      else
        echo "  }"
      fi
    } >> "$YAML_FILE"
done

echo "]" >> "$YAML_FILE"

echo "Dataset file created at: $YAML_FILE"
echo "First 20 lines:"
head -n 20 "$YAML_FILE"

# -----------------------------
# 4. Run metaSPAdes
# -----------------------------
echo "Running metaSPAdes..."

ulimit -n 65535
spades.py --meta \
          --dataset "$YAML_FILE" \
          --threads "$THREADS" \
          --memory 1800 \
          -o "$FINAL_OUTPUT" \
          --continue

echo "metaSPAdes completed successfully."

# -----------------------------
# 5. Copy results back
# -----------------------------
echo "Copying results to: $FINAL_OUTPUT"
rsync -a --info=progress2 "$TMP_WORKDIR/" "$FINAL_OUTPUT/"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

