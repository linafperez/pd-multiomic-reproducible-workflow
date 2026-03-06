#!/bin/bash
#SBATCH --job-name=DASTool
#SBATCH --output=DASTool_%j.out
#SBATCH --error=DASTool_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=250G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Data 
# -----------------------------
CONTIGS="/data_HPC02/alexis_rojasc/Metagenomics/Assembly/metaSPAdes/metaSPAdes_out/contigs.fasta"

BIN_TSV_COMEBIN="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/Bin/COMEBin/COMEBin_contigs2bin.tsv"
BIN_TSV_METABAT2="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/Bin/MetaBAT2/MetaBAT2_contigs2bin.tsv"
BIN_TSV_SEMIBIN2="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/Bin/SemiBin2/SemiBin2_contigs2bin.tsv"
BIN_TSV_VAMB="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/Bin/Vamb/Vamb_contigs2bin.tsv"

WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool"
OUTPUT_DIR="$WORKDIR/DAS-Tool_out"

# -----------------------------
# 2. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/DASTool"
TMP_CONTIGS="$TMP_BASE/Contigs"
TMP_BINS="$TMP_BASE/Bins"
TMP_OUTPUT="$TMP_BASE/DAS-Tool_out"

mkdir -p "$TMP_BASE" "$OUTPUT_DIR" "$TMP_CONTIGS" "$TMP_BINS" "$TMP_OUTPUT"

# -----------------------------
# 3. Copy inputs
# -----------------------------

echo "Copying contigs FASTA: $(basename "$CONTIGS")"
rsync -a --info=progress2 "$CONTIGS" "$TMP_CONTIGS/"

echo "Copying bins TSVs to local disk..."

echo "Copying COMEBin TSV: $(basename "$BIN_TSV_COMEBIN")"
rsync -a --info=progress2 "$BIN_TSV_COMEBIN" "$TMP_BINS/"

echo "Copying MetaBAT2 TSV: $(basename "$BIN_TSV_METABAT2")"
rsync -a --info=progress2 "$BIN_TSV_METABAT2" "$TMP_BINS/"

echo "Copying SemiBin2 TSV: $(basename "$BIN_TSV_SEMIBIN2")"
rsync -a --info=progress2 "$BIN_TSV_SEMIBIN2" "$TMP_BINS/"

echo "Copying Vamb TSV: $(basename "$BIN_TSV_VAMB")"
rsync -a --info=progress2 "$BIN_TSV_VAMB" "$TMP_BINS/"

# -----------------------------
# 4. Run DAS Tool
# -----------------------------
echo "Running DAS Tool..."


DAS_Tool -i "$TMP_BINS/$(basename "$BIN_TSV_COMEBIN"),$TMP_BINS/$(basename "$BIN_TSV_METABAT2"),$TMP_BINS/$(basename "$BIN_TSV_SEMIBIN2"),$TMP_BINS/$(basename "$BIN_TSV_VAMB")" \
         -l COMEBin,MetaBAT2,SemiBin2,Vamb \
         -c "$TMP_CONTIGS/$(basename "$CONTIGS")" \
         -o "$TMP_OUTPUT/DASTool" \
         --threads "$THREADS" \
	     --search_engine diamond \
         --write_bins

echo "DAS Tool completed."

# -----------------------------
# 5. Copy results back
# -----------------------------
echo "Copying results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# -----------------------------
# 6. Cleanup
# -----------------------------
echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

