#!/bin/bash

# Source directory (with renamed .fastq files)
source_dir="/data_HPC02/alexis_rojasc/Metatranscriptomics/Host_removal/STAR/Raw_data"

# Destination directory for symbolic links
target_dir="/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon/Data"

# Make sure the target directory exists
mkdir -p "$target_dir"

# List all .fastq files in the source directory
files=("$source_dir"/*/*non*/*.fastq)

# Create symbolic links
for file in "${files[@]}"; do
    filename=$(basename "$file")
    ln -s "$file" "${target_dir}/${filename}"
    echo "Symbolic link created: $file -> ${target_dir}/${filename}"
done
