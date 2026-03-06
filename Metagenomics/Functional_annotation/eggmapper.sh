#!/bin/bash
#SBATCH --job-name=EggNOG_mapper
#SBATCH --output=EggNOG_%A_%a.out
#SBATCH --error=EggNOG_%A_%a.err
#SBATCH --nodelist=pyky-w002
#SBATCH --array=1-41%10          
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=30G
#SBATCH --partition=debug

set -euo pipefail

echo "=============================================="
echo "Job started at: $(date +"%Y-%m-%d %H:%M:%S")"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "=============================================="

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# 1. Input / Output Paths
# -----------------------------
PROTEIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Gene_prediction/GeneMarkS2/GeneMarkS2_out"
OUTPUT_BASE="/data_HPC02/alexis_rojasc/Metagenomics/Functional_annotation/EggNOG_out"
DB_DIR="/data_HPC02/alexis_rojasc/Metagenomics/Functional_annotation/eggnog_db"

mkdir -p "$OUTPUT_BASE"

# -----------------------------
# 2. Gather all MAG protein files
# -----------------------------
mapfile -t FILES < <(find "$PROTEIN_DIR" -type f -name "*.faa" | sort)
TOTAL=${#FILES[@]}
echo "Found $TOTAL MAGs protein FASTA files total."

# -----------------------------
# 3. Define batch range
# -----------------------------
BATCH_SIZE=10
START=$(( (SLURM_ARRAY_TASK_ID - 1) * BATCH_SIZE ))
END=$(( START + BATCH_SIZE - 1 ))

echo "Processing batch $SLURM_ARRAY_TASK_ID: MAGs ${START}-${END}"

# -----------------------------
# 4. Run EggNOG-mapper per MAG
# -----------------------------
for i in $(seq $START $END); do
    if [ $i -ge $TOTAL ]; then
        echo "Reached end of protein list at index $i."
        break
    fi

    protein_faa="${FILES[$i]}"
    base=$(basename "$protein_faa")
    Name="${base%.*}"
    mag_out="$OUTPUT_BASE/$Name"
    
    mkdir -p "$mag_out"

    echo "  -> Annotating $Name (MAG $((i+1)) of $TOTAL)"

    # Skip already annotated MAGs (correct filename)
    if [ -f "$mag_out/${Name}.emapper.annotations" ] && [ -s "$mag_out/${Name}.emapper.annotations" ]; then
        echo "  -> SKIP: $Name already annotated."
        continue
    fi

    # Run EggNOG-mapper
    emapper.py \
        -i "$protein_faa" \
	    -m diamond \
        --output "$Name" \
        --output_dir "$mag_out" \
        --itype proteins \
        --cpu "$THREADS" \
        --data_dir "$DB_DIR" \
        --usemem 

    echo "  -> Completed annotation for $Name"
done

# -----------------------------
# 5. Batch summary
# -----------------------------
SUMMARY_FILE="$OUTPUT_BASE/batch_${SLURM_ARRAY_TASK_ID}_summary.txt"

{
    echo "=============================================="
    echo "Batch $SLURM_ARRAY_TASK_ID Summary"
    echo "Date: $(date)"
    echo "Processed range: ${START}-${END}"
    echo "Output base: $OUTPUT_BASE"
    echo "=============================================="
} | tee "$SUMMARY_FILE"

echo "Batch $SLURM_ARRAY_TASK_ID completed."
echo "Job finished at: $(date +"%Y-%m-%d %H:%M:%S")"

