FROM condaforge/mambaforge:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Set conda channel priority and add defaults last
RUN conda config --set channel_priority flexible && \
    conda config --remove channels defaults || true && \
    conda config --append channels defaults

# Install Python and base tools
RUN mamba install -c conda-forge -c bioconda \
    python=3.11 snakemake -y

# Install base dependencies
RUN mamba install -c conda-forge -c bioconda \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio -y

# Install prokka using conda instead of mamba
RUN conda install -c conda-forge -c bioconda -c defaults \
    prokka --no-channel-priority -y

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
