# Template Computational Modeling Project

This repository provides a **template** for running computational modeling using Stan in R, focused on **alpha-beta models** with or without spline components.

---

## Features

✅ Fits **alpha-beta reinforcement learning models** using Stan  
✅ Supports optional **spline-based extensions** to capture trial-wise nonlinear effects  
✅ Uses the `cmdstanr` backend for efficient sampling  
✅ Includes built-in **parameter recovery routines** to test model identifiability

---

## Folder Structure

data/ # (Ignored) Empirical or simulated data files
stan_modeling/ # R scripts for fitting and recovery
functions/ # Helper R functions
analysis/ # Analysis scripts


---

## Requirements

- R ≥ 4.1  
- R packages:
  - `cmdstanr`
  - `rstan`
  - `tidyverse`
  - `posterior`
  - `bayesplot`

- Stan installed and configured with `cmdstanr`

---

## How to Use

1️⃣ **Prepare your data**  
Place your dataset (or generate synthetic data) in the `/data/` folder.

2️⃣ **Select your model**  
Choose:
- `/stanmodel_alpha_beta/` → basic alpha-beta model  
- `/stanmodel_alpha_beta_splines/` → spline-augmented model

3️⃣ **Fit the model**  
Run the main R script