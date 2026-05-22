#!/bin/bash
#SBATCH --job-name=BactPrep
#SBATCH --output=/xdisk/kcooper/gaviganh/BactPrep_2026/logs/bactprep_%j.out
#SBATCH --error=/xdisk/kcooper/gaviganh/BactPrep_2026/logs/bactprep_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64gb
#SBATCH --time=96:00:00
#SBATCH --account=kcooper
#SBATCH --partition=standard

source ~/.bashrc
conda activate BactPrep
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

cd /xdisk/kcooper/gaviganh/BactPrep_2026

python start_analysis.py ALL \
  -p PMEN1_test \
  -o /xdisk/kcooper/gaviganh/test_output \
  -i /xdisk/kcooper/gaviganh/test_data/assemblies \
  -r /xdisk/kcooper/gaviganh/test_data/GCF_000026665.1_ASM2666v1_genomic.fna \
  -t 16
