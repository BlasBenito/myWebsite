---
title: "A Gentle Intro to Dynamic Time Warping"
author: ''
date: '2025-01-05'
slug: dynamic-time-warping
categories: []
tags: [Time Series Analysis, Dynamic Time Warping]
subtitle: ''
summary: 'Brief introduction to dynamic time warping and its role in the field of time series analysis.'
authors: [admin]
lastmod: '2025-01-05T05:14:20+01:00'
featured: no
draft: true
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
projects: []
---

# Resources

  + [distantia: an open-source toolset to quantify dissimilarity between multivariate ecological time-series](https://nsojournals.onlinelibrary.wiley.com/doi/full/10.1111/ecog.04895)
  + [Dynamic Time Warping vs Lock-Step](https://blasbenito.github.io/distantia/articles/dynamic_time_warping_and_lock_step.html)
  + [Everything you know about Dynamic Time Warping is Wrong](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=598dcc162548d1deabc9ef8eaa2de7609b7c7682#page=53)

# Summary




# A Useless Bit of History

Dynamic Time Warping (DTW) might sound like a high-tech buzzword, but its roots go way back—older than me. This powerful method was first developed in the pioneering days of speech recognition. The earliest reference I uncovered is from Shearme and Leach’s 1968 paper, [*Some experiments with a simple word recognition system*](https://doi.org/10.1109/TAU.1968.1161985), published by the Joint Speech Research Unit in the UK.

These foundational ideas were later expanded upon by Sakoe and Chiba in their seminal 1971 paper, [*A Dynamic Programming Approach to Continuous Speech Recognition*](https://api.semanticscholar.org/CorpusID:107516844), often regarded as the definitive starting point for modern DTW applications. 

From there, DTW found applications in diverse fields such as seismology, bioinformatics, and financial analysis. But one particular trans-disciplinary application of DTW brings me to write this post. In 1973, Gordon and Birks published the paper [*Numerical Methods in Quaternary Palaeoecology: II Comparison of Pollen Diagrams*](https://doi.org/10.1111/j.1469-8137.1974.tb04621.x), where DTW—renamed "sequence slotting"—was applied to combine pollen time series. This work inspired the development of the Fortran program [*SLOTSEQ*](https://doi.org/10.1016/0098-3004(80)90003-5) in 1980, which I somehow *inherited* 38 years later, resulting in version 1.0 of the R package [`distantia`](https://doi.org/10.1111/ecog.04895). Fast-forward to today, and my recent work on [version 2.0 of the same package](https://github.com/BlasBenito/distantia) is what brings us here.

Nowadays, Dynamic Time Warping is widely used across fields relying on time-dependent data, such as [medical sciences](https://doi.org/10.1016/j.bspc.2024.106677), [sports analytics](https://doi.org/10.1371/journal.pone.0272848), [astronomy](https://iopscience.iop.org/article/10.3847/1538-4357/ac4af6), [econometrics](https://doi.org/10.1016/j.eneco.2020.105036), [robotics](https://www.mdpi.com/2079-9292/8/11/1306), [epidemiology](https://doi.org/10.1111/exsy.13237), and many others.

## How It Works

Blas

