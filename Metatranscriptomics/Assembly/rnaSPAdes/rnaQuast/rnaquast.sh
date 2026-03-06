#!/bin/bash
#SBATCH --job-name=rnaQUAST
#SBATCH --output=rnaQUAST_%j.out
#SBATCH --error=rnaQUAST_%j.err
#SBATCH --nodelist=pyky-w003
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=20G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# Input assembly (rnaSPAdes output)
ASSEMBLY="/data_HPC02/alexis_rojasc/Metatranscriptomics/Assembly/rnaSPAdes/rnaSPAdes_out/transcripts.fasta"

# Output directory for rnaQUAST
OUTDIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Assembly/rnaSPAdes/rnaQuast/rnaQuast_out"
mkdir -p "$OUTDIR"

# Use all CPUs requested by SLURM
THREADS=${SLURM_CPUS_PER_TASK:-6}

# Set a writable cache directory for Matplotlib (avoid tmpdir issues)
export MPLCONFIGDIR=$OUTDIR/matplotlib_cache
mkdir -p $MPLCONFIGDIR

# Run rnaQUAST
rnaQUAST.py "$ASSEMBLY" \
    -o "$OUTDIR" \
    --threads "$THREADS"

echo "rnaQUAST finished. Results in: $OUTDIR"
echo "Job ended at: $(date +"%Y-%m-%d %H:%M:%S")"

