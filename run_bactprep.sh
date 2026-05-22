#!/bin/bash
#SBATCH --job-name=BactPrep
#SBATCH --output=logs/bactprep_%j.out
#SBATCH --error=logs/bactprep_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64gb
#SBATCH --time=96:00:00
#SBATCH --account=your_account
#SBATCH --partition=standard

# ====== USER SETTINGS - edit these ======
BACTPREP_DIR=/path/to/BactPrep        # path to cloned BactPrep directory
OUTPUT=/path/to/your/output            # path to output directory
INPUT=/path/to/your/assemblies         # path to directory with genome assemblies
REF=/path/to/your/reference.fna        # path to reference genome
PROJECT_NAME=my_project                # name prefix for output files
THREADS=16                             # number of threads (match --cpus-per-task)
# =========================================

source ~/.bashrc
conda activate BactPrep
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

mkdir -p $BACTPREP_DIR/logs
cd $BACTPREP_DIR

python start_analysis.py ALL \
  -p $PROJECT_NAME \
  -o $OUTPUT \
  -i $INPUT \
  -r $REF \
  -t $THREADS
