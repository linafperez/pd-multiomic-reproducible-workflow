#!/bin/bash
#SBATCH --job-name=sra_ERR_download
#SBATCH --output=sra_ERR_%j.out
#SBATCH --error=sra_ERR_%j.err
#SBATCH --nodelist=pujnodo4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=19G
#SBATCH --partition=debug

# Record start time
start_time=$(date +%s)

# Set the base path for logs and output
LOG_PATH="/opt/data/HPC01A/alexis_rojasc/Metagenomics/EUR/Raw_data"

# Create a directory for the downloaded data
OUTPUT_DIR="${LOG_PATH}/EUR_DATA"
mkdir -p "${OUTPUT_DIR}"
 
# Navigate to the output directory
cd "${OUTPUT_DIR}"
 
# File with ERR accessions (one per line)
ERR_LIST="/opt/data/HPC01A/alexis_rojasc/Metagenomics/EUR/Raw_data/ERR.txt"   
 
# Prefetch: Download each ERR listed in the ERR.txt file
echo "Starting data download from SRA using prefetch..."
while read -r ERR; do
    if [ -n "$ERR" ]; then
        echo "Downloading $ERR..."
        prefetch "$ERR"
        if [ $? -ne 0 ]; then
            echo "Error downloading $ERR" >&2
        fi
    fi
done < "$ERR_LIST"
 
echo "All downloads attempted."
 
# Fastq-dump: Convert downloaded .sra files to FASTQ format
echo "Converting SRA files to FASTQ format using fastq-dump..."
find . -name "*.sra" | while read -r SRA_FILE; do
    fastq-dump --split-3 "$SRA_FILE"
    if [ $? -ne 0 ]; then
        echo "Error during FASTQ conversion for $SRA_FILE" >&2
    fi
done
 
# Record end time
end_time=$(date +%s)
runtime=$((end_time - start_time))
echo "Completed in $runtime seconds"
