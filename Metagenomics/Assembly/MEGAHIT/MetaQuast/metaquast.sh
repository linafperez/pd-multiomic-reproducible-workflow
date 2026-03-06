#!/bin/bash
#SBATCH --job-name=MetaQUAST
#SBATCH --output=MetaQUAST_%j.out
#SBATCH --error=MetaQUAST_%j.err
#SBATCH --nodelist=pyky-w003
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# Input assembly
ASSEMBLY="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/Megahit_out/final.contigs.fa"

# Output directory
OUTDIR="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/MEGAHIT/MetaQuast/MetaQuast_out"
mkdir -p "$OUTDIR"

# Use all CPUs requested by SLURM
THREADS=${SLURM_CPUS_PER_TASK:-6}

# Set a writable cache directory for Matplotlib
export MPLCONFIGDIR=$OUTDIR/matplotlib_cache
mkdir -p $MPLCONFIGDIR

# Run MetaQUAST (default behavior)
metaquast.py "$ASSEMBLY" \
    -o "$OUTDIR" \
    --threads "$THREADS"

echo "MetaQUAST finished. Results in: $OUTDIR"
echo "Job ended at: $(date +"%Y-%m-%d %H:%M:%S")"
