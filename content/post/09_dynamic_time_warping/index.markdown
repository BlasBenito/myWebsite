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










# Comparing Time Series

Time series comparison is a critical task in many fields, such as environmental monitoring, finance, and healthcare. The goal is often to quantify similarities or differences between pairs of time series to gain insights in how the data is structured and identify meaningful patterns.

For example, the data below shows time series representing the same phenomena in three different places and time ranges: `a` and `b` have 30 synchronized observations, while `c` has 20 observations from a different year. 

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="750" />


There are several options to compare `a` and `b` directly, such as computing their correlation (0.955), or adding the euclidean distances between their respective samples (2.021). 

This comparison approach is named *lock-step* (also known as *inelastic comparison*), and works best when the time series represent phenomena with relatively similar shapes and are aligned in time and frequency, as it is the case of `a` and `b`.

Comparing `c` with `a` or `b` is a completely different task though, exactly the one *Dynamic Time Warping* was designed for.

Now it'd make sense to explain right away what dynamic time warping is and how it works, but there's a bit of history to know about it first.

# A Useless Bit of History

Dynamic Time Warping (DTW) might sound like a modern high-tech buzzword, but its roots go way back—older than me (gen X guy here!). This powerful method was first developed in the pioneering days of speech recognition. The earliest reference I uncovered is from Shearme and Leach’s 1968 paper, [*Some experiments with a simple word recognition system*](https://doi.org/10.1109/TAU.1968.1161985), published by the Joint Speech Research Unit in the UK.

These foundational ideas were later expanded upon by Sakoe and Chiba in their seminal 1971 paper, [*A Dynamic Programming Approach to Continuous Speech Recognition*](https://api.semanticscholar.org/CorpusID:107516844), often regarded as the definitive starting point for modern DTW applications. 

From there, DTW found applications in diverse fields such as seismology, bioinformatics, and financial analysis. But one particular trans-disciplinary application of DTW brings me to write this post. In 1973, Gordon and Birks published the paper [*Numerical Methods in Quaternary Palaeoecology: II Comparison of Pollen Diagrams*](https://doi.org/10.1111/j.1469-8137.1974.tb04621.x), where DTW—renamed "sequence slotting"—was applied to combine pollen time series. This work inspired the development of the Fortran program [*SLOTSEQ*](https://doi.org/10.1016/0098-3004(80)90003-5) in 1980, which I somehow *inherited* 38 years later, resulting in version 1.0 of the R package [`distantia`](https://doi.org/10.1111/ecog.04895). Fast-forward to today, and my recent work on [version 2.0 of the same package](https://github.com/BlasBenito/distantia) is what brings us here.

Nowadays, Dynamic Time Warping is widely used across fields relying on time-dependent data, such as [medical sciences](https://doi.org/10.1016/j.bspc.2024.106677), [sports analytics](https://doi.org/10.1371/journal.pone.0272848), [astronomy](https://iopscience.iop.org/article/10.3847/1538-4357/ac4af6), [econometrics](https://doi.org/10.1016/j.eneco.2020.105036), [robotics](https://www.mdpi.com/2079-9292/8/11/1306), [epidemiology](https://doi.org/10.1111/exsy.13237), and many others.

Ok, let's stop wandering in time, and go back to the meat in this post.

# What is *Dynamic Time Warping*?

Dynamic Time Warping is a method to compare univariate or multivariate time series of different length, timing, or shape. To do so, DTW stretches or compresses (hence *warping*) parts of the time series until it finds the alignment that minimizes their overall differences. Think of it as a way to match the rhythm of two songs even if one plays faster than the other.

The figure below represents the dynamic time warping of the time series `c` and `a`. Notice how each sample in one time series matches one or several samples from the other. These matches are optimized to minimize the sum of distances between the samples they connect (3.285 in this case). Any other combination of matches would result in a higher sum of distances.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-5-1.png" width="750" />

In dynamic time warping, the *time warping* happens when a sample in one time series is matched with two or more samples of the other, independently of their observation times. The figure below identifies one of these instances with blue bubbles. The sample 10 of `c` (upper blue bubble), with date 2022-07-16, is matched with the samples 14 to 16 of `a` (lower bubble), with dates 2023-12-13 to 2024-03-09. This matching structure represents a time compression in `a` for the range of involved dates.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-6-1.png" width="750" />
This ability to warp time makes DTW incredibly useful for analyzing time series that are similar in shape but don't have the same length or are not fully synchronized. 


# DTW Step by Step

Time series comparison via Dynamic Time Warping requires several steps:

  - Detrending and z-score normalization of the time series.
  - Computation of the distance matrix between all pairs of samples.
  - Computation of a cost matrix from the distance matrix.
  - Finding the least-cost path within the cost matrix.
  - Computation of a similarity metric based on the least-cost path.
  
## Detrending and Z-score Normalization

The first step to perform DTW does not pertain DTW itself, but the time series data. DTW is highly sensitive to significant differences in data trends and ranges (see section *Pitfalls*), which turns detrending and z-score normalization into pre-requirements to perform DTW correctly.

The time series `a` and `c` don't need detrending, and they already have matching ranges between 0 and 1, so they would not require z-score normalization. However, and only for the sake of the example, the figure below shows them normalized.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="750" />

## Distance Matrix

The second step in DTW is computing the distance matrix between all pairs of samples in both time series, which is shown in the figure below.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="600" />
The selection of a proper distance metric is key here, because all other DTW steps depend on an accurate representation of the distances between time series samples. In general, Euclidean distance may work well in most cases, but there are data types that may require different metrics.

## Cost Matrix

This step involves transforming the distance matrix into a cost matrix using a dynamic algorithm that accumulates distances from the starting corner of the distance matrix (lower left) towards the ending corner using different cell neighborhood rules:

  - **Orthogonal only**: Distance accumulation only happens in the *x* and *y* axes, completely ignoring diagonals.
  - **Orthogonal and diagonal**: Distance accumulation is also computed in diagonals, which are usually weighted by a factor of `1.414214` so they don't outcompete orthogonal movements.
  
The figure below shows the orthogonal and diagonal cost matrix of the time series `a` and `c`.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" width="600" />

## Least-cost Path

This is the step that actually does the time warping! It involves finding the path between the corners of the cost matrix that minimizes the overall movement cost, just like a river finds its way between the mountains.

Like the computation of the cost matrix, the cost path can consider orthogonal movements only, or orthogonal and diagonal ones. In any case, the method used to compute the cost matrix must match the method used to build the least-cost path.

The figure below shows the least-cost path between `a` and `c` in black. Any deviation of the least-cost path from the white diagonal indicates an adjustment made to optimize the alignment between both time series.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="600" />

## Similarity Metric

All the steps above are just the means to obtain an statistic representing the similarity between both time series.



In its simplest form, this number can be the sum of distances between pairs of samples connected by the least cost path, which is 8.167 in this case. 

However, when many time series of different lengths are involved in the analysis, it is convenient to normalize this number by some quantity. There are several options for this normalization factor:

  - Sum of lengths of the time series: this would be `2.663/(30 + 20)` for `a` () and `c`, resulting in 0.163.
  - Auto-sum of distances between consecutive samples in both time series: this normalization factor results from adding the distances between the adjacent samples in both time series, such as `D(a[1], a[2]) + D(a[2], a[3]) + ... D(c[1], c[2]) + D(c[2], c[3]) + ...`. For `a` this would be 11.044, for `c`, 10.125, and hence, the normalized distance between them would be `2.663/(11.044 + 10.125) = 0.126`.


# Pitfalls

TODO: Explain pathological alignments and approaches to detect and limit them.

# Computational considerations

TODO: Maximum data sizes that can be addressed with naive DTW, and a few steps to reduce the computational load (data resampling)

# Closing Thoughts

TODO: small paragraph with take-home details.

Blas

