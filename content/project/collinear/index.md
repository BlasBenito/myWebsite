---
title: "R package collinear"
summary: R package for multicollinearity management in data frames with numeric and categorical variables.
date: "2025-01-12T00:00:00Z"
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
links:
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://blasbenito.github.io/collinear/
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://CRAN.R-project.org/package=collinear
tags: 
- Rstats
- Quantitative Methods
- Linear Modelling
- Machine Learning
- Multicollinearity
- Target Encoding
- Analytics
- Data Science
---

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10039489.svg)](https://doi.org/10.5281/zenodo.10039489)
[![CRAN status](https://www.r-pkg.org/badges/version/collinear)](https://cran.r-project.org/package=collinear)
[![CRAN\_Download\_Badge](http://cranlogs.r-pkg.org/badges/grand-total/collinear)](https://CRAN.R-project.org/package=collinear)

<!-- badges: end -->


## Description

[Multicollinearity hinders the interpretability](https://www.blasbenito.com/post/multicollinearity-model-interpretability/) of linear and machine learning models.

The R package [**`collinear`**](https://blasbenito.github.io/collinear/), [available on CRAN](https://CRAN.R-project.org/package=collinear), combines four methods for easy management of multicollinearity in modelling data frames with numeric and categorical variables:

- **Target Encoding**: Transforms categorical predictors to numeric using a numeric response as reference.
- **Preference Order**: Ranks predictors by their association with a response variable to preserve important ones in multicollinearity filtering.
- **Pairwise Correlation Filtering**: Automated multicollinearity filtering of numeric and categorical predictors based 
## Main Improvements in Version 2.0.0

1. **Expanded Functionality**: Functions `collinear()` and `preference_order()` support both categorical and numeric responses and predictors, and can handle several responses at once.
2. **Robust Selection Algorithms**: Enhanced selection in `vif_select()` and `cor_select()`.
3. **Enhanced Functionality to Rank Predictors**: New functions to compute association between response and predictors covering most use-cases, and automated function selection depending on data features.
4. **Simplified Target Encoding**: Streamlined and parallelized for better efficiency, and new default is "loo" (leave-one-out).
5. **Parallelization and Progress Bars**: Utilizes `future` and `progressr` for enhanced performance and user experience.on pairwise correlations.
- **Variance Inflation Factor Filtering**: Automated multicollinearity filtering of numeric predictors based on Variance Inflation Factors.

The article [How It Works](https://blasbenito.github.io/collinear/articles/how_it_works.html) explains how the package works in detail.

## Citation

If you find this package useful, please cite it as:

*Blas M. Benito (2024). collinear: R Package for Seamless Multicollinearity Management. Version 2.0.0. doi: 10.5281/zenodo.10039489*

