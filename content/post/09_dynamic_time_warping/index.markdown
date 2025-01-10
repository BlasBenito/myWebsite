---
title: "A Gentle Intro to Dynamic Time Warping"
author: ''
date: '2025-01-05'
slug: dynamic-time-warping
categories: []
tags: [Time Series Analysis, Dynamic Time Warping]
subtitle: ''
summary: 'Brief introduction to Dynamic Time Warping with a conceptual step-by-step break down.'
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

  + [Dynamic Time Warping (Müller 2007)](https://www.audiolabs-erlangen.de/media/pages/fau/professor/mueller/publications/225d056498-1492348761/2007_Mueller_DTW-Chapter04-IR_Springer.pdf)
  + [Everything you know about Dynamic Time Warping is Wrong](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=598dcc162548d1deabc9ef8eaa2de7609b7c7682#page=53)
  + [distantia: an open-source toolset to quantify dissimilarity between multivariate ecological time-series](https://nsojournals.onlinelibrary.wiley.com/doi/full/10.1111/ecog.04895)
  + [Dynamic Time Warping vs Lock-Step](https://blasbenito.github.io/distantia/articles/dynamic_time_warping_and_lock_step.html)

# Summary

This post provides a gentle introduction to *Dynamic Time Warping*, a method to compare time series of different lengths that has applications.










# Comparing Time Series

Time series comparison is a critical task in many fields, such as environmental monitoring, finance, and healthcare. The goal is often to quantify similarities or differences between pairs of time series to gain insights in how the data is structured and identify meaningful patterns.

For example, the data below shows time series representing the same phenomena in three different places and time ranges: `a` and `b` have 30 synchronized observations, while `c` has 20 observations from a different year. 

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="750" />


There are several options to compare `a` and `b` directly, such as assessing their correlation (0.955), or computing the sum of euclidean distances between their respective samples (2.021). 

This comparison approach is named *lock-step* (also known as *inelastic comparison*), and works best when the time series represent phenomena with relatively similar shapes and are aligned in time and frequency, as it is the case of `a` and `b`.

Comparing `c` with `a` and/or `b` is a completely different task though, exactly the one [Dynamic Time Warping](https://en.wikipedia.org/wiki/Dynamic_time_warping) was designed for.

Now it'd make sense to explain right away what dynamic time warping is and how it works, but there's a bit of history to know about it first.

# A Useless Bit of History

Dynamic Time Warping (DTW) might sound like a modern high-tech buzzword, but its roots go way back—older than me (gen X guy here!). This powerful method was first developed in the pioneering days of speech recognition. The earliest reference I uncovered is from Shearme and Leach’s 1968 paper, [*Some experiments with a simple word recognition system*](https://doi.org/10.1109/TAU.1968.1161985), published by the Joint Speech Research Unit in the UK.

These foundational ideas were later expanded upon by Sakoe and Chiba in their seminal 1971 paper, [*A Dynamic Programming Approach to Continuous Speech Recognition*](https://api.semanticscholar.org/CorpusID:107516844), often regarded as the definitive starting point for modern DTW applications. 

From there, DTW found applications in diverse fields such as seismology, bioinformatics, and financial analysis. But one particular trans-disciplinary application of DTW brings me to write this post. In 1973, Gordon and Birks published the paper [*Numerical Methods in Quaternary Palaeoecology: II Comparison of Pollen Diagrams*](https://doi.org/10.1111/j.1469-8137.1974.tb04621.x), where DTW—renamed "sequence slotting"—was applied to combine pollen time series. This work inspired the development of the Fortran program [*SLOTSEQ*](https://doi.org/10.1016/0098-3004(80)90003-5) in 1980, which I somehow *inherited* 38 years later, resulting in version 1.0 of the R package [`distantia`](https://doi.org/10.1111/ecog.04895). Fast-forward to today, what brings you this article is my recent work on the [version 2.0 of the same package](https://github.com/BlasBenito/distantia).

Nowadays, Dynamic Time Warping is widely used across fields relying on time-dependent data, such as [medical sciences](https://doi.org/10.1016/j.bspc.2024.106677), [sports analytics](https://doi.org/10.1371/journal.pone.0272848), [astronomy](https://iopscience.iop.org/article/10.3847/1538-4357/ac4af6), [econometrics](https://doi.org/10.1016/j.eneco.2020.105036), [robotics](https://www.mdpi.com/2079-9292/8/11/1306), [epidemiology](https://doi.org/10.1111/exsy.13237), and many others.

Ok, let's stop wandering in time, and go back to the meat in this post.

# What is *Dynamic Time Warping*?

Dynamic Time Warping is a method to compare univariate or multivariate time series of different length, timing, and/or shape. To do so, DTW stretches or compresses parts of the time series (hence *warping*) until it finds the alignment that minimizes their overall differences. Think of it as a way to match the rhythm of two songs even if one plays faster than the other.

The figure below represents a dynamic time warping solution for the time series `c` and `a`. Notice how each sample in one time series matches one or several samples from the other. These matches are optimized to minimize the sum of distances between the samples they connect (3.285 in this case). Any other combination of matches would result in a higher sum of distances.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-5-1.png" width="750" />

In dynamic time warping, the actual *warping* happens when a sample in one time series is matched with two or more samples from the other, independently of their observation times. The figure below identifies one of these instances with blue bubbles. The sample 10 of `c` (upper blue bubble), with date 2022-07-16, is matched with the samples 14 to 16 of `a` (lower bubble), with dates 2023-12-13 to 2024-03-09. This matching structure represents a time compression in `a` for the range of involved dates.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-6-1.png" width="750" />

This ability to warp time makes DTW incredibly useful for analyzing time series that are similar in shape but don't have the same length or are not fully synchronized. 

The next section explains how DTW is computed on a step-by-step fashion.

# DTW: Step by Step

Time series comparison via Dynamic Time Warping (DTW) involves several key steps:

- **Detrending and z-score normalization** of the time series.
- **Computation of the distance matrix** between all pairs of samples.
- **Computation of a cost matrix** from the distance matrix.
- **Finding the least-cost path** within the cost matrix.
- **Computation of a similarity metric** based on the least-cost path.

## Detrending and Z-score Normalization

DTW is highly sensitive to differences in trends and ranges between time series (see the *Pitfalls* section). To address this, [detrending](https://sherbold.github.io/intro-to-data-science/09_Time-Series-Analysis.html#Trend-and-Seasonal-Effects) and [z-score normalization](https://developers.google.com/machine-learning/crash-course/numerical-data/normalization#z-score_scaling) are important preprocessing steps.

In this example, the time series `a` and `c` already have matching ranges, so normalization is not strictly necessary. For demonstration purposes, however, the figure below shows them normalized using z-score scaling:

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="750" />

## Distance Matrix

The next step involves computing the distance matrix, which contains pairwise distances between all samples in the two time series. 

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="600" />

Choosing an appropriate distance metric is crucial. While Euclidean distance works well in many cases, other metrics may be more suitable depending on the data.

## Cost Matrix

The cost matrix is derived from the distance matrix by accumulating distances dynamically from the starting corner (lower-left) to the ending corner (upper-right). Different rules for cell neighborhood determine how costs propagate:

  - **Orthogonal only**: Accumulation occurs in the *x* and *y* directions only, ignoring diagonals.
  - **Orthogonal and diagonal**: Diagonal movements are also considered, typically weighted by a factor of `√2` (1.414) to balance with orthogonal movements.

The figure below illustrates the cost matrix with both orthogonal and diagonal paths:

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" width="600" />

## Least-cost Path

This is where the actual time warping happens! 

The least-cost path minimizes the total cost from the start to the end of the cost matrix, aligning the time series optimally. The algorithm building the least-cost path starts on the upper right corner of the cost matrix, and recursively selects the antecedent neighbor with the lowest cost to build the least-cost path step by step.

The figure below shows the least-cost path (black line). Deviations from the diagonal represent adjustments made to align the time series.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="600" />

## Similarity Metric

Finally, DTW produces a similarity metric based on the least-cost path. The simplest approach is to sum the distances of all points along the path.



For this example, the total cost is 8.167. 
However, when comparing time series of varying lengths, normalization is often useful. Common options include:

  - **Sum of lengths**: Normalize by the combined lengths of the time series, e.g., `Normalized Cost = Total Cost / (Length(a) + Length(c))`. For `a` and `c`, this would be 0.163.
  - **Auto-sum of distances**: Normalize by the sum of distances between adjacent samples in each series, as in `Normalized Cost = Total Cost / (Auto-sum(a) + Auto-sum(c))`. For `a` and `c`, this results in 0.386.

These normalized metrics allow comparisons across datasets with varying characteristics.

# Pitfalls of Dynamic Time Warping

DTW is a powerful tool for time series comparison, but it comes with several challenges that users should be aware of when starting to work with it. Below is a summary of the most common pitfalls and how to mitigate them.

DTW is highly sensitive to differences in scale and trends in non-stationary time series. A time series with larger values or a strong trend might dominate the alignment, resulting in misleading results, the so-called *pathological alignments*, especially when one of the time series has noise, spikes, or outliers.

The figure below shows an example of pahological alignment between temperature time series of two major cities. It results from

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="750" />

These long straight lines in the least-cost path are clear features of a pathological alignment. They result from the algorithm *getting stuck* in a particular sample of one of the time series, which is matched with many samples from the other one.

There are two complementary approaches to mitigate this issue:

The first one involves z-score normalization, detrending, and maybe smoothing. These pre-processing steps alone can transform a pathological alignnment into a very healthy one, as the figure below shows.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-13-1.png" width="750" />
The second approach, which can be combined with the previous one, involves applying *constrained DTW*, which limits the area of the cost matrix the least-cost path can use. For example, *Sakoe-Chiba bands*, shown in the figure below, and *Itakura parallelograms* define an area at both sides of the cost matrix diagonal outside of which the least-cost path cannot cross.

However, as seen below, these methods have a limited ability to fix extremely pathological alignments, which mostly happen when the proper data preprocessing steps are ignored or skipped.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-14-1.png" width="750" />


Understanding these pitfalls and implementing the suggested mitigations can greatly improve the reliability of DTW-based analyses.

# Real World Applications

The [United States Patent and Trademark Office](https://www.uspto.gov/) has the [class 704/241](https://patents.justia.com/patents-by-us-classification/704/241) with the literal title "Dynamic Time Warping Patents". A similar category titled "Speech recognition using dynamic programming techniques, e.g. dynamic time warping [DTW]" [(G10L 15/12)](https://www.uspto.gov/web/patents/classification/cpc/pdf/cpc-scheme-G10L.pdf) exists in the [Cooperative Patent Classification](https://www.cooperativepatentclassification.org/home). 	

The patent search tool of the [European Patent Office](https://www.epo.org/en), [Spacenet](https://worldwide.espacenet.com/patent/), shows about [12k results for "Dynamic Time Warping"](https://worldwide.espacenet.com/patent/search/family/007654522/publication/US2002049591A1?q=%22dynamic%20time%20warping%22).

So there is no doubt about how valuable DTW is beyond academic papers. Let's take a closer look at a few of these applications.

**Wearables**

    Fitbit: Fitbit devices, like the Fitbit Charge or Fitbit Sense, use DTW in their activity recognition algorithms. DTW aligns accelerometer and gyroscope time series data with predefined templates for activities like walking, running, or cycling, ensuring accurate classification even if the user's movements vary.
    Apple Watch: While Apple’s systems rely on advanced AI models, DTW is often a key component in earlier motion pattern matching for fitness tracking and health monitoring.

2. Healthcare Devices

    Holter Monitors: Wearable heart monitoring devices like the Zio Patch or similar ECG monitors use DTW to align and compare heart rate time series with normal or pathological patterns, aiding in the detection of arrhythmias like atrial fibrillation.
    Continuous Glucose Monitors (CGMs): Devices like the Dexcom G6 may incorporate DTW to analyze glucose time series trends, ensuring accurate comparisons despite individual variations in data timing.

3. Speech Recognition and Audio Devices

    Google Nest and Amazon Echo: These smart speakers incorporate DTW in their keyword detection phase ("OK Google" or "Alexa") by matching incoming audio patterns with stored templates, even if spoken with different speeds or intonations.
    Sony ICD Voice Recorders: Professional audio recorders and transcribers may use DTW for aligning audio with text during transcription.

4. Music and Entertainment

    Shazam: Shazam’s music recognition algorithm historically used DTW to match audio fingerprints of songs played in real-time against a vast database, even when tempo or pitch varied slightly.
    Ableton Push (Music Production Tool): DTW is used in time-stretching and quantization features to align beats and melodies for seamless music production.

5. Industrial Devices

    GE Predix (Industrial IoT): Sensors in industrial equipment managed by platforms like GE Predix or Siemens MindSphere use DTW for predictive maintenance by aligning real-time sensor data with known patterns of normal or faulty operations.


# Open Source Implementations

This section lists several open source implementations of DTW in R and Python, in case you want to play with DTW.

## R 

  - [dtw](https://dynamictimewarping.github.io/), by Toni Giorgino: most complete DTW suite in R, with a companion paper [here](https://www.jstatsoft.org/article/view/v031i07). It also has a Python implementation linked below.
  - [dtwclust](https://cran.r-project.org/package=dtwclust), by Alexis Sarda-Espinosa: focused on applying DTW for time series clustering. It has a very comprehensive technical vignette [here](https://cran.r-project.org/web/packages/dtwclust/vignettes/dtwclust.pdf).
  - [IncDTW](https://cran.r-project.org/package=IncDTW), by Maximilian Leodolter: efficient implementation with a [companion paper](https://www.jstatsoft.org/article/view/v099i09), focused on fast DTW computations for real-time applications.
  - [distantia](https://blasbenito.github.io/distantia/), by myself: streamlined package to facilitate time series comparison and inference (permutation tests and variable importance scores) with DTW and lock-step methods.

## Python

  - [dtw-python](https://pypi.org/project/dtw-python/): Python implementation of [dtw](https://dynamictimewarping.github.io/).
  - [dtaidistance](https://github.com/wannesm/dtaidistance): fast C implementation of DTW, with a great documentation page [here](https://dtaidistance.readthedocs.io/en/latest/).
  - [tslearn](https://tslearn.readthedocs.io/en/stable/), by Romain Tavenard: focused on time series clustering via DTW for machine learning modeling.
  - [fastdtw](https://github.com/slaypni/fastdtw?tab=readme-ov-file), by Stan Salvador and Philip Chan: python implementation of FastDTW, a fast approximation to DTW described in [this paper](https://cs.fit.edu/~pkc/papers/tdm04.pdf).
  
## Other Languages

The [Wikipedia page on Dynamic Time Warping](https://en.wikipedia.org/wiki/Dynamic_time_warping) lists implementations in other languages in the section *Open Source Software*.

# Closing Thoughts

TODO: small paragraph with take-home details.

Blas

