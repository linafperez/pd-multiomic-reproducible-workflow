# 16S rRNA Gene Analysis Pipeline

This directory contains the complete workflow used to process 16S rRNA gene sequencing datasets from the European and Latin American Parkinson’s disease cohorts. The pipeline reproduces the exact steps used to generate Amplicon Sequence Variant (ASV) tables and taxonomic profiles used in the study.

The workflow converts raw amplicon sequencing reads into high-resolution ASVs, performs taxonomic classification, and generates microbial community composition profiles.

Two independent pipelines are implemented:

- **EUR cohort** – Pereira et al. (V3–V4 region)
- **LATAM cohort** – Forero-Rodríguez et al. (V4–V5 region)

Because these studies amplified different hypervariable regions of the 16S rRNA gene, the datasets were processed independently but using identical computational procedures.

---

# Pipeline Overview

The pipeline includes the following steps:

1. Download raw sequencing data  
2. Import reads into QIIME2  
3. Quality inspection and demultiplexing  
4. Primer and adapter removal  
5. Denoising with DADA2  
6. Generation of ASVs  
7. Training region-specific taxonomic classifiers  
8. Taxonomic classification  
9. Filtering non-bacterial sequences  

---

# Software Requirements

The following software versions were used for the analysis.
QIIME2 2025.4
FastQC 0.12.1
SRA Toolkit 3.x
Cutadapt 4.x
R 4.5.2


QIIME2 plugins used:
dada2
cutadapt
feature-classifier
taxa
diversity


Reference database:
SILVA 138.2 SSURef NR99

---

# Directory Structure
16S_Metagenomics
│
├── Classifier-training
│ ├── Download
│ │ └── qiime_download.sh
│ └── Curate
│ └── qiime_curate.sh
│
├── EUR
│ ├── Raw_data
│ │ └── sra_tools.sh
│ ├── Import
│ │ ├── qiime_import.sh
│ │ └── Demux
│ │ └── qiime_demux.sh
│ ├── Denoising
│ │ ├── Cutadapt
│ │ │ └── qiime_cutadapt.sh
│ │ ├── DADA
│ │ │ └── qiime_denoise.sh
│ │ └── Summarize
│ │ └── qiime_summarize.sh
│ └── Taxonomy
│ ├── Extract
│ │ └── qiime_extract.sh
│ ├── Train
│ │ └── qiime_train.sh
│ ├── Classification
│ │ └── qiime_classification.sh
│ └── Filtering
│ └── qiime_filtering.sh
│
└── LATAM
├── Raw_data
│ └── sra_tools.sh
├── Import
│ ├── qiime_import.sh
│ └── Demux
│ └── qiime_demux.sh
├── Denoising
│ ├── Cutadapt
│ │ └── qiime_cutadapt.sh
│ ├── DADA
│ │ └── qiime_denoise.sh
│ └── Summarize
│ └── qiime_summarize.sh
└── Taxonomy
├── Extract
│ └── qiime_extract.sh
├── Train
│ └── qiime_train.sh
├── Classification
│ └── qiime_classification.sh
└── Filtering
└── qiime_filtering.sh


---

# Step 1 — Download Raw Sequencing Data

Raw sequencing reads were downloaded from public repositories.

European cohort:

ENA accession: PRJEB27564


Latin American cohort:


NCBI BioProject: PRJNA975118


Example download using SRA Toolkit:


bash Raw_data/sra_tools.sh


Expected output:


sample_R1.fastq
sample_R2.fastq


---

# Step 2 — Import Reads into QIIME2

FASTQ files are imported into QIIME2 artifact format.


bash Import/qiime_import.sh


Output artifact:


demux.qza


---

# Step 3 — Demultiplexing and Quality Inspection

Sequence quality is inspected before denoising.


bash Import/Demux/qiime_demux.sh


Output visualization:


demux.qzv


The file can be inspected with:


qiime tools view demux.qzv


---

# Step 4 — Primer Removal

Primer and adapter sequences are removed using Cutadapt.


bash Denoising/Cutadapt/qiime_cutadapt.sh


Output artifact:


trimmed_sequences.qza


---

# Step 5 — Denoising and ASV Inference

DADA2 performs:

- quality filtering  
- error correction  
- chimera removal  
- ASV inference  


bash Denoising/DADA/qiime_denoise.sh


Outputs:


feature_table.qza
rep_seqs.qza
denoising_stats.qza


---

# Step 6 — Generate Summary Statistics

Summaries of the feature table and representative sequences are generated.


bash Denoising/Summarize/qiime_summarize.sh


Outputs:


feature_table.qzv
rep_seqs.qzv


---

# Step 7 — Download and Prepare Reference Database

Download the SILVA database and prepare it for classifier training.


bash Classifier-training/Download/qiime_download.sh


Curate the reference sequences.


bash Classifier-training/Curate/qiime_curate.sh


---

# Step 8 — Extract Region-Specific Reference Reads

Extract the amplified region of the 16S rRNA gene.


bash Taxonomy/Extract/qiime_extract.sh


---

# Step 9 — Train the Naïve Bayes Classifier

Train the classifier using the region-specific reference sequences.


bash Taxonomy/Train/qiime_train.sh


Output:


classifier.qza


---

# Step 10 — Taxonomic Classification

Assign taxonomy to ASVs using the trained classifier.


bash Taxonomy/Classification/qiime_classification.sh


Outputs:


taxonomy.qza
taxonomy.qzv


---

# Step 11 — Filter Non-Bacterial Sequences

Sequences classified as mitochondria, chloroplasts, or eukaryotes are removed.


bash Taxonomy/Filtering/qiime_filtering.sh


Outputs:


filtered_feature_table.qza
filtered_rep_seqs.qza


---

# Final Outputs

The pipeline generates the following key outputs:


ASV feature table
Representative ASV sequences
Taxonomic assignments
Denoising statistics
Quality control visualizations


These outputs serve as input for downstream statistical analyses including:

- microbial community composition profiling  
- alpha diversity analysis  
- beta diversity analysis  
- differential abundance testing  
- multi-omic integration with metabolomics and metagenomics
