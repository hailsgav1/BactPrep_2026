FROM ubuntu:22.04

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Install basic system utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    bzip2 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Micromamba
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba

# Initialize micromamba
RUN micromamba shell init -s bash -p /opt/conda

# Install Prokka in its own environment
RUN micromamba create -y -p /opt/conda/envs/prokka_env \
    --override-channels \
    -c conda-forge \
    -c bioconda \
    prokka=1.14.6 bioperl perl-xml-simple \
    && micromamba clean -afy

# Install base BactPrep dependencies
RUN micromamba create -y -p /opt/conda/envs/bactprep \
    --override-channels \
    -c conda-forge \
    -c bioconda \
    python=3.11 snakemake biopython pyyaml matplotlib \
    unzip tar tree r-dplyr zenodo_get \
    bioconductor-ggtree bioconductor-treeio \
    && micromamba clean -afy

# Add both environments to PATH
ENV PATH="/opt/conda/envs/prokka_env/bin:/opt/conda/envs/bactprep/bin:${PATH}"

# Handle tbl2asn expiration
ENV tbl2asn="-no-warn"

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
