import os
import pandas as pd

# read recent recombinations
fastGear_recent = pd.read_csv(snakemake.input[0], sep=r"\s+", header=1)
fastGear_recent_out = fastGear_recent[["StrainName", "Start", "End"]]

def mask_strains_in_lineage(row, lineage):
    lineage1 = row["Lineage1"]
    lineage2 = row["Lineage2"]
    start = row["Start"]
    end = row["End"]
    lineages = lineage[lineage["Lineage"].isin([lineage1, lineage2])]["Name"]
    current_ances_row_bed = pd.DataFrame({
        "StrainName": lineages.to_list(),
        "Start": [int(start)] * len(lineages),
        "End": [int(end)] * len(lineages)
    })
    return current_ances_row_bed

# read in ancestral recombination files
fastGear_ances = pd.read_csv(snakemake.input[1], sep=r"\s+", header=1)
lineage_file = pd.read_csv(snakemake.input[2], sep=r"\s+", header=0)

fastGear_ances_out_df = pd.DataFrame(columns=["StrainName", "Start", "End"])

fastGear_ances_out = fastGear_ances.apply(lambda row: mask_strains_in_lineage(row, lineage_file), axis=1)

if not fastGear_ances_out.empty:
    frames = [fastGear_ances_out_df] + [item for item in fastGear_ances_out]
    fastGear_ances_out_df = pd.concat(frames, ignore_index=True)

fastGear_out = pd.concat(
    [fastGear_ances_out_df, fastGear_recent_out],
    ignore_index=True,
    sort=False
)[["StrainName", "Start", "End"]]

fastGear_out.to_csv(snakemake.output[0], header=False, index=False, sep="\t")
    
