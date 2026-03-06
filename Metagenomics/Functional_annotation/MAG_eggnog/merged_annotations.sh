# Define paths
OUTDIR="/data_HPC02/alexis_rojasc/Metagenomics/Functional_annotation/MAG_eggnog"
DEST="/data_HPC02/alexis_rojasc/Metagenomics/Functional_annotation/MAG_eggnog/merged_annotations.tsv"

# Write header (only once)
echo -e "#query\tseed_ortholog\tevalue\tscore\teggNOG_OGs\tmax_annot_lvl\tCOG_category\tDescription\tPreferred_name\tGOs\tEC\tKEGG_ko\tKEGG_Pathway\tKEGG_Module\tKEGG_Reaction\tKEGG_rclass\tBRITE\tKEGG_TC\tCAZy\tBiGG_Reaction\tPFAMs" > "$DEST"

# Append data from each file (skip comment lines and extra headers)
find "$OUTDIR" -type f -name "*.annotations" | sort | while read file; do
    echo "Processing $file"
    grep -v '^#' "$file" >> "$DEST"
done
