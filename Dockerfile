FROM ubuntu:22.04

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Install basic system utilities and native python3-pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    bzip2 \
    wget \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Use the exact API endpoint to pull the raw linux-64 binary tarball
RUN curl -Ls https://mamba.pm | tar -xj -C /usr/local/bin --strip-components=1 bin/micromamba

# Install Prokka environment
RUN micromamba create -y -p /opt/conda/envs/prokka_env \
    --override-channels \
    -c conda-forge \
    -c bioconda \
    prokka=1.14.6 bioperl perl-xml-simple \
    && micromamba clean -afy

# Install BactPrep base environment
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

# Target the specific conda-activated environment's pip to avoid path conflicts
RUN /opt/conda/envs/bactprep/bin/pip install --no-cache-dir pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
