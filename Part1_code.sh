#!/bin/bash
# LIFE748 Assessment 2 - Part 1: Genome Assembly and Annotation
# Sample: GN9 (PacBio HiFi, 30x coverage)

# GAI Declaration:
# Claude (Anthropic, claude.ai) was used to assist with the following:
# - Interpreting QUAST output metrics for the assembly report
#
# Prompts:
# what flye flag do i use for pacbio hifi reads
# Claude responded: Use --pacbio-hifi, this is specifically for HiFi reads which have
# less than 1% error rate. If you used --pacbio-raw it would treat
# them as lower quality reads and affect the assembly
# why is my genome fraction 88% and not 100% ithis bad
# Claude responded: No that is not bad at all. GN9 is a clinical isolate and K-12 is a
# lab strain so they will have genuine biological differences. The 88%
# reflects those differences not gaps in your assembly
# Claude responded: SPAdes is not installed in your conda environment. It also needs at
# least 16GB RAM which your machine does not have so even if you
# installed it, it would likely fail on this dataset
#
# All ccommands were executed by myself.

# ── Step 1: Quality Control
mkdir -p fastqc_output
fastqc cgr.liv.ac.uk/454/acdarby/LIFE748/raw/GN9_hifix30.fastq \
  -o fastqc_output/

# ── Step 2: Genome Assembly - Flye 
flye --pacbio-hifi cgr.liv.ac.uk/454/acdarby/LIFE748/raw/GN9_hifix30.fastq \
  --out-dir GN9_flye_assembly \
  --threads 4
# Output assembly: GN9_flye_assembly/assembly.fasta

# ── Step 3: Genome Assembly - SPAdes
# SPAdes was not available in the local WSL conda environment
# (command not found). SPAdes also requires >=16 GB RAM which
# exceeded available local resources.
# spades.py --pacbio cgr.liv.ac.uk/454/acdarby/LIFE748/raw/GN9_hifix30.fastq \
#   -o GN9_spades_assembly

# ── Step 4: Assembly Quality Assessment - QUAST
quast.py GN9_flye_assembly/assembly.fasta \
  -r cgr.liv.ac.uk/454/acdarby/LIFE748/EcoliK12/EcoliK12_GCA_000005845.2_ASM584v2_genomic.fna \
  --threads 4 \
  -o GN9_quast_output

# ── Step 5 & 6: Annotation - Prokka and Bakta
# Prokka v1.14.6 and Bakta v1.7.0 results were obtained from
# the LIFE748 workshop pre-computed dataset, following workshop
# pipeline guidelines:
# cgr.liv.ac.uk/454/acdarby/LIFE748/annotation/
#
# Prokka settings used: --kingdom Bacteria --mincontiglen 200
# Bakta settings used: full database v5.0, default parameters
#
# Results were compared on CDS, rRNA, tRNA, ncRNA, CRISPR arrays,
# hypothetical proteins, and coding density
