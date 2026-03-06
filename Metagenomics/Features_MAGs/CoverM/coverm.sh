#!/bin/bash
#SBATCH --job-name=CoverM_MAGs
#SBATCH --output=CoverM_%j.out
#SBATCH --error=CoverM_%j.err
#SBATCH --nodelist=pyky-w003
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "CoverM job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# -----------------------------
# 0. Configuration
# -----------------------------
DATA_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Data/reads"
MAG_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/dRep_out/dereplicated_genomes"
FINAL_OUTPUT="/data_HPC02/alexis_rojasc/Metagenomics/Features_MAGs/CoverM/Results"

THREADS=$SLURM_CPUS_PER_TASK

mkdir -p "$FINAL_OUTPUT"

# -----------------------------
# 1. Build paired-end list
# -----------------------------
COUPLED_ARGS=""
while IFS= read -r -d '' R1; do
    if [[ "$R1" =~ _R1\.fastq ]]; then
        R2="${R1/_R1.fastq/_R2.fastq}"
        if [[ -f "$R2" ]]; then
            COUPLED_ARGS+="$R1 $R2 "
        else
            echo "WARNING: No matching R2 for $R1 -  skipping." >&2
        fi
    fi
done < <(find "$DATA_DIR" -type f -name "*_R1.fastq" -print0 | sort -z)

if [[ -z "$COUPLED_ARGS" ]]; then
    echo "ERROR: No paired FASTQ files found in $DATA_DIR" >&2
    exit 1
fi

NUM_PAIRS=$(echo "$COUPLED_ARGS" | wc -w)
NUM_PAIRS=$((NUM_PAIRS / 2))
echo "Found $NUM_PAIRS paired-end read sets."

# -----------------------------
# 2. Run CoverM
# -----------------------------
echo "Running CoverM genome-level coverage estimation..."

coverm genome \
  --genome-fasta-directory "$MAG_DIR" \
  --genome-fasta-extension fa \
  --coupled $COUPLED_ARGS \
  --mapper minimap2-sr \
  --methods relative_abundance mean covered_fraction length \
  --proper-pairs-only \
  --min-read-percent-identity 95 \
  --min-read-aligned-percent 75 \
  --min-covered-fraction 0 \
  --contig-end-exclusion 0 \
  --threads "$THREADS" \
  --output-format dense \
  --output-file "$FINAL_OUTPUT/MAG_coverage.tsv"

echo "CoverM job finished successfully at: $(date +"%Y-%m-%d %H:%M:%S")"

