#!/bin/bash
#SBATCH --job-name=Tximport
#SBATCH --output=Tximport_%j.out
#SBATCH --error=Tximport_%j.err
#SBATCH --nodelist=pyky-w004
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=1500G
#SBATCH --partition=debug


echo "----------------------------------------"
echo "Job started on: $(date)"

# Path to your R script
R_SCRIPT="/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon/Counts/tximport_salmon.R"

# Run the R script
Rscript "$R_SCRIPT"

# End message
echo "----------------------------------------"
echo "Job finished at: $(date)"
echo "----------------------------------------"

