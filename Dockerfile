FROM continuumio/miniconda3:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Install system dependencies and create legacy symlink for fastGEAR
RUN apt-get update && apt-get install -y \
    libncurses6 \
    libtinfo6 \
    execstack \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5 \
    && ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5

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

# Install Prokka without defaults channel
RUN conda create -n prokka_env -c conda-forge -c bioconda prokka -y

# Fix Perl library path issue
RUN cd /opt/conda/envs/prokka_env/lib/site_perl/5.26.2/ && \
    ln -s ../../perl5/site_perl/5.22.0/* . 2>/dev/null || true

# Add prokka to PATH but keep base conda Python first
ENV PATH="/opt/conda/bin:/opt/conda/envs/prokka_env/bin:${PATH}"

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Fix MATLAB MCR executable stack issue
RUN find /BactPrep/resources/mcr/v901/ -name "*.so" -exec execstack -c {} \; 2>/dev/null || true

# Make start_analysis.py executable
RUN chmod +x /BactPrep/start_analysis.py

# Handle tbl2asn expiration
ENV tbl2asn="-no-warn"

# Default command using full path
ENTRYPOINT ["python", "/BactPrep/start_analysis.py"]
