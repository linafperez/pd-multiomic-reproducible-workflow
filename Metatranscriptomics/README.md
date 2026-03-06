# Metatranscriptomics Analysis
This directory contains the workflow used to process metatranscriptomic sequencing datasets and characterize the functional activity of the gut microbiome in Parkinson’s disease cohorts. The pipeline reproduces the computational procedures used in the study to assemble transcripts, predict coding sequences, quantify gene expression, and identify differentially expressed microbial genes.

The workflow converts raw RNA-seq reads into transcript-level and gene-level expression profiles through a combination of quality control, host removal, transcriptome assembly, coding sequence prediction, and expression quantification. The resulting expression matrices are used to identify microbial genes whose transcriptional activity differs between Parkinson’s disease and healthy control samples.

The metatranscriptomic pipeline complements the metagenomic genome reconstruction workflow by providing functional evidence of gene activity across reconstructed microbial genomes.

---

## Pipeline Overview

The metatranscriptomic analysis pipeline consists of the following stages:

1. Download raw metatranscriptomic sequencing data
2. Quality control and read filtering
3. Removal of host (human) reads
4. Removal of ribosomal RNA sequences
5. Transcriptome assembly
6. Prediction of coding sequences
7. Functional alignment against microbial proteins
8. Quantification of transcript abundance
9. Differential gene expression analysis

---

## Software Requirements

The following software versions were used for the analysis.

- FastQC 0.12.1
- fastp 0.23.x
- STAR 2.7.x
- SortMeRNA 4.x
- RNA-SPAdes 3.15.x
- TransDecoder 5.x
- DIAMOND 2.x
- Salmon 1.10.x
- R 4.5.2

### R Packages

- DESeq2
- tximport
- tidyverse
- data.table
- ggplot2

### Reference Databases

- Human reference genome (for host removal)
- Protein database derived from reconstructed MAGs

---

## Directory Structure

```
Metatranscriptomics
│
├── Raw_data
│   └── sra-tools.sh
│
├── Quality_control
│   ├── FastQC_raw
│   │   └── fastqc_raw.sh
│   ├── FastP
│   │   └── fastp.sh
│   └── FastQC_clean
│       └── fastqc_clean.sh
│
├── Host_removal
│   └── STAR
│       ├── Data
│       │   └── symlinks.sh
│       └── STAR.sh
│
├── rRNA_removal
│   └── sortmerna.sh
│
├── Assembly
│   └── rnaSPAdes
│       ├── rnaspades.sh
│       └── rnaQuast
│           └── rnaquast.sh
│
├── Transcript_prediction
│   ├── TransDecoder
│   │   └── transdecoder.sh
│   └── Diamond
│       ├── DB
│       │   └── MAG-protein_copy.sh
│       └── magxtrans.sh
│
├── Quantification
│   └── Salmon
│       ├── Data
│       │   └── symlinks.sh
│       ├── Counts
│       │   ├── import.sh
│       │   └── tximport_salmon.R
│       └── meta_salmon.sh
│
└── Expression
    └── Meta-PD_DESeq2.Rmd
```

---

## Workflow

### Step 1 — Download Raw Sequencing Data

Raw metatranscriptomic reads are retrieved from public repositories.

```bash
bash Raw_data/sra-tools.sh
```

Expected output:

```
sample_R1.fastq
sample_R2.fastq
```

---

### Step 2 — Quality Control

Initial quality inspection of raw RNA sequencing reads:

```bash
bash Quality_control/FastQC_raw/fastqc_raw.sh
```

Read trimming and filtering:

```bash
bash Quality_control/FastP/fastp.sh
```

Quality inspection of cleaned reads:

```bash
bash Quality_control/FastQC_clean/fastqc_clean.sh
```

Outputs:

```
clean_R1.fastq
clean_R2.fastq
```

---

### Step 3 — Host Read Removal

Human reads are removed by aligning sequences against the human reference genome using STAR.

Prepare input data:

```bash
bash Host_removal/STAR/Data/symlinks.sh
```

Run alignment and filtering:

```bash
bash Host_removal/STAR/STAR.sh
```

Output:

```
host_removed_R1.fastq
host_removed_R2.fastq
```

---

### Step 4 — rRNA Removal

Ribosomal RNA reads are removed to enrich for messenger RNA.

```bash
bash rRNA_removal/sortmerna.sh
```

Output:

```
non_rRNA_reads.fastq
```

---

### Step 5 — Transcriptome Assembly

Transcript sequences are reconstructed using RNA-SPAdes.

```bash
bash Assembly/rnaSPAdes/rnaspades.sh
```

Assembly quality assessment:

```bash
bash Assembly/rnaSPAdes/rnaQuast/rnaquast.sh
```

Output:

```
transcripts.fasta
```

---

### Step 6 — Prediction of Coding Sequences

Open reading frames are predicted from assembled transcripts.

```bash
bash Transcript_prediction/TransDecoder/transdecoder.sh
```

Output:

```
predicted_proteins.faa
```

---

### Step 7 — Functional Alignment Against Microbial Proteins

Predicted proteins are aligned against a protein database derived from reconstructed microbial genomes.

Prepare protein database:

```bash
bash Transcript_prediction/Diamond/DB/MAG-protein_copy.sh
```

Run alignment:

```bash
bash Transcript_prediction/Diamond/magxtrans.sh
```

Output:

```
diamond_matches.tsv
```

---

### Step 8 — Transcript Quantification

Transcript abundance is estimated using Salmon.

Prepare input files:

```bash
bash Quantification/Salmon/Data/symlinks.sh
```

Run quantification:

```bash
bash Quantification/Salmon/meta_salmon.sh
```

Output:

```
quant.sf
```

Import counts into R:

```bash
bash Quantification/Salmon/Counts/import.sh
```

Generate count matrices:

```bash
Rscript Quantification/Salmon/Counts/tximport_salmon.R
```

Output:

```
gene_expression_matrix.tsv
```

---

### Step 9 — Differential Expression Analysis

Differential expression analysis is performed using DESeq2.

```bash
Rscript Expression/Meta-PD_DESeq2.Rmd
```

Outputs:

```
differential_expression_results.tsv
volcano_plot.pdf
heatmap_expression.pdf
```

---

## Final Outputs

The metatranscriptomic pipeline generates the following key outputs:

- assembled microbial transcripts
- predicted protein-coding genes
- transcript abundance estimates
- gene expression matrices
- differential expression results between Parkinson’s disease and control samples

These outputs provide functional insights into microbial gene activity and are integrated with metagenomic and metabolomic datasets in the multi-omic analysis framework.
