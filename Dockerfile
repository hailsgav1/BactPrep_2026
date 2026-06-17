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

# Install Prokka without defaults channel
RUN conda create -n prokka_env -c conda-forge -c bioconda prokka -y

# Fix Perl library path issue
RUN cd /opt/conda/envs/prokka_env/lib/site_perl/5.26.2/ && \
    ln -s ../../perl5/site_perl/5.22.0/* . 2>/dev/null || true

# Add prokka to PATH
ENV PATH="/opt/conda/envs/prokka_env/bin:${PATH}"

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
