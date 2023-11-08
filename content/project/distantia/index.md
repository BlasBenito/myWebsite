---
date: "2020-12-19T00:00:00Z"
external_link: ""
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
links:
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://github.com/BlasBenito/distantia
- icon: r-project
  icon_pack: fab
  name: CRAN
  url: https://CRAN.R-project.org/package=distantia
- icon: file-alt
  icon_pack: fas
  name: Ecography
  url: https://onlinelibrary.wiley.com/doi/epdf/10.1111/ecog.04895
summary: R package to compare multivariate time-series.
tags: 
- R packages
- Time Series Analysis
title: R package `distantia`
url_code: ""
url_pdf: ""
url_slides: ""
url_video: ""
---

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/187805264.svg)](https://zenodo.org/badge/latestdoi/187805264)
[![CRAN\_Release\_Badge](https://www.r-pkg.org/badges/version-ago/distantia)](https://CRAN.R-project.org/package=distantia)
[![CRAN\_Download\_Badge](https://cranlogs.r-pkg.org/badges/distantia)](https://CRAN.R-project.org/package=distantia)

<!-- badges: end -->

The package *distantia* allows to measure the dissimilarity between multivariate time-series. The package assumes that the target sequences are ordered along a given dimension, being depth and time the most common ones, but others such as latitude or elevation are also possible. Furthermore, the target time-series can be regular or irregular, and have their samples aligned (same age/time/depth) or unaligned (different age/time/depth). The only requirement is that the sequences must have at least two (but ideally more) columns with the same name and units representing different variables relevant to the dynamics of a system of interest.

The [GitHub page](https://github.com/BlasBenito/distantia) of the project contains a thorough explanation of the statistics behind the method. The [paper published in the Ecography journal](https://onlinelibrary.wiley.com/doi/full/10.1111/ecog.04895) describes the method, the package, and a couple of practical examples. The code and data used to develop the examples can be found in [GitHub](https://github.com/BlasBenito/distantiaPaper) and [Zenodo](https://zenodo.org/record/3520959#.X94GNtYo-1c). 

Please, if you find this package useful, please cite it as:

*Benito, B.M. and Birks, H.J.B. (2020), distantia: an open‐source toolset to quantify dissimilarity between multivariate ecological time‐series. Ecography, 43: 660-667. https://doi.org/10.1111/ecog.04895*

