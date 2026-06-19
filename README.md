# Essential role for the urothelial plaque in Gram-negative urinary tract infections

## Introduction
Urothelial plaques are produced by bladder superficial urothelium cells and are composed of uroplakin proteins, including Upk1b. These plaques interact with UPEC type I fimbriae and are thought to contribute to bacterial attachment and invasion. To evaluate the role of the plaque in infection-associated host responses, this study used *Upk1b* knockout mice as a model of disrupted urothelial plaque function. Following UPEC inoculation, Upk1b KO mice exhibited reduced bacterial burden, impaired urothelial invasion, and absent intracellular bacterial communities, compared to wild-type hosts.

## Description
The code in this repository is mainly used for RNA-seq analysis of bladder samples from *Upk1b* knockout and wild-type mice following UPEC infection. The workflow includes preprocessing of RNA-seq data, pairwise comparisons between experimental groups, and global comparisons across all groups to identify transcriptional changes associated with plaque disruption and UPEC infection.

These analyses were used to characterize host immune and inflammatory pathways affected by loss of *Upk1b*, providing transcriptomic support for the role of the urothelial plaque in UPEC invasion, establishment of urinary tract infection, and activation of the innate immune response.


## Datasets
RNA was isolated from female Upk1b WT and KO bladders (4 biological replicates/group) at baseline and 24 hr following infected with UTI89 using the MirVanaTM ParisTM kit (Thermo Fisher). Bulk RNA sequencing (RNA-seq) was performed by the Genomic Services Laboratory at Nationwide Children’s Hospital.

## Methods

1. RNA-seq Preprocessing .
2. Differentially Expression Analysis
3. Functional enrichment Analysis
4. Transcrition factor and signaling pathway activation inference.

##  Workflow

The analysis is organized into three sequential steps.

**Step 1 — Preprocessing** ([scripts/01_preprocessing/](scripts/01_preprocessing/))

Raw paired-end FASTQ files were generated across two sequencing runs for each of the 16 samples. Files from each run were first concatenated to produce a single input per sample. Read quality was assessed with FastQC, and low-quality bases and adapter sequences were removed using Trim Galore (v0.6.0). Trimmed reads were aligned to the mouse reference genome (GRCm38/mm10) with TopHat2 (v2.1.2), guided by GENCODE vM33 gene annotations. Transcript-level abundances were estimated using Cufflinks (v2.2.1). Aligned reads were filtered to retain only uniquely mapping read pairs using SAMtools (v1.15; flags `-F 1548 -q 30`), and gene-level read counts were generated with HTSeq-count (v0.12.4) in union mode with reverse-strand specificity.

**Step 2 — Pairwise Differential Expression Analysis** ([scripts/02_pairwise_comparisons/](scripts/02_pairwise_comparisions/))

Read counts across all samples were merged into a single protein-coding gene expression matrix. Five pairwise contrasts were analyzed: (1) FVB infected vs. FVB baseline, (2) *Upk1b* KO infected vs. FVB baseline, (3) *Upk1b* KO infected vs. FVB infected, (4) *Upk1b* KO infected vs. *Upk1b* KO baseline, and (5) *Upk1b* KO baseline vs. FVB baseline. For each contrast, count data were normalized using the TMM method in edgeR and filtered to retain genes with CPM > 0.5 in at least 2 samples. Sample relationships were visualized by PCA and MDS plots. Differentially expressed genes (DEGs) were identified using the quasi-likelihood F-test (`glmQLFTest`) and defined by a Benjamini–Hochberg adjusted p-value ≤ 0.05 and |log2 fold change| ≥ 0.58. For each contrast, Gene Ontology (GO) biological process enrichment was performed using clusterProfiler with redundant terms collapsed by `simplify()`. Transcription factor (TF) activity was inferred from DEG t-values using the Univariate Linear Model (ULM) in decoupleR with the CollecTRI mouse regulatory network. Signaling pathway activity was estimated using the Multivariate Linear Model (MLM) with the PROGENy network.

**Step 3 — Cross-group Comparison** ([scripts/03_all_groups_comparison/](scripts/03_all_groups_comparision/))

DEG lists from all five pairwise contrasts were integrated and compared across experimental groups using `compareCluster()` from clusterProfiler. Innate and adaptive immune pathways were highlighted, and expression profiles of cytokines and chemokines were visualized as heatmaps. TF activity was further compared across groups to identify transcriptional regulators consistently or differentially active between *Upk1b* KO and wild-type conditions.

## Citation

Jackson, AR., Li, B., EIHaraken, M., Cortado, H., Gupta, S., Ballash, G., Ching, CB, Wang, X., Becknell, B. **Essential role for the urothelial plaque in Gram-negative urinary tract infections**, Scientific Reports (2026). 


## Copyright
For more detail information, please feel free to contact: xin.wang@nationwidechildrens.org

Copyright (c) 2026 Xin Wang

Current version v1.0
