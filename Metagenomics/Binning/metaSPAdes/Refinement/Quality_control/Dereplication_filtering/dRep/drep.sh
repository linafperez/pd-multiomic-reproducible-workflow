#!/bin/bash
#SBATCH --job-name=dRep
#SBATCH --output=dRep_%j.out
#SBATCH --error=dRep_%j.err
#SBATCH --nodelist=pyky-w002
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input paths
# -----------------------------
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/DAS_Tool/DAS-Tool_out/DASTool_DASTool_bins"
CHECKM2_REPORT="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/Quality_control/Raw_bin/CheckM2/CheckM2_out/quality_report.tsv"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Binning/metaSPAdes/Refinement/Quality_control/Dereplication_filtering/dRep"
OUTPUT_DIR="$WORKDIR/dRep_out"

# -----------------------------
# 2. Temporary folders 
# -----------------------------
TMP_BASE="/tmp/dRep"
TMP_BINS="$TMP_BASE/Bins"
TMP_OUTPUT="$TMP_BASE/dRep_out"

mkdir -p "$TMP_BASE" "$OUTPUT_DIR" "$TMP_BINS" "$TMP_OUTPUT"

# -----------------------------
# 3. Copy inputs
# -----------------------------
echo "Copying bins to local scratch..."
rsync -a --info=progress2 "$BIN_DIR/" "$TMP_BINS/"

echo "Copying CheckM2 report..."
rsync -a --info=progress2 "$CHECKM2_REPORT" "$TMP_BASE/quality_report.tsv"

# -----------------------------
# 4. Reformat CheckM2 report for dRep
# -----------------------------
echo "Reformatting CheckM2 report into dRep genomeInfo.csv..."

awk -F"\t" 'BEGIN{OFS=","} 
NR==1 {print "genome","completeness","contamination","N50","size","GC","contigs","longest_contig"; next} 
{print $1".fa",$2,$3,$7,$9,$10,$12,$13}' "$TMP_BASE/quality_report.tsv" > "$TMP_BASE/genomeInfo.csv"

echo "Genome info table ready: $TMP_BASE/genomeInfo.csv"
head -n 5 "$TMP_BASE/genomeInfo.csv"

# -----------------------------
# 5. Run dRep (high-quality MAGs)
# -----------------------------
echo "Running dRep dereplicate..."

dRep dereplicate "$TMP_OUTPUT" \
     -g "$TMP_BINS"/*.fa \
     --genomeInfo "$TMP_BASE/genomeInfo.csv" \
     -p "$THREADS" \
     -comp 90 \
     -con 5 \
     -sa 0.995 \
     -nc 0.30 \
     -cm larger \
     --S_algorithm fastANI \
     --multiround_primary_clustering

echo "dRep completed."

# -----------------------------
# 6. Copy results back
# -----------------------------
echo "Copying results to: $OUTPUT_DIR"
rsync -a --info=progress2 "$TMP_OUTPUT/" "$OUTPUT_DIR/"

# -----------------------------
# 7. Cleanup
# -----------------------------
echo "Cleaning up temporary files..."
rm -rf "$TMP_BASE"

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

