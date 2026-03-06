# Genome-resolved multi-omic workflow for Parkinson’s disease
Parkinson’s disease (PD) is increasingly hypothesized to originate in the gut, yet the mechanistic links between microbiome dysbiosis and systemic neurodegeneration remain poorly resolved. This study addresses that gap by performing a genome-resolved multi-omic meta-analysis integrating Mendelian randomization (MR), shotgun metagenomics, metatranscriptomics, 16S rRNA gene profiling, and untargeted metabolomics across European and Latin American cohorts. By reconstructing 356 high-quality metagenome-assembled genomes (MAGs) and linking strain-level microbial activity to host lipid remodeling, the work defines a functional immunometabolic interface connecting gut microbial programs to systemic lipid dysregulation in PD. This repository contains the fully reproducible computational workflow underlying that analysis, organized by omic layer and methodological order, enabling stepwise reprocessing, genome reconstruction, differential profiling, and cross-layer functional integration from raw data to mechanistic interpretation.

## Table of Contents
1. [Study Design](#study-design)  
2. [Repository Structure](#repository-structure)  
3. [Workflow Description](#workflow-description)  
   - [3.1. Mendelian Randomization (MR)](#31-mendelian-randomization-mr)  
   - [3.2. Shotgun Metagenomics](#32-shotgun-metagenomics)  
   - [3.3. Metatranscriptomics](#33-metatranscriptomics)  
   - [3.4. 16S rRNA Gene Analysis](#34-16s-rrna-gene-analysis)  
   - [3.5. Metabolomics](#35-metabolomics)  
   - [3.6. Multi-omic Integration](#36-multi-omic-integration)  
4. [Software and Dependencies](#software-and-dependencies)  
5. [Data Availability](#data-availability)  
6. [Reproducibility Notes](#reproducibility-notes)  
7. [Citation](#citation)

## Study Design

This study performs a genome-resolved multi-omic meta-analysis to investigate the role of the gut microbiome in Parkinson’s disease (PD). The workflow integrates multiple omic layers to reconstruct microbial genomic structure, functional activity, and host metabolic interactions.

The analysis combines datasets from independent cohorts in Europe and Latin America and integrates five complementary analytical layers:

1. Mendelian Randomization (MR)
2. Shotgun metagenomics
3. Metatranscriptomics
4. 16S rRNA gene sequencing
5. Untargeted metabolomics

All analyses were performed independently for each omic layer and subsequently integrated to identify strain-resolved microbial signatures associated with Parkinson’s disease.

### Included cohorts

The study includes publicly available datasets from three studies:

| Study | Region | Omics | Samples |
|------|------|------|------|
| Villette et al. | Europe | Shotgun metagenomics + metatranscriptomics | 46 PD / 49 HC |
| Pereira et al. | Europe | 16S rRNA sequencing + metabolomics | 63 PD / 61 HC |
| Forero-Rodríguez et al. | Latin America | 16S rRNA sequencing | 25 PD / 25 HC |

Microbiome data were derived from fecal samples, while metabolomic profiles were obtained from serum samples.

### Study workflow

The analytical workflow was designed to systematically reconstruct the functional landscape of the Parkinson’s disease gut microbiome through a multi-omic integration framework. First, raw sequencing and metabolomic datasets were retrieved from publicly available repositories corresponding to the selected cohorts. Each omic layer was then processed independently using standardized bioinformatic pipelines to ensure methodological consistency and reproducibility. Shotgun metagenomic data were used to reconstruct microbial genomes through the assembly and binning of metagenome-assembled genomes (MAGs), enabling genome-resolved characterization of the microbial community. 

To capture the functional activity of these genomes, metatranscriptomic data were analyzed to quantify gene expression profiles, while untargeted metabolomics provided a complementary view of the systemic metabolic phenotype associated with disease. In parallel, 16S rRNA gene sequencing datasets were processed to identify amplicon sequence variants (ASVs) and characterize community-level compositional patterns across cohorts. 

Finally, a cross-platform harmonization strategy was implemented to link MAG-derived taxa with ASV-level features and integrate these microbial signals with metabolite profiles. This multi-layer integration enabled the reconstruction of functional relationships connecting microbial genomes, encoded genes, metabolic pathways, and host metabolites, ultimately providing a systems-level view of microbiome–host interactions associated with Parkinson’s disease.

## Repository Structure
## Repository Structure

The repository is organized according to the different omic layers analyzed in this study and the final multi-omic integration steps. Each top-level directory corresponds to a specific analytical component of the workflow, and contains the scripts required to reproduce the analyses described in the manuscript.

The full directory structure of the repository is shown below.

```text
.
├── 16S_Metagenomics
│   ├── Classifier-training
│   │   ├── Curate
│   │   │   └── qiime_curate.sh
│   │   └── Download
│   │       └── qiime_download.sh
│   ├── EUR
│   │   ├── Denoising
│   │   │   ├── Cutadapt
│   │   │   │   └── qiime_cutadapt.sh
│   │   │   ├── DADA
│   │   │   │   └── qiime_denoise.sh
│   │   │   └── Summarize
│   │   │       └── qiime_summarize.sh
│   │   ├── Import
│   │   │   ├── Demux
│   │   │   │   └── qiime_demux.sh
│   │   │   └── qiime_import.sh
│   │   ├── Raw_data
│   │   │   └── sra_tools.sh
│   │   └── Taxonomy
│   │       ├── Classification
│   │       │   └── qiime_classification.sh
│   │       ├── Extract
│   │       │   └── qiime_extract.sh
│   │       ├── Filtering
│   │       │   └── qiime_filtering.sh
│   │       └── Train
│   │           └── qiime_train.sh
│   └── LATAM
│       ├── Denoising
│       │   ├── Cutadapt
│       │   │   └── qiime_cutadapt.sh
│       │   ├── DADA
│       │   │   └── qiime_denoise.sh
│       │   └── Summarize
│       │       └── qiime_summarize.sh
│       ├── Import
│       │   ├── Demux
│       │   │   └── qiime_demux.sh
│       │   └── qiime_import.sh
│       ├── Raw_data
│       │   └── sra-tools.sh
│       └── Taxonomy
│           ├── Classification
│           │   └── qiime_classification.sh
│           ├── Extract
│           │   └── qiime_extract.sh
│           ├── Filtering
│           │   └── qiime_filtering.sh
│           └── Train
│               └── qiime_train.sh
├── Integration
│   ├── MAG-ASV
│   │   └── MAG_ASV-integration.Rmd
│   └── MAG-genes-metabolite
│       └── Microbe-gene-metabolite.Rmd
├── MR
│   ├── Exposure
│   │   └── SNPs_exposure.R
│   ├── MR
│   │   └── MR.Rmd
│   └── Outcome
│       └── SNP_outcome.R
├── Metabolomics
│   └── Metabolomics_analysis.Rmd
├── Metagenomics
│   ├── Assembly
│   │   ├── MEGAHIT
│   │   │   ├── MEGAHIT.sh
│   │   │   └── MetaQuast
│   │   │       └── metaquast.sh
│   │   └── metaSPAdes
│   │       ├── MetaQuast
│   │       │   └── metaquast.sh
│   │       └── metaspades.sh
│   ├── Binning
│   │   ├── MEGAHIT
│   │   │   ├── Binner
│   │   │   │   ├── COMEBin
│   │   │   │   │   └── comebin.sh
│   │   │   │   ├── MetaBAT2
│   │   │   │   │   └── metabat2.sh
│   │   │   │   ├── SemiBin2
│   │   │   │   │   └── semibin2.sh
│   │   │   │   └── Vamb
│   │   │   │       └── vamb.sh
│   │   │   ├── CoverM
│   │   │   │   ├── coverm.sh
│   │   │   │   └── fix-vamb.py
│   │   │   └── Refinement
│   │   │       ├── DAS_Tool
│   │   │       │   └── das_tool.sh
│   │   │       └── Quality_control
│   │   │           ├── Clean_bin
│   │   │           │   ├── CheckM2
│   │   │           │   │   └── checkm2.sh
│   │   │           │   └── GUNC
│   │   │           │       └── gunc.sh
│   │   │           ├── Dereplication_filtering
│   │   │           │   └── dRep
│   │   │           │       └── drep.sh
│   │   │           └── Raw_bin
│   │   │               ├── CheckM2
│   │   │               │   └── checkm2.sh
│   │   │               └── GUNC
│   │   │                   └── gunc.sh
│   │   └── metaSPAdes
│   │       ├── Binner
│   │       │   ├── COMEBin
│   │       │   │   └── comebin.sh
│   │       │   ├── MetaBAT2
│   │       │   │   └── metabat2.sh
│   │       │   ├── SemiBin2
│   │       │   │   └── semibin2.sh
│   │       │   └── Vamb
│   │       │       └── vamb.sh
│   │       ├── CoverM
│   │       │   ├── coverm.sh
│   │       │   └── fix-vamb.py
│   │       └── Refinement
│   │           ├── DAS_Tool
│   │           │   └── das_tool.sh
│   │           └── Quality_control
│   │               ├── Clean_bin
│   │               │   ├── CheckM2
│   │               │   │   └── checkm2.sh
│   │               │   └── GUNC
│   │               │       └── gunc.sh
│   │               ├── Dereplication_filtering
│   │               │   └── dRep
│   │               │       └── drep.sh
│   │               └── Raw_bin
│   │                   ├── CheckM2
│   │                   │   └── checkm2.sh
│   │                   └── GUNC
│   │                       └── gunc.sh
│   ├── Features_MAGs
│   │   └── CoverM
│   │       └── coverm.sh
│   ├── Functional_annotation
│   │   ├── MAG_eggnog
│   │   │   └── merged_annotations.sh
│   │   └── eggmapper.sh
│   ├── Gene_prediction
│   │   └── GeneMarkS2
│   │       └── genemarks2.sh
│   ├── Host_removal
│   │   └── bowtie2.sh
│   ├── QC_MAGs
│   │   └── Final_MAGs
│   │       ├── CheckM2
│   │       │   └── checkm2.sh
│   │       ├── GUNC
│   │       │   └── gunc.sh
│   │       └── dRep
│   │           └── drep.sh
│   ├── Quality_control
│   │   ├── FastP
│   │   │   └── fastp.sh
│   │   ├── FastQC_clean
│   │   │   └── fastqc_clean.sh
│   │   └── FastQC_raw
│   │       └── fastqc_raw.sh
│   ├── Raw_data
│   │   └── sra-tools.sh
│   └── Taxonomy
│       ├── GTDB
│       │   ├── DB
│       │   └── taxonomy.sh
│       └── Phylogenomics
│           └── phylo.sh
└── Metatranscriptomics
    ├── Assembly
    │   └── rnaSPAdes
    │       ├── rnaQuast
    │       │   └── rnaquast.sh
    │       └── rnaspades.sh
    ├── Expression
    │   └── Meta-PD_DESeq2.Rmd
    ├── Host_removal
    │   └── STAR
    │       ├── Data
    │       │   └── symlinks.sh
    │       └── STAR.sh
    ├── Quality_control
    │   ├── FastP
    │   │   └── fastp.sh
    │   ├── FastQC_clean
    │   │   └── fastqc_clean.sh
    │   └── FastQC_raw
    │       └── fastqc_raw.sh
    ├── Quantification
    │   └── Salmon
    │       ├── Counts
    │       │   ├── import.sh
    │       │   └── tximport_salmon.R
    │       ├── Data
    │       │   └── symlinks.sh
    │       ├── MetaT
    │       └── meta_salmon.sh
    ├── Raw_data
    │   └── sra-tools.sh
    ├── Transcript_prediction
    │   ├── Diamond
    │   │   ├── DB
    │   │   │   └── MAG-protein_copy.sh
    │   │   └── magxtrans.sh
    │   └── TransDecoder
    │       └── transdecoder.sh
    └── rRNA_removal
        └── sortmerna.sh
## Workflow Description
### Mendelian Randomization (MR)
### Shotgun Metagenomics
### Metatranscriptomics
### 16S rRNA Gene Analysis
### Metabolomics
### Multi-omic Integration
## Software and Dependencies
## Data Availability
## Reproducibility Notes
## Citation
