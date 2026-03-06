#!/bin/bash

# Define directories
PROTEIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Gene_prediction/GeneMarkS2/GeneMarkS2_out"
TARGET_DIR="/data_HPC02/alexis_rojasc/Metatranscriptomics/Transcript_prediction/Diamond/DB"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# ---------------------------------
# 1. Gather all MAG nucleotide files
# ---------------------------------
mapfile -t FILES < <(find "$PROTEIN_DIR" -type f -name "*.faa" | sort)
TOTAL=${#FILES[@]}
echo "Found $TOTAL MAG protein (.faa) files total."

# ---------------------------------
# 2. Copy files to target directory
# ---------------------------------
for FILE in "${FILES[@]}"; do
    BASENAME=$(basename "$FILE")
    cp "$FILE" "$TARGET_DIR/$BASENAME"
done

echo "Copied $TOTAL .faa files to $TARGET_DIR"

