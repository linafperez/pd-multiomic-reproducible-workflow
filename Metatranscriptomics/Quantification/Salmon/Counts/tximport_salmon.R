#!/usr/bin/env Rscript

# ============================================================
#  tximport_salmon.R
#  Import Salmon quantifications and summarize to gene level
#  Author: Alexis Felipe Rojas Cruz
#  Date: 2025-10-20
# ============================================================

suppressPackageStartupMessages({
  library(tximport)
  library(dplyr)
})

# -----------------------------
# 1. Define directories
# -----------------------------
salmon_dir <- "/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon/Salmon_out"
tx2gene_file <- "/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon/Counts/MAGxTranscripts_modified.tsv"
output_file <- "/data_HPC02/alexis_rojasc/Metatranscriptomics/Quantification/Salmon/Counts/tximport_results.rds"

cat("Reading quantification files from:\n", salmon_dir, "\n")

# -----------------------------
# 2. Locate Salmon quant.sf files
# -----------------------------
files <- list.files(path = salmon_dir, pattern = "quant.sf", recursive = TRUE, full.names = TRUE)

if (length(files) == 0) {
  stop("No quant.sf files found in ", salmon_dir, ". Please check the path.")
}

cat("Found", length(files), "quant.sf files.\n")

sample_names <- basename(dirname(files))
names(files) <- sample_names

# -----------------------------
# 3. Load transcript-to-gene map
# -----------------------------
cat("Reading tx2gene mapping from:\n", tx2gene_file, "\n")

tx2gene_raw <- read.delim(tx2gene_file, header = FALSE, sep = "", stringsAsFactors = FALSE)

tx2gene <- tx2gene_raw %>%
  dplyr::select(V1, V2) %>%
  dplyr::rename(transcript_id = V1, gene_id = V2)

cat("tx2gene mapping contains", nrow(tx2gene), "unique transcript-gene pairs.\n")
print(tx2gene)

# -----------------------------
# 4. Import Salmon data
# -----------------------------
cat("Starting tximport...\n")

txi <- tximport(
  files = files,
  type = "salmon",
  tx2gene = tx2gene,
  countsFromAbundance = "lengthScaledTPM"
)

cat("tximport completed successfully.\n")

# -----------------------------
# 5. Save results
# -----------------------------
saveRDS(txi, file = output_file)
cat("Saved tximport results to:\n", output_file, "\n")

# -----------------------------
# 6. Session info for reproducibility
# -----------------------------
cat("\nSession Info:\n")
print(sessionInfo())

cat("\nDone.\n")

