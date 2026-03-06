#!/bin/bash
#SBATCH --job-name=STAR_microbiome
#SBATCH --output=STAR_microbiome_%j.out
#SBATCH --error=STAR_microbiome_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=80G
#SBATCH --partition=debug

set -euo pipefail
#trap 'echo "Cleaning up..."; rm -rf "$TMP_BASE"' EXIT

echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"

# -----------------------------
# 0. Configuration
# -----------------------------
DATA_DIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Host_removal/STAR/Data"
GENOME_DIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Host_removal/STAR/Genome"
OUTPUT_DIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Host_removal/STAR/STAR_output"

GENOME_IDX_DIR="$GENOME_DIR/STAR_IDX"

TMP_BASE="/tmp/STAR"
TMP_DATA="$TMP_BASE/Data"
TMP_GENOME="$TMP_BASE/Genome"
TMP_OUTPUT="$TMP_BASE/STAR_output"
TMP_GENOME_BAM="$TMP_OUTPUT/Genome_bam"
TMP_UNMAPPED="$TMP_OUTPUT/Unmapped"

mkdir -p "$TMP_DATA" "$TMP_GENOME" "$TMP_OUTPUT" "$TMP_GENOME_BAM" "$TMP_UNMAPPED"

# -----------------------------
# 1. Copy FASTQ files to node
# -----------------------------
echo "Copying FastQ files to node..."
cp -Lr "$DATA_DIR"/* "$TMP_DATA"/

# -----------------------------
# 2. Copy genome files to node
# -----------------------------
echo "Copying genome reference to node..."
rsync -a --info=progress2 "$GENOME_DIR"/ "$TMP_GENOME"/

GENOME_FA=$(find "$TMP_GENOME" -maxdepth 1 -name "*.fa*" | head -n1)
GENOME_GTF=$(find "$TMP_GENOME" -maxdepth 1 -name "*.gtf" | head -n1)

if [[ -z "$GENOME_FA" || -z "$GENOME_GTF" ]]; then
    echo "Error: Genome FASTA or GTF not found in $GENOME_DIR"
    exit 1
fi

# -----------------------------
# 3. Generate STAR index if needed
# -----------------------------
if [[ ! -f "$GENOME_IDX_DIR/SA" ]]; then
    echo "Generating STAR genome index..."
    mkdir -p "$GENOME_IDX_DIR"
    STAR --runThreadN 24 \
         --runMode genomeGenerate \
         --genomeDir "$GENOME_IDX_DIR" \
         --genomeFastaFiles "$GENOME_FA" \
         --sjdbGTFfile "$GENOME_GTF" \
         --sjdbOverhang 149
else
    echo "Using existing STAR index at $GENOME_IDX_DIR"
fi

# -----------------------------
# 4. Run STAR alignments
# -----------------------------
for fastq_file_R1 in "$TMP_DATA"/*_1.fastq; do
    base_name=$(basename "$fastq_file_R1" | sed 's/_1\.fastq$//')
    fastq_file_R2="$TMP_DATA/${base_name}_2.fastq"

    echo "Checking files: $fastq_file_R1 and $fastq_file_R2"
    if [[ ! -f "$fastq_file_R2" ]]; then
        echo "Error: Paired file for $(basename "$fastq_file_R1") not found. Skipping..."
        continue
    fi

    echo "Running STAR alignment for $base_name..."

    STAR --runMode alignReads \
         --runThreadN 24 \
         --genomeDir "$GENOME_IDX_DIR" \
         --twopassMode Basic \
         --readFilesIn "$fastq_file_R1" "$fastq_file_R2" \
         --sjdbScore 1 \
         --outFileNamePrefix "$TMP_OUTPUT"/"$base_name"_ \
         --outReadsUnmapped Fastx \
	 --outSAMtype BAM Unsorted  \
         --outFilterType BySJout \
         --outFilterMultimapNmax 20 \
         --outFilterMismatchNmax 999 \
         --outFilterMismatchNoverReadLmax 0.04 \
         --alignSJoverhangMin 8 \
         --alignSJDBoverhangMin 1 \
         --alignIntronMin 20 \
         --alignIntronMax 1000000 \
         --alignMatesGapMax 1000000

    # Move STAR outputs
    mv "$TMP_OUTPUT"/"$base_name"_Aligned.out.bam "${TMP_GENOME_BAM}/"
    mv "$TMP_OUTPUT"/"$base_name"_Unmapped.out.mate* "${TMP_UNMAPPED}/"

done

# -----------------------------
# 5. Copy results back to storage
# -----------------------------
echo "Copying results back to storage..."

rsync -a --info=progress2 "$TMP_OUTPUT"/ "$OUTPUT_DIR"/
rsync -a --info=progress2 "$TMP_STAR_IDX"/ "$GENOME_DIR"/

echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"
