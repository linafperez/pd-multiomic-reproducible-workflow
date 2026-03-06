#!/bin/bash
#SBATCH --job-name=FastP
#SBATCH --output=FastP_%j.out
#SBATCH --error=FastP_%j.err
#SBATCH --nodelist=pujnodo4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=19G
#SBATCH --partition=debug

# Directories
FASTQ_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Raw_data/Rename"
OUTPUT_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Quality_control/FastP/Results"

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Start timing the execution
start_time=$(date +%s)

# Loop through all fastq files in the input directory
for file1 in "${INPUT_DIR}"/*_1.fastq; do
  # Extract the sample name (removes _1.fastq)
  sample_name=$(basename "$file1" _1.fastq)

  # Define the corresponding reverse read file
  file2="${INPUT_DIR}/${sample_name}_2.fastq"

  # Define output file names
  out_file1="${OUTPUT_DIR}/${sample_name}_trimmed_1.fastq"
  out_file2="${OUTPUT_DIR}/${sample_name}_trimmed_2.fastq"
  json_report="${OUTPUT_DIR}/${sample_name}_fastp.json"
  html_report="${OUTPUT_DIR}/${sample_name}_fastp.html"

  # Run fastp with adapter auto-detection and poly-X trimming
  fastp --in1 "${file1}" --in2 "${file2}" \
        --out1 "${out_file1}" --out2 "${out_file2}" \
        --qualified_quality_phred 30 \
        --length_required 30 \
        --detect_adapter_for_pe \
        --trim_poly_g \
        --trim_poly_x \
        --cut_right --cut_right_window_size 4 --cut_right_mean_quality 30 \
        --thread 6 \
        --json "${json_report}" \
        --html "${html_report}"

done

# End timing the execution
end_time=$(date +%s)

# Calculate elapsed time
elapsed_time=$((end_time - start_time))

# Print the elapsed time
echo "Execution time: ${elapsed_time} seconds"