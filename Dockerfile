FROM continuumio/miniconda3:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Update conda, install mamba, and build prokka environment
RUN conda update -n base -c defaults conda -y && \
    conda install -y -c conda-forge mamba && \
    mamba create -y -n prokka_env \
    --override-channels \
    -c conda-forge \
    -c bioconda \
    prokka bioperl perl-xml-simple && \
    conda clean -afy

# Add prokka to PATH
ENV PATH="/opt/conda/envs/prokka_env/bin:$PATH"

# Set conda channel priority flexible
RUN conda config --set channel_priority flexible

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Install base dependencies
RUN conda install -c conda-forge -c bioconda \
    python=3.11 \
    biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio snakemake -y

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Handle tbl2asn expiration
ENV tbl2asn="-no-warn"

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
