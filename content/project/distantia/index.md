---
title: "R package distantia"
summary: R package to compare multivariate time-series with dynamic time warping and lock-step methods.
date: "2025-01-12T00:00:00Z"
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
links:
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://blasbenito.github.io/distantia/
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://CRAN.R-project.org/package=distantia
- icon: file-alt
  icon_pack: fas
  name: Ecography
  url: https://onlinelibrary.wiley.com/doi/epdf/10.1111/ecog.04895
tags: 
- Rstats
- Quantitative Methods
- Time Series Analysis
- Dynamic Time Warping
- Data Science
---

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/187805264.svg)](https://zenodo.org/badge/latestdoi/187805264)
[![CRAN\_Release\_Badge](https://www.r-pkg.org/badges/version-ago/distantia)](https://CRAN.R-project.org/package=distantia)
[![CRAN\_Download\_Badge](https://cranlogs.r-pkg.org/badges/distantia)](https://CRAN.R-project.org/package=distantia)

<!-- badges: end -->

## Description

The R package [**`distantia`**](https://blasbenito.github.io/distantia/), [available on CRAN](https://CRAN.R-project.org/package=distantia), offers an efficient, feature-rich toolkit for managing, comparing, and analyzing time series data. It is designed to handle a wide range of scenarios, including:

- Multivariate and univariate time series.
- Regular and irregular sampling. 
- Time series of different lengths.

## Key Features

### Comprehensive Analytical Tools

  - 10 distance metrics: see `distantia::distances`.
  - The normalized dissimilarity metric `psi`.
  - Free and Restricted Dynamic Time Warping (DTW) for shape-based comparison.
  - A Lock-Step method for sample-to-sample comparison
  - Restricted permutation tests for robust inferential support.
  - Analysis of contribution to dissimilarity of individual variables in multivariate time series.
  - Hierarchical and K-means clustering of time series based on dissimilarity matrices.
  
### Computational Efficiency

  - A **C++ back-end** powered by [Rcpp](https://www.rcpp.org/).
  - **Parallel processing** managed through the [future](https://future.futureverse.org/) package.
  - **Efficient data handling** via [zoo](https://CRAN.R-project.org/package=zoo).

### Time Series Management Tools

  - Introduces **time series lists** (TSL), a versatile format for handling collections of time series stored as lists of `zoo` objects.
  - Includes a suite of `tsl_...()` functions for generating, resampling, transforming, analyzing, and visualizing univariate and multivariate time series.
  
### Citation

If you find this package useful, please cite it as:

*Blas M. Benito, H. John B. Birks (2020). distantia: an open-source toolset to quantify dissimilarity between multivariate ecological time-series. Ecography, 43(5), 660-667. doi: [10.1111/ecog.04895](https://nsojournals.onlinelibrary.wiley.com/doi/10.1111/ecog.04895).*

*Blas M. Benito (2024). distantia: A Toolset for Time Series Dissimilarity Analysis. R package version 2.0.0. url:  [https://blasbenito.github.io/distantia/](https://blasbenito.github.io/distantia/).*

