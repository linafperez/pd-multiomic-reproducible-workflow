#!/bin/bash
#SBATCH --job-name=MAGxTranscripts
#SBATCH --output=MAGxTranscripts_%j.out
#SBATCH --error=MAGxTranscripts_%j.err
#SBATCH --nodelist=pyky-w001
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=40G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"
THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input / Output paths
# -----------------------------
QUERY_PEP="/data_HPC02/alexis_rojasc/Metatranscriptomics/Transcript_prediction/TransDecoder/Results/transcripts.fasta.transdecoder.pep"
DB_PATH="/data_HPC02/alexis_rojasc/Metatranscriptomics/Transcript_prediction/Diamond/DB/MAGs_protein.dmnd"
OUTDIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Transcript_prediction/Diamond/Results"
OUTFILE="$OUTDIR/MAGxTranscripts"

mkdir -p "$OUTDIR"

# -----------------------------
# 2. Run DIAMOND blastp (high-confidence)
# -----------------------------
echo "Running DIAMOND blastp (high-confidence mode)..."

diamond blastp \
    --db "$DB_PATH" \
    --query "$QUERY_PEP" \
    --out "$OUTFILE.daa" \
    --outfmt 100 \
    --threads "$THREADS" \
    --evalue 1e-10 \
    --id 95 \
    --query-cover 90 \
    --subject-cover 90 \
    --max-target-seqs 1 \
    --very-sensitive \
    --masking 1 \
    --block-size 10.0 \
    --index-chunks 1

# -----------------------------
# 3. Convert DAA to tabular output
# -----------------------------
echo "Converting DAA to tabular format..."

diamond view \
    --daa "$OUTFILE.daa" \
    --out "$OUTFILE.tsv" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore

# -----------------------------
# 4. Done
# -----------------------------
echo "DIAMOND (high-confidence mode) completed successfully."
echo "Results table: $OUTFILE.tsv"
echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

