FROM condaforge/mambaforge:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Install Docker to pull prokka container
RUN apt-get update && apt-get install -y docker.io

# Set conda channel priority
RUN conda config --set channel_priority flexible

# Install Python and base tools
RUN mamba install -c conda-forge -c bioconda \
    python=3.11 snakemake -y

# Install base dependencies
RUN mamba install -c conda-forge -c bioconda \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio -y

# Install prokka via pip workaround
RUN mamba install -c conda-forge -c bioconda \
    perl=5.22 parallel prodigal blast tbl2asn -y && \
    mamba install -c bioconda prokka -y

# Install SNP tools
RUN mamba install -c conda-forge -c bioconda \
    snippy -y

# Install recombination tools
RUN mamba install -c conda-forge -c bioconda \
    gubbins -y

# Install tree tools
RUN mamba install -c conda-forge -c bioconda \
    iqtree snp-sites bedtools seqkit -y

# Install pangenome tools
RUN mamba install -c conda-forge -c bioconda \
    roary -y

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
