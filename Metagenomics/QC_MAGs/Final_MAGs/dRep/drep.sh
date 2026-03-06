#!/bin/bash
#SBATCH --job-name=dRep
#SBATCH --output=dRep_%j.out
#SBATCH --error=dRep_%j.err
#SBATCH --nodelist=pyky-w001
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G
#SBATCH --partition=debug

set -euo pipefail

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input paths
# -----------------------------
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/Bin_merged"
CHECKM2_REPORT="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/Quality_checkm2/merged_quality_report.txt"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep"
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
rsync -a --info=progress2 "$CHECKM2_REPORT" "$TMP_BASE/merged_quality_report.txt"

# -----------------------------
# 4. Reformat CheckM2 report for dRep
# -----------------------------
echo "Reformatting CheckM2 report into dRep genomeInfo.csv..."

awk -F"\t" 'BEGIN{OFS=","}
NR==1 {print "genome","completeness","contamination","N50","size","GC","contigs","longest_contig"; next}
{print $1".fa",$2,$3,$10,$12,$13,$15,$16}' "$TMP_BASE/merged_quality_report.txt" > "$TMP_BASE/genomeInfo.csv"

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

