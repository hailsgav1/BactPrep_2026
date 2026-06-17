FROM continuumio/miniconda3:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Set conda channel priority
RUN conda config --set channel_priority flexible

# Install all base dependencies into base environment
RUN conda install -c conda-forge -c bioconda \
    python=3.11 \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio snakemake -y

# Install bioinformatics tools
RUN conda install -c conda-forge -c bioconda \
    prokka=1.14.6 \
    snippy=4.6.0 \
    gubbins=2.4.1 \
    iqtree \
    snp-sites \
    bedtools \
    roary=3.13.0 \
    seqkit -y

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
