#!/bin/bash
#SBATCH --job-name=Phylophlan3
#SBATCH --output=Phylophlan3_%j.out
#SBATCH --error=Phylophlan3_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=120G
#SBATCH --partition=debug

set -euo pipefail

echo "PhyloPhlAn 3 job started at: $(date)"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input and output paths
# -----------------------------
MAG_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/dRep_out/dereplicated_genomes"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Taxonomy/Phylogenomics"
OUT_DIR="$WORKDIR/Results"
CONFIG_FILE="$WORKDIR/custom_config.cfg"

mkdir -p "$OUT_DIR"

# -----------------------------
# 2. Log genome count
# -----------------------------
MAG_COUNT=$(find "$MAG_DIR" -type f -name "*.fa" | wc -l)
echo "Found $MAG_COUNT MAGs to process."

# -----------------------------
# 3. Run PhyloPhlAn with config
# -----------------------------
echo "Starting PhyloPhlAn analysis..."

phylophlan \
  -i "$MAG_DIR" \
  -o "$OUT_DIR" \
  -d phylophlan \
  -f "$CONFIG_FILE" \
  -t a \
  --genome_extension .fa \
  --diversity high \
  --nproc "$THREADS" \
  --force_nucleotides

echo "PhyloPhlAn run completed successfully."
echo "Job finished at: $(date)"
echo "Results saved in: $OUT_DIR"

