# miRNA-Based Tissue Signal (miR-TS) scores

## What is miR-TS?

**miR-TS**, a computational method to estimate signals from 23 tissue types using circulating miRNAs in plasma/serum, can simultaneously track multiple tissue health and predict the onset of a wide range of diseases.

## Input & Output

- **Input:** A matrix with **miRNAs as rows** and **samples as columns**
- **Output:** A matrix with **samples as rows** and **tissue types as columns** (miR-TS scores)

## Tissue types being estimated
*adipocyte, artery, bladder, bone, bowel, brain, esophagus, heart, kidney, liver, lung, lymph_node,
muscle, nerve, pancreas, pleura, salivary_gland, skin, spleen, stomach, testis, thyroid, vein*

## Demo Data

This repository includes a demo dataset based on small RNA data from a hepatitis C study (GEO accession: [GSE74872](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE74872)).  
It demonstrates how to apply the miR-TS pipeline and illustrates how liver miR-TS scores vary across three groups: healthy controls, hepatitis C patients without fibrosis, and those with fibrosis.

Additionally, miR-TS scores were tested across the following tissue types and health conditions using publicly available datasets:

| Tissue     | Condition                             | GEO Accession |
|------------|----------------------------------------|---------------|
| Adipocyte  | Adipose inflammation                   | [GSE240273](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE240273) |
| Bone       | Osteoporosis                           | [GSE201543](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE201543) |
| Bowel      | Ulcerative colitis                     | [GSE32273](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE32273)   |
| Brain      | Traumatic brain injuries               | [GSE131695](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE131695) |
| Heart      | Fulminant myocarditis                  | [GSE148153](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE148153) |
| Kidney     | T2D + diabetic kidney disease          | [GSE262414](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE262414) |
| Liver      | Acetaminophen overdose                 | [GSE59565](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE59565)   |
| Liver      | Liver allograft rejection              | [GSE69579](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE69579)   |
| Lung       | COVID-19                               | [GSE178246](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE178246) |
| Skin       | Medicamentosa-like dermatitis          | [GSE247297](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE247297) |



## Citation

Coming soon...
