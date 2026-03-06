#!/bin/bash
#SBATCH --job-name=GUNC
#SBATCH --output=GUNC_%j.out
#SBATCH --error=GUNC_%j.err
#SBATCH --nodelist=pyky-w004
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
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/DAS-Tool_out/DASTool_DASTool_bins"
DB_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/MEGAHIT/Refinement/Quality_control/Raw_bin/GUNC/GTDB"
OUTPUT_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/Quality_control/Raw_bin/GUNC/GUNC_out"

mkdir -p "$OUTPUT_DIR"

# -----------------------------
# 2. Run GUNC
# -----------------------------
echo "Running GUNC..."
gunc run \
    --input_dir "$BIN_DIR" \
    --db_file "$DB_DIR/gunc_db_gtdb95.dmnd" \
    --out_dir "$OUTPUT_DIR" \
    --threads "$THREADS"

echo "GUNC run completed."

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"
