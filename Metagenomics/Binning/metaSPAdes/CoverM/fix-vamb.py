import pandas as pd

# Load your CoverM file
df = pd.read_csv("depth.vamb.txt", sep="\t")

# Rename first column to contigname
df.rename(columns={"Contig": "contigname"}, inplace=True)

# Clean up sample names (remove paths and " Mean")
df.columns = [c.replace("final.contigs.fa/", "").replace("_unmapped_R1.fastq", "").replace(" Mean", "") 
              if c != "contigname" else c for c in df.columns]

# Save in Vamb format
df.to_csv("depth.vamb.cleaned.txt", sep="\t", index=False)
