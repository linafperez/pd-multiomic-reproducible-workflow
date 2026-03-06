#!/bin/bash
#SBATCH --job-name=Bowtie2_HostRemoval
#SBATCH --output=Bowtie2_%j.out
#SBATCH --error=Bowtie2_%j.err
#SBATCH --nodelist=pujnodo4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=19G
#SBATCH --partition=debug

# =========================================================
# Human host read removal for paired-end shotgun metagenomics
# =========================================================

# ===============================
# Directories
# ===============================
INPUT_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Quality_control/FastP/Results"
GENOME_FASTA="/data_HPC02/alexis_rojasc/Metagenomics/Host_removal/Bowtie2/Reference/GRCh38.primary_assembly.genome.fa"
INDEX_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Host_removal/Bowtie2/Human_index"
INDEX_PREFIX="GRCh38"
HUMAN_INDEX="${INDEX_DIR}/${INDEX_PREFIX}"
OUTPUT_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Host_removal/Bowtie2/Results"

mkdir -p "${OUTPUT_DIR}" "${INDEX_DIR}"

# ===============================
# Start timer
# ===============================
start_time=$(date +%s)

echo "======================================"
echo "Human host removal with Bowtie2"
echo "======================================"

# =========================================================
# Build Bowtie2 index (only once)
# =========================================================
if [ ! -f "${HUMAN_INDEX}.1.bt2" ]; then
  echo "[INFO] Building Bowtie2 index for human genome..."

  bowtie2-build \
    --threads 24 \
    "${GENOME_FASTA}" \
    "${HUMAN_INDEX}"

  echo "[INFO] Index completed."
else
  echo "[INFO] Existing index detected. Skipping build."
fi

# =========================================================
# Host removal for each paired sample
# =========================================================
for file1 in "${INPUT_DIR}"/*_trimmed_1.fastq; do

  sample_name=$(basename "$file1" _trimmed_1.fastq)
  file2="${INPUT_DIR}/${sample_name}_trimmed_2.fastq"

  if [[ ! -f "$file2" ]]; then
    echo "[WARNING] Missing pair for ${sample_name}, skipping."
    continue
  fi

  echo "--------------------------------------"
  echo "[INFO] Processing sample: ${sample_name}"
  echo "--------------------------------------"

  nonhost_prefix="${OUTPUT_DIR}/${sample_name}_nonhost"

  bowtie2 \
    -x "${HUMAN_INDEX}" \
    -1 "${file1}" \
    -2 "${file2}" \
    --very-sensitive-local \
    --threads 24 \
    --phred33 \
    --un-conc-gz "${nonhost_prefix}.fastq" \
    -S /dev/null

  echo "[INFO] Finished sample: ${sample_name}"
  echo ""

done

# =========================================================
# End timer
# =========================================================
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

echo "======================================"
echo "[INFO] Execution time: ${elapsed_time} seconds"
echo "======================================"

