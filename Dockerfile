FROM continuumio/miniconda3:latest

LABEL maintainer="hailsgav1"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Set conda channel priority
RUN conda config --set channel_priority flexible

# Install base dependencies
RUN conda create -n BactPrep python=3.11 mamba -c conda-forge -y

# Activate environment and install packages
SHELL ["conda", "run", "-n", "BactPrep", "/bin/bash", "-c"]

RUN mamba install -c conda-forge -c bioconda \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio snakemake -y

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["conda", "run", "-n", "BactPrep", "python", "start_analysis.py"]
