# Supplementary Materials — English vocabulary 3D-VAE

## Overview

This README describes the **English-language component** of the supplementary code for the three-dimensional variational autoencoder (3D-VAE) analysis of early vocabulary production. The workflow comprises (1) searching over random seeds, (2) training the selected final model and exporting its weights, and (3) computing decoder outputs on a three-dimensional latent-space grid using saved weights.

The notebooks were curated for the Supplementary Materials in 2026 from the original analysis notebooks. Explanatory text and comments were translated into English, unused code was removed, and the execution workflow was documented. **The curated notebooks were not rerun.** Saved outputs are historical records, and the notebooks should **not** be executed using *Run all*: the final-model notebook describes two separate execution stages.

## Files

| File | Contents |
| --- | --- |
| `english_vae_seed_search.ipynb` | Seed-screening workflow: an initial 50 trials followed by 950 additional trials; exports training and validation losses. |
| `VAEloss_English_20240411ver0.1.csv` | Recorded seed-screening results, with columns `seed`, `loss`, and `val_loss`. |
| `english_vae_final_model.ipynb` | Selection of the final seed, final VAE training, export of five weight files, and grid-based decoder computation from saved weights. |
| `README.md` | This document. |

The two `.ipynb` files above are publication-named copies of the completed, versioned working notebooks. The versioned files and the original research notebooks are preserved separately; the copies have not been computationally rerun.

## 1. Seed search

Run `english_vae_seed_search.ipynb` with the English vocabulary input data available at the paths specified in the code.

- An initial list of **50** random integer seeds is evaluated, followed by **950** further seeds processed in **10 batches of 95**. Results are saved incrementally to the loss CSV.
- Each trial trains a 3D-VAE for **30 epochs**, using the trial's seed and a randomly selected one-seventh validation subset.
- Seeds are sampled using `random.randint(0, 100000)` **with possible repetitions**. The accompanying CSV has **1,000 rows representing training runs** but **993 distinct seed values**.
- The final model uses the seed with the lowest recorded `val_loss`: **26172** (`val_loss` approximately **186.898148**).

The supplied loss CSV is the historical result of the seed search. Rerunning the seed-search notebook may overwrite that file; use a separate output path if the original record must be retained.

## 2. Final model: two execution stages

Open `english_vae_final_model.ipynb` and follow the Markdown instructions immediately preceding the relevant cells.

### Stage 1 — Train model and export weights

1. Import the required packages, mount Google Drive, and prepare the English vocabulary data.
2. Read `VAEloss_English_20240411ver0.1.csv` and examine the `val_loss` ranking.
3. Train the VAE with **seed 26172**, as recorded in the training cell.
4. Extract the trained weights and biases, then run the **weight-export cell** to save five CSV files.

The final-model architecture in the notebook has **680 input/output vocabulary variables**, a **512-unit hidden layer**, and a **three-dimensional latent space**. It uses a reconstruction loss based on binary cross-entropy combined with a Kullback–Leibler divergence term, optimized with Adam; the recorded training uses **30 epochs** and **batch size 128**. The historical data display contains **9,093 children** and **680 word items**.

The five weight exports are:

- `VAEweD_eng3D20240411.csv`
- `VAEweZm_eng3D20240411.csv`
- `VAEweZlv_eng3D20240411.csv`
- `VAEwdD1_eng3D20240411.csv`
- `VAEwdD2_eng3D20240411.csv`

They are written beneath `dataset/VAEeng3D20240411_weight/`. **The weight-export cell is active in the supplied notebook; do not run it if the existing weight files should not be overwritten.**

### Stage 2 — Compute decoder outputs from saved weights

This stage can be carried out in a fresh session, **without retraining** the model:

1. Run the imports and mount Google Drive. Skip the training cell and plots that depend on a trained Encoder.
2. Run the independent grid-definition cell. It defines **30 points per latent dimension**, spanning **-4 to 4**, for **27,000 grid points** in total.
3. Remove the enclosing `"""` lines from the **decoder-weight loading cell**, then execute it. The cell loads the two decoder-layer weight files (`VAEwdD1_eng3D20240411.csv` and `VAEwdD2_eng3D20240411.csv`) and their biases. This cell is **disabled by default** in the curated notebook.
4. Run the subsequent NumPy calculations, applying ReLU at the hidden layer and sigmoid at the output layer, then construct the resulting DataFrame.
5. To save the results, uncomment and run the CSV export statement for `VAEdecAlleng3D20240411.csv`. Leave it commented if the existing output must be preserved.

The decoder produces **27,000 x 680** values (grid points x vocabulary items). The recorded CSV-export code saves the **transposed 680 x 27,000 array**, without row indices or column headers.

**Historical execution note:** Weight-export statements were used during the original model-training stage and later commented out. They have been made active in this curated notebook to describe Stage 1. Conversely, the decoder-weight loading cell was used in the subsequent saved-weight stage and is now enclosed in triple quotes to identify Stage 2 as a deliberate alternative. These presentation changes do not mean the historical computations were not performed.

## Data, paths, and reproducibility

The notebooks were written for **Google Colab** and contain absolute paths beginning with `/content/drive/MyDrive/dataset/`. In particular, the English input file is `EnglishAmerican_WS_20240411_shaped.csv`. Adjust paths to match the execution environment, and ensure the `VAEeng3D20240411_weight` directory exists before exporting weights.

The original input vocabulary dataset, the five trained-weight CSV files, and the final decoder-output CSV are **referenced by the notebooks but are not included among the English files listed above**. They are additional dependencies or generated artifacts, not substitutes for the seed-search CSV. Full computational reproduction also requires a compatible Python/TensorFlow/Keras environment; package versions are not pinned by these notebooks, and exact numerical reproduction across environments is not guaranteed.

The existing cell outputs are retained where relevant as records of the historical runs. Changes to file paths, explanatory Markdown, and activation of weight export/loading cells were made for documentation in 2026; **no new model fitting or decoder computation was performed as part of these edits**.
