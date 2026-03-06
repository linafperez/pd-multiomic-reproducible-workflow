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

The study follows a stepwise analytical strategy:

1. **Data acquisition** from public repositories.
2. **Independent processing of each omic layer** using standardized pipelines.
3. **Genome reconstruction** from metagenomic data to obtain metagenome-assembled genomes (MAGs).
4. **Functional characterization** using metatranscriptomics and metabolomics.
5. **Cross-platform taxonomic harmonization** linking MAGs and ASVs.
6. **Multi-omic integration** connecting microbial genomes, genes, pathways, and host metabolites.

This design enables a systems-level reconstruction of microbiome–host interactions associated with Parkinson’s disease.

## Repository Structure
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
