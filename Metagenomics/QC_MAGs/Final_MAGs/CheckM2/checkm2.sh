#!/bin/bash
#SBATCH --job-name=CheckM2
#SBATCH --output=CheckM2_%j.out
#SBATCH --error=CheckM2_%j.err
#SBATCH --nodelist=pyky-w001
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=25G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input / Output paths
# -----------------------------
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/dRep_out/dereplicated_genomes"
OUTPUT_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/CheckM2/CheckM2_out"
DB_PATH="/data_HPC02/alexis_rojasc/Metagenomics/Binning/MEGAHIT/Refinement/Quality_control/Raw_bin/CheckM2/Diamond_DB/CheckM2_database/uniref100.KO.1.dmnd"

mkdir -p "$OUTPUT_DIR"

# -----------------------------
# 2. Run CheckM2 predict
# -----------------------------
echo "Running CheckM2..."
checkm2 predict \
    --input "$BIN_DIR" \
    --output-directory "$OUTPUT_DIR" \
    --database_path "$DB_PATH" \
    --threads "$THREADS" \
    -x fa

echo "CheckM2 completed."
echo "Results table: $OUTPUT_DIR/predicted_quality.tsv"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

