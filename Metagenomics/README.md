# Shotgun Metagenomics Analysis
This directory contains the workflow used to process shotgun metagenomic sequencing datasets and reconstruct genome-resolved microbiomes from Parkinson’s disease cohorts. The pipeline reproduces the computational procedures used in the study to assemble metagenomes, recover metagenome-assembled genomes (MAGs), perform taxonomic classification, and annotate microbial functions.

The workflow converts raw shotgun sequencing reads into high-quality microbial genomes through assembly, binning, and genome refinement. The resulting genomes are used to characterize microbial community structure at strain resolution and identify functional pathways associated with Parkinson’s disease.

Two independent assembly strategies were implemented to maximize genome recovery:

- **MEGAHIT assembly pipeline**
- **metaSPAdes assembly pipeline**

Recovered genomes from both assemblies were subsequently refined and dereplicated to produce a final non-redundant MAG catalogue.

---

## Pipeline Overview

The metagenomic analysis pipeline consists of the following stages:

1. Download raw shotgun sequencing data
2. Quality control and read filtering
3. Removal of host (human) reads
4. Metagenome assembly
5. Genome binning using multiple algorithms
6. Bin refinement and quality assessment
7. Genome dereplication
8. Taxonomic classification of MAGs
9. Gene prediction and functional annotation
10. Estimation of genome abundance across samples

---

## Software Requirements

The following software versions were used for the analysis.

- FastQC 0.12.1
- fastp 0.23.x
- Bowtie2 2.5.x
- MEGAHIT 1.2.x
- metaSPAdes 3.15.x
- MetaBAT2 2.15
- COMEBin 1.x
- SemiBin2 2.x
- VAMB 4.x
- DAS Tool 1.1.x
- CheckM2 1.x
- GUNC 1.x
- dRep 3.x
- CoverM 0.6.x
- GTDB-Tk 2.x
- eggNOG-mapper 2.x
- GeneMarkS2 1.x

### Reference Databases

- GTDB taxonomy database
- eggNOG functional annotation database
- Human reference genome (for host removal)

---

## Directory Structure

```
Metagenomics
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
│   └── bowtie2.sh
│
├── Assembly
│   ├── MEGAHIT
│   │   ├── MEGAHIT.sh
│   │   └── MetaQuast
│   │       └── metaquast.sh
│   └── metaSPAdes
│       ├── metaspades.sh
│       └── MetaQuast
│           └── metaquast.sh
│
├── Binning
│   ├── MEGAHIT
│   │   ├── Binner
│   │   │   ├── COMEBin
│   │   │   │   └── comebin.sh
│   │   │   ├── MetaBAT2
│   │   │   │   └── metabat2.sh
│   │   │   ├── SemiBin2
│   │   │   │   └── semibin2.sh
│   │   │   └── Vamb
│   │   │       └── vamb.sh
│   │   ├── CoverM
│   │   │   └── coverm.sh
│   │   └── Refinement
│   │       ├── DAS_Tool
│   │       │   └── das_tool.sh
│   │       └── Quality_control
│   │           ├── Clean_bin
│   │           │   ├── CheckM2
│   │           │   │   └── checkm2.sh
│   │           │   └── GUNC
│   │           │       └── gunc.sh
│   │           ├── Dereplication_filtering
│   │           │   └── dRep
│   │           │       └── drep.sh
│   │           └── Raw_bin
│   │               ├── CheckM2
│   │               │   └── checkm2.sh
│   │               └── GUNC
│   │                   └── gunc.sh
│
│   └── metaSPAdes
│       ├── Binner
│       │   ├── COMEBin
│       │   │   └── comebin.sh
│       │   ├── MetaBAT2
│       │   │   └── metabat2.sh
│       │   ├── SemiBin2
│       │   │   └── semibin2.sh
│       │   └── Vamb
│       │       └── vamb.sh
│       ├── CoverM
│       │   └── coverm.sh
│       └── Refinement
│           ├── DAS_Tool
│           │   └── das_tool.sh
│           └── Quality_control
│               ├── Clean_bin
│               │   ├── CheckM2
│               │   │   └── checkm2.sh
│               │   └── GUNC
│               │       └── gunc.sh
│               ├── Dereplication_filtering
│               │   └── dRep
│               │       └── drep.sh
│               └── Raw_bin
│                   ├── CheckM2
│                   │   └── checkm2.sh
│                   └── GUNC
│                       └── gunc.sh
│
├── Features_MAGs
│   └── CoverM
│       └── coverm.sh
│
├── Gene_prediction
│   └── GeneMarkS2
│       └── genemarks2.sh
│
├── Functional_annotation
│   ├── eggmapper.sh
│   └── MAG_eggnog
│       └── merged_annotations.sh
│
└── Taxonomy
    ├── GTDB
    │   └── taxonomy.sh
    └── Phylogenomics
        └── phylo.sh
```

---

## Workflow

### Step 1 — Download Raw Sequencing Data

Raw metagenomic reads are retrieved from public repositories.

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

Initial quality inspection of raw reads:

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

Human reads are removed by aligning sequences against the human reference genome.

```bash
bash Host_removal/bowtie2.sh
```

Output:

```
host_removed_R1.fastq
host_removed_R2.fastq
```

---

### Step 4 — Metagenome Assembly

Two independent assemblers are used to reconstruct metagenomic contigs.

MEGAHIT assembly:

```bash
bash Assembly/MEGAHIT/MEGAHIT.sh
```

metaSPAdes assembly:

```bash
bash Assembly/metaSPAdes/metaspades.sh
```

Assembly quality assessment:

```bash
bash Assembly/MEGAHIT/MetaQuast/metaquast.sh
bash Assembly/metaSPAdes/MetaQuast/metaquast.sh
```

Output:

```
contigs.fa
```

---

### Step 5 — Genome Binning

Genome bins are generated using multiple binning algorithms.

Example commands:

```bash
bash Binning/MEGAHIT/Binner/MetaBAT2/metabat2.sh
bash Binning/MEGAHIT/Binner/COMEBin/comebin.sh
bash Binning/MEGAHIT/Binner/SemiBin2/semibin2.sh
bash Binning/MEGAHIT/Binner/Vamb/vamb.sh
```

Coverage estimation:

```bash
bash Binning/MEGAHIT/CoverM/coverm.sh
```

---

### Step 6 — Bin Refinement

Binning results are merged using DAS Tool.

```bash
bash Binning/MEGAHIT/Refinement/DAS_Tool/das_tool.sh
```

Quality assessment:

```bash
bash Binning/MEGAHIT/Refinement/Quality_control/Raw_bin/CheckM2/checkm2.sh
bash Binning/MEGAHIT/Refinement/Quality_control/Raw_bin/GUNC/gunc.sh
```

Dereplication of high-quality MAGs:

```bash
bash Binning/MEGAHIT/Refinement/Quality_control/Dereplication_filtering/dRep/drep.sh
```

---

### Step 7 — Genome Abundance Estimation

Genome coverage across samples is estimated.

```bash
bash Features_MAGs/CoverM/coverm.sh
```

Output:

```
MAG_abundance.tsv
```

---

### Step 8 — Gene Prediction

Protein-coding genes are predicted from MAG sequences.

```bash
bash Gene_prediction/GeneMarkS2/genemarks2.sh
```

Output:

```
predicted_genes.faa
```

---

### Step 9 — Functional Annotation

Functional annotation of predicted genes.

```bash
bash Functional_annotation/eggmapper.sh
```

Annotation merging:

```bash
bash Functional_annotation/MAG_eggnog/merged_annotations.sh
```

Outputs:

```
gene_annotations.tsv
pathway_annotations.tsv
```

---

### Step 10 — Taxonomic Classification

Taxonomic classification of MAGs using GTDB-Tk.

```bash
bash Taxonomy/GTDB/taxonomy.sh
```

Phylogenomic tree construction:

```bash
bash Taxonomy/Phylogenomics/phylo.sh
```

Outputs:

```
taxonomy_assignments.tsv
phylogenomic_tree.nwk
```

---

## Final Outputs

The metagenomic pipeline produces the following key outputs:

- assembled metagenomic contigs
- high-quality metagenome-assembled genomes (MAGs)
- genome abundance profiles
- predicted microbial genes
- functional annotations
- taxonomic classification of genomes
- phylogenomic relationships

These outputs provide genome-resolved insight into the gut microbiome and serve as the basis for downstream integration with metatranscriptomic and metabolomic datasets.
