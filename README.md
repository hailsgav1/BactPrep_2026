# BactPrep

This pipeline is written specifically for annotating the **bacteria whole genome sequences (WGS)**. The pipeline handles multiple operations that are necessary for bacterial genome analysis. Including:

1) Annotating bacterial WGS 
2) Constructing a pangenome for bacterial WGS dataset
3) Identify core and accessory loci for bacterial WGS dataset 
4) Produce core gene concatenation alignment (with & without recombination detection)
5) Identify potential recombination regions (recent & ancestral) - (WGS wise & Per-gene)
6) Identify SNPs from conserved regions of the bacterial genomes
7) Reconstruct Phylogeny of input dataset (Maximum Likelihood)
8) Add Annotation to alignment and ML trees taxa (designed for BEAST Analysis)

## Overall Workflow

![pipeline_workflow](https://user-images.githubusercontent.com/31255012/126013330-8ffed1fb-af59-45f2-9393-2cfe6331b324.png)

## Installation

1) Install conda (Python3) in your local computer or on the computing cluster. Detailed instructions can be found [here](https://docs.conda.io/en/latest/miniconda.html)

2) Make a working directory
mkdir {BactPrep_dir}
cd {BactPrep_dir}
_* this name can change based on your project_

3) **Clone the repository into local working directory**
git clone https://github.com/rx32940/BactPrep.git
4) If first time using the pipeline
cd BactPrep

conda create -n BactPrep python=3.11 mamba -c conda-forge -y

conda activate BactPrep

# Set conda channel priority to flexible (required for Roary installation)
conda config --set channel_priority flexible

pip install pyyaml biopython

mamba install -c conda-forge -c bioconda \
  biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get \
  bioconductor-ggtree bioconductor-treeio snakemake -y

source INSTALL.sh
> **Note:** Python 3.11 is required. Python 3.12+ will cause compatibility issues with Snakemake and other dependencies.

 - 4.1) If you have used the pipeline before or already have matlab runtime R2016b (MCR) **AND** fastGear executable installed, use flags `--mcr_path` and `--fastgear_exe` to specify the absolute path to MCR and fastGear executable. You can find them in the `resources` folder from a previous download (see FAQ #6 for details).

5) You are now good to go!
``python start_analysis.py ALL(coreGen/wgsRecomb/panRecomb)``
7) After running all your analysis, deactivate the env
``conda deactivate``
## Running on HPC (SLURM clusters)

A SLURM submission script is included in the repo (`run_bactprep.sh`) for running BactPrep on HPC clusters. Edit the user settings at the top of the script before submitting:

```bash
# ====== USER SETTINGS - edit these ======
BACTPREP_DIR=/path/to/BactPrep        # path to cloned BactPrep directory
OUTPUT=/path/to/your/output            # path to output directory
INPUT=/path/to/your/assemblies         # path to directory with genome assemblies
REF=/path/to/your/reference.fna        # path to reference genome
PROJECT_NAME=my_project                # name prefix for output files
THREADS=16                             # number of threads (match --cpus-per-task)
# =========================================
```

Then submit:

mkdir -p logs
sbatch run_bactprep.sh

> **Note:** Make sure to set `#SBATCH --account` to your HPC account name before submitting.

## Troubleshooting

- **Python version:** Always use `python=3.11` when creating the conda environment. Python 3.12+ breaks Snakemake and other dependencies.
- **Roary installation fails:** Run `conda config --set channel_priority flexible` before installing dependencies.
- **Git fails on HPC:** If you get a `curl_global_sslset` error when running git on HPC, run `export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH` first.
- **Missing modules:** If you get `ModuleNotFoundError` for `yaml` or `Bio`, run `pip install pyyaml biopython`.

## Sample Dataset

[218 Streptococcus pneumoniae PMEN1 WGS assemblies collected from the year 1984 - 2008 from 22 unique countries globally](https://zenodo.org/record/5603335#.YkxP9y9h1TY)

The sample dataset can be downloaded to your work directory by:

mkdir -p $INPATH/assemblies
cd $INPATH/assemblies
zenodo_get -d 10.5281/zenodo.5603335
rm $INPATH/assemblies/md5sums*

**Reference genome** for _Streptococcus pneumoniae_ PMEN1 can be downloaded from NCBI: [Streptococcus pneumoniae ATCC 700669 (firmicutes)](https://www.ncbi.nlm.nih.gov/assembly/GCF_000026665.1/)

cd $INPATH/
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/026/665/GCF_000026665.1_ASM2666v1/GCF_000026665.1_ASM2666v1_genomic.fna.gz
gunzip GCF_000026665.1_ASM2666v1_genomic.fna.gz

## Instruction

### Module Selection:

`ALL`: this module will attempt to run `wgsRecomb`, `coreGen`, and `coreRecomb` modules
- All options required for these three modules are also required for `ALL` module

`wgsRecomb`: detect recombination from WGS alignment

`coreGen`: construct bacteria pangenome

`panRecomb`: will attempt to detect recombination for each gene in all genes in the pangenome individually
- predict recombination among lineages detected by BAPs (can also provide your own lineage)
- this module uses gene loci detected by Roary, thus will also run module coreGen
- please use geneRecomb module for individual gene/alignment of interest

`geneRecomb`: will detect recombination from a gene/alignment of interest

`coreRecomb`: will detect recombinations only from the core genes detected by coreGen module (Roary)
- this is part of the ALL module
- this module uses gene loci detected by Roary, thus will also run module coreGen
- will mask detected recombination region, and call SNPs from conserved region of core genome alignment
- recombinations are detected for each gene individually
- will also reconstruct phylogeny for the dataset based on the core clonal SNPs

usage: start_analysis.py MODULE [options]
Please always specify the program to use in the first argument, or the whole pipeline will attempt to run
positional arguments:
{ALL,wgsRecomb,coreGen,coreRecomb,panRecomb,geneRecomb}
Specify the module you would like to run
optional arguments:
-h, --help            show this help message and exit
general arguments:
-i , --input          path to input dir with assemblies
-p , --name           provide name prefix for the output files
-t , --thread         num of threads
-o , --output         path to the output directory
arguments for if you would like to add metadata to output:
-M, --addMetadata     must have the flag specify if want to allow annotation
-a , --annotate       path to a csv file containing sample metadata
-s , --sample         integer indicates which column the sample name is in the metadata csv file
-m , --metadata       metadata chosen to annotate ML tree/alignment after the sample name
arguments for wgsRecomb module:
-r , --ref            reference (required for wgsRecomb module)
-v , --phage          phage region identified for masking (bed file)
-G , --gubbins        any additional Gubbins arguments (please refer to Gubbins manual)
arguments for coreGen module:
-g , --gff            path to input dir with gff (this can replace input assemblies dir in coreGen module. Must be gff3 files)
-c , --core           define core gene definition by percentage for coreGen module (default=99)
-k , --kingdom        specify the kingdom of input assemblies for genome annotation (default=Bacteria)
-R , --roary          any additional roary arguments (please refer to Roary manual)
arguments for all three fastGear modules (coreRecomb, panRecomb, geneRecomb):
--mcr_path            path to mcr runtime (need to install before use any of the fastGear module)
--fastgear_exe        path to the executable of fastGear
--fg , --fastgear_param
path to fastGear params
arguments for geneRecomb module:
-n , --alignment      input alignment (either -n/-fl is required for geneRecomb module)
-fl , --alnlist       input alignment list with path to gene alignments (either -n/-fl is required for geneRecomb module)
Enjoy the program! :)

**Run**: `python start_analysis.py ALL(coreGen/wgsRecomb/panRecomb)`

## Output Files

---

## FAQS

**1) Getting Started - How to run ALL Module**

If you would like to run "wgsRecomb", "coreGen", and "coreRecomb" modules all together, use the "ALL" module. **Note: a reference genome (-r) is necessary to run the "wgsRecomb" module.**

EXAMPLE:

python start_analysis.py ALL -p PMEN1.dated 
-o $OUTPATH 
-i $INPATH/assemblies 
-r $INPATH/GCF_000026665.1_ASM2666v1_genomic.fna

**1.1)** If you already have gff files from a previous analysis, **gff dir** can be used as input for the "coreGen" module. This saves a lot of time:

python start_analysis.py ALL -p PMEN1.dated 
-o $OUTPATH 
-t 10 
-g $INPATH/gff 
--mcr_path {path_to_previous_BactPrep_folder}/resources/mcr 
--fastgear_exe /home/user/SOFTWARE/fastGEARpackageLinux64bit

**2) Obtain Annotated Outputs**

If you would like to obtain annotated phylogenies and alignments, provide a CSV file with annotation of every isolate. Flag `-M` must be specified for annotation. `-a` is the path to the CSV metadata file. `-s` specifies the index of the column matching input assemblies' file names (default is 1). `-m` asks for the column names of the metadata to add for annotations (comma separated).

EXAMPLE CSV File:

ENA Accession | Strain | Year | Country
-- | -- | -- | --
ERS009226 | ARG 740 | 1995 | Argentina
ERS009778 | 3122 | 1994 | Canada
ERS009785 | 36148 | 2008 | Canada
ERS004773 | HK P1 | 2000 | China
ERS004775 | HK P38 | 2000 | China

EXAMPLE:

python start_analysis.py ALL -p PMEN1.dated 
-o $OUTPATH 
-i $INPATH/assemblies 
-r $INPATH/GCF_000026665.1_ASM2666v1_genomic.fna 
-M 
-a $INPATH/PMEN1.dated.metadata.csv 
-s 1 
-m Year,Country

**3) IF you would only like to run "wgsRecomb"**

A reference genome must be provided. "wgsRecomb" will call SNPs from the reference genome for each input WGS assembly, and combine them into a multiple sequence alignment using **Snippy**. **Gubbins** will detect recombination regions from the alignment. SNPs outside of recombination regions will be used to reconstruct the phylogeny with **IQTree**.

EXAMPLE:


python start_analysis.py wgsRecomb -p PMEN1.dated 
-o $OUTPATH 
-i $INPATH/assemblies 
-r $INPATH/GCF_000026665.1_ASM2666v1_genomic.fna

**4) IF you would only like to run "coreGen"**

All input WGS assemblies will be annotated by **Prokka**. Using Prokka's gene annotations, **Roary** will reconstruct the pangenome and identify core genes shared by 99% (adjustable with `-c` flag) of the isolates. Roary will also provide a core gene concatenation alignment for phylogeny reconstruction using **IQTree**.

EXAMPLE:

python start_analysis.py coreGen -p PMEN1.dated 
-o $OUTPATH 
-i $INPATH/assemblies

**5) IF you would only like to run "coreRecomb"**

The "coreGen" module will run first. "coreRecomb" will identify homologous recombination from every core gene identified by **Roary**. Recombination regions will be masked before core genes' alignments are concatenated. SNPs outside recombination regions will be used to reconstruct the phylogeny with **IQTree**.

EXAMPLE:

python start_analysis.py coreRecomb 
-p PMEN1.dated 
-o $WORKPATH 
-i $WORKPATH/assemblies 
-r $WORKPATH/GCF_000026665.1_ASM2666v1_genomic.fna 
-t 10 
-M 
-a $WORKPATH/PMEN1.dated.metadata.csv 
-m Year,Country

**6) IF matlab runtime (MCR) version R2016a is already installed or this is not the first time running this pipeline**

Use flags `--mcr_path` and `--fastgear_exe` to avoid reinstalling these dependencies. You do not need to run `INSTALL.sh` again, but a conda environment still needs to be created and activated.

EXAMPLE:

conda create -n BactPrep python=3.11 mamba -c conda-forge -y
conda activate BactPrep
conda config --set channel_priority flexible
pip install pyyaml biopython
mamba install -c conda-forge -c bioconda 
biopython unzip tar tree r-dplyr pyyaml matplotlib zenodo_get 
bioconductor-ggtree bioconductor-treeio snakemake -y
python start_analysis.py panRecomb -p PMEN1.dated_fastGear_pan 
-o $OUTPATH 
-t 10 
-i $INPATH/assemblies 
--mcr_path {path_to_previous_BactPrep_folder}/resources/mcr/v901 
--fastgear_exe {path_to_previous_BactPrep_folder}/fastGEARpackageLinux64bit

**7) IF you would like to inform wgsRecomb (Gubbins) about an already known phage region**

Use `-v` or `--phage` to provide the phage region in a BED file.

EXAMPLE:

python start_analysis.py wgsRecomb 
-p PMEN1.dated 
-o $WORKPATH 
-i $WORKPATH/assemblies 
-r $WORKPATH/GCF_000026665.1_ASM2666v1_genomic.fna 
-v $WORKPATH/phage_region.bed

**8) IF additional arguments need to be specified for Roary and Gubbins**

Additional Roary and Gubbins arguments can be added using the `-R` or `-G` flags respectively.

> **Note:** A space is necessary at the beginning of the string.

EXAMPLE:

python start_analysis.py ALL 
-p PMEN1.dated 
-o $WORKPATH 
-g $WORKPATH/gff 
-r $WORKPATH/GCF_000026665.1_ASM2666v1_genomic.fna 
-R " -r -y -iv 1.5"

**9) If you have trouble installing fastGear with `INSTALL.sh`**

Follow the instructions below for manual installation.

Download and install fastGear executable:
1. Change directory to: `{absolute_path_to_BactPrep}/resources/`
2. Download fastGear:
wget --no-check-certificate https://users.ics.aalto.fi/~pemartti/fastGEAR/fastGEARpackageLinux64bit.tar.gz -P {absolute_path_to_BactPrep}/resources

3. Unzip: `tar -zvxf fastGEARpackageLinux64bit.tar.gz`

Download and install Matlab Runtime (MCR):
1. Download MCR:
wget https://users.ics.aalto.fi/~pemartti/fastGEAR/MCRInstallerLinux64bit.zip -P {absolute_path_to_BactPrep}/resources --no-check-certificate
2. Unzip: `unzip MCRInstallerLinux64bit.zip`
3. Change directory: `cd MCRInstallerLinux64bit`
4. Install:
./install -destinationFolder {absolute_path_to_BactPrep}/resources/mcr/ -mode silent -agreeToLicense yes
If you already have MCR (R2016a) installed, specify the path with `--mcr_path`:
--mcr_path {absolute_path_to_BactPrep}/resources/mcr/
