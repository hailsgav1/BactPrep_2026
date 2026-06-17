FROM staphb/prokka:latest

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Install micromamba
RUN apt-get update && apt-get install -y wget bzip2 && \
    wget -qO- https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba && \
    mv bin/micromamba /usr/local/bin/micromamba

ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV PATH="/opt/conda/bin:/usr/local/bin:$PATH"

# Initialize micromamba
RUN micromamba shell init -s bash && \
    micromamba config set channel_priority flexible

# Set working directory
WORKDIR /BactPrep

# Copy the entire repo into the container
COPY . .

# Install all tools
RUN micromamba install -c conda-forge -c bioconda \
    python=3.11 snakemake biopython pyyaml \
    snippy gubbins iqtree snp-sites bedtools seqkit roary \
    unzip tar tree r-dplyr matplotlib zenodo_get \
    bioconductor-ggtree bioconductor-treeio -y

RUN pip install pyyaml biopython

# Run INSTALL.sh to set up fastGEAR and MATLAB runtime
RUN bash INSTALL.sh

# Make start_analysis.py executable
RUN chmod +x start_analysis.py

# Default command
ENTRYPOINT ["python", "start_analysis.py"]
