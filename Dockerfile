FROM quay.io/biocontainers/prokka:1.14.6--hdfd78af_5

LABEL maintainer="biowizardhailey"
LABEL description="BactPrep - Bacterial Genome Preparation Pipeline"

# Install wget and curl
RUN apt-get update && apt-get install -y wget curl bzip2 && \
    apt-get clean

# Install Miniconda with Python 3.11
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py311_23.5.2-0-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

ENV PATH="/opt/conda/bin:$PATH"

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
