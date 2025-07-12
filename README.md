# miRNA-Based Tissue Signal (miR-TS) scores

## What is miR-TS?

**miR-TS** is a computational method to estimate signals from 23 tissue types using circulating miRNAs in plasma/serum.

## Input & Output

- **Input:** A matrix with **miRNAs as rows** and **samples as columns**
- **Output:** A matrix with **samples as rows** and **tissue types as columns** (miR-TS scores)

## 23 Tissue types being estimated
*adipocyte, artery, bladder, bone, bowel, brain, esophagus, heart, kidney, liver, lung, lymph_node,
muscle, nerve, pancreas, pleura, salivary_gland, skin, spleen, stomach, testis, thyroid, vein*

## Demo Data

The repository includes an example dataset of small RNA-seq data from a study of **hepatitis C** (GEO acc: GSE74872), demonstrating how to run the pipeline to obtain the miR-TS scores and how the liver miR-TS differs bewteen patients and healthy controls.
