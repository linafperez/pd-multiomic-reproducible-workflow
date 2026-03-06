#!/bin/bash
#SBATCH --job-name=Genemarks2
#SBATCH --output=Genemarks2_%A_%a.out
#SBATCH --error=Genemarks2_%A_%a.err
#SBATCH --nodelist=pyky-w001
#SBATCH --array=1-41%10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --partition=debug

set -euo pipefail

echo "=============================================="
echo "Job started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "SLURM_ARRAY_TASK_ID: $SLURM_ARRAY_TASK_ID"
echo "=============================================="

THREADS=$SLURM_CPUS_PER_TASK

# -----------------------------
# License key setup for GeneMarkS-2
# -----------------------------
export PATH="/data_HPC02/alexis_rojasc/Metagenomics/Gene_prediction/GeneMarkS2:$PATH"
export GMHMMP2_KEY="/data_HPC02/alexis_rojasc/.gmhmmp2_key"

# -----------------------------
# 1. Input / Output Paths
# -----------------------------
BIN_DIR="/data_HPC02/alexis_rojasc/Metagenomics/QC_MAGs/Final_MAGs/dRep/dRep_out/dereplicated_genomes"
WORKDIR="/data_HPC02/alexis_rojasc/Metagenomics/Gene_prediction/GeneMarkS2"
OUTPUT_DIR="$WORKDIR/GeneMarkS2_out"
TMP_BASE="$WORKDIR/tmp"

mkdir -p "$OUTPUT_DIR" "$TMP_BASE"

# -----------------------------
# 2. Gather all MAGs
# -----------------------------
mapfile -t FILES < <(find "$BIN_DIR" -type f \( -name "*.fa" -o -name "*.fasta" \) | sort)
TOTAL=${#FILES[@]}
echo "Found $TOTAL MAGs total."

# -----------------------------
# 3. Define batch range
# -----------------------------
BATCH_SIZE=10
START=$(( (SLURM_ARRAY_TASK_ID - 1) * BATCH_SIZE ))
END=$(( START + BATCH_SIZE - 1 ))
echo "Processing batch $SLURM_ARRAY_TASK_ID: MAGs ${START}-${END}"

# -----------------------------
# 4. Helper functions
# -----------------------------

# Update .faa and .fnn headers
update_fasta_headers() {
    local file="$1"
    local MAG="$2"
    if [ ! -s "$file" ]; then return; fi

    awk -v MAG="$MAG" '
    /^>/ {
        split($2,a," ");          # original contig
        gene_num=substr($1,2);    # sequential gene number
        contig=a[1];
        attrs=""; for(i=3;i<=NF;i++) attrs=attrs" "$i;
        print ">"MAG"|"contig"|"gene_num attrs;
        next
    }
    {print}' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# Update .lst first column with MAG|contig|gene_number
update_lst_headers() {
    local file="$1"
    local MAG="$2"
    if [ ! -s "$file" ]; then return; fi

    awk -v MAG="$MAG" '
    /^#/ {print; next}       # keep comment lines
    /^$/ {next}              # skip empty lines
    {
        contig=$1
        gene_num="NA"
        for(i=1;i<=NF;i++){
            if($i=="gene_id"){
                gene_num=$(i+1)
                gsub(";","",gene_num)
                break
            }
        }
        $1 = MAG "|" contig "|" gene_num
        print
    }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# -----------------------------
# 5. Run GeneMarkS-2 per MAG safely
# -----------------------------
export LC_ALL=C
export LANG=C

for i in $(seq $START $END); do
    if [ $i -ge $TOTAL ]; then
        echo "Reached end of MAG list at index $i."
        break
    fi

    fasta="${FILES[$i]}"
    base=$(basename "$fasta")
    Name="${base%.*}"
    mag_dir="$OUTPUT_DIR/$Name"
    mkdir -p "$mag_dir"

    echo "  -> Processing $Name (MAG $((i+1)) of $TOTAL)"

    if [ -s "$mag_dir/${Name}.faa" ]; then
        echo "  -> SKIP: $Name already processed."
        continue
    fi

    # --- Unique temp directory for this MAG ---
    TMP_DIR=$(mktemp -d "$TMP_BASE/${Name}_XXXX")
    cp "$GMHMMP2_KEY" "$TMP_DIR/.gmhmmp2_key"

    # --- Run GeneMarkS-2 inside temp folder ---
    (
        cd "$TMP_DIR"
        if gms2.pl \
            --seq "$fasta" \
            --genome-type bacteria \
            --threads "$THREADS" \
            --output "$mag_dir/${Name}.lst" \
            --fnn "$mag_dir/${Name}.fnn" \
            --faa "$mag_dir/${Name}.faa" \
            --format gff > "$mag_dir/${Name}.log" 2>&1; then
            echo "  -> SUCCESS: Completed $Name"
        else
            echo "  -> ERROR: Failed to process $Name"
        fi
    )

    # --- Modify headers ---
    update_fasta_headers "$mag_dir/${Name}.faa" "$Name"
    update_fasta_headers "$mag_dir/${Name}.fnn" "$Name"
    update_lst_headers "$mag_dir/${Name}.lst" "$Name"

    # --- Cleanup temp folder ---
    rm -rf "$TMP_DIR"
done

# -----------------------------
# 6. Batch summary
# -----------------------------
SUMMARY_FILE="$OUTPUT_DIR/batch_${SLURM_ARRAY_TASK_ID}_summary.txt"
{
    echo "=============================================="
    echo "Batch $SLURM_ARRAY_TASK_ID Summary"
    echo "Date: $(date)"
    echo "Processed range: ${START}-${END}"
    echo "Output directory: $OUTPUT_DIR"
    echo "=============================================="
} | tee "$SUMMARY_FILE"

echo "Batch $SLURM_ARRAY_TASK_ID completed."
echo "Job finished at: $(date '+%Y-%m-%d %H:%M:%S')"

