FROM continuumio/miniconda3:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Set conda channel priority flexible
RUN conda config --set channel_priority flexible

# Install base dependencies
RUN conda install -c conda-forge -c bioconda \
    python=3.11 \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio snakemake -y

# Install Prokka with strict channel ordering and bioperl
RUN conda create -y -n prokka_env -c conda-forge -c bioconda -c defaults \
    prokka bioperl perl-xml-simple

# Handle tbl2asn expiration
ENV tbl2asn="-no-warn"

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
