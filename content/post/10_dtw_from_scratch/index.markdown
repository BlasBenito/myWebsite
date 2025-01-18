---
title: "Coding a Minimalistic Dynamic Time Warping Library with R"
author: ''
date: '2025-01-13'
slug: dynamic-time-warping-from-scratch
categories: []
tags: [Rstats]
subtitle: ''
summary: 'Tutorial on how to implement dynamic time warping in R'
authors: [admin]
lastmod: '2025-01-13T05:14:20+01:00'
featured: yes
draft: true
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
projects: []
---




# Summary

Dynamic Time Warping is a powerful method to compare univariate or multivariate time series by shape I explained in [previous post](https://www.blasbenito.com/post/dynamic-time-warping/). The objective of this post is to explain how DTW work by implementing a minimalistic yet fully functional dynamic time warping library with R. The tutorial focuses on code simplicity, and as such, it does not require any particular any particular level of competence in R.

# Design

## Example Data

Having good example data at hand is a must when developing new code. For this tutorial we use a subset of three multivariate time series of temperature, rainfall, and normalized vegetation index available in the R package [distantia](https://blasbenito.github.io/distantia/).

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" width="480" />

To facilitate our development, each time series is stored in an object of the class [zoo](https://CRAN.R-project.org/package=zoo), which is probably the most flexible time series management library in the R ecosystem.


``` r
zoo_sweden <- tsl$Sweden
zoo_spain <- tsl$Spain
zoo_germany <- tsl$Germany

class(zoo_sweden)
```

```
## [1] "zoo"
```

Each zoo object has a *core data* of the class "matrix" with one observation per row and one variable per column, and an *index*, which is a vector of dates, one per row in the data matrix.


``` r
zoo::coredata(zoo_sweden)
```

```
##         evi  rain temp
## 1092 0.1259  32.0 -4.4
## 1132 0.1901  55.6 -2.8
## 1142 0.2664  38.8  1.8
## 1152 0.2785  20.3  7.0
## 1162 0.7068  59.4 10.1
## 1172 0.7085  69.5 14.3
## 1182 0.6580  85.2 19.2
## 1192 0.5831 150.2 16.8
## 1202 0.5036  74.9 12.7
## 1103 0.3587  74.9  7.8
## 1113 0.2213 114.6  2.5
## 1122 0.1475  52.1 -4.7
## 1213 0.2140  49.5 -0.8
## attr(,"name")
## [1] "Sweden"
```


``` r
class(zoo::coredata(zoo_sweden))
```

```
## [1] "matrix" "array"
```


``` r
zoo::index(zoo_sweden)
```

```
##  [1] "2010-01-01" "2010-02-01" "2010-03-01" "2010-04-01" "2010-05-01"
##  [6] "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" "2010-10-01"
## [11] "2010-11-01" "2010-12-01" "2011-01-01"
```

## Required Functions

The section *DTW Step by Step* from the previous article [A Gentle Intro to Dynamic Time Warping](https://www.blasbenito.com/post/dynamic-time-warping/) shows the steps required to compute DTW. Below, these steps are broken down in sub-steps that will correspond to specific functionalities in our library:

**Pre-processing steps** 

These steps help DTW work as best as possible with the input data.

  - **Linear detrending**: forces time series to be stationary by removing any upwards or downwards trends. 
  - **Z-score normalization**: facilitates distance computation between samples multivariate time series and limits potential alignment issues in DTW.

**DTW steps**

Steps to perform DTW proper and evaluate the similarity between time series.

  - **Multivariate distance**: evaluate the distance between samples of each time series.
  - **Distance matrix**: organize the multivariate distances in a matrix.
  - **Cost matrix**: dynamic programming algorithm to accumulate distance across time.
  - **Least-cost path**: algorithm to find the path across the cost matrix that maximizes the alignment between both time series.
  - **Dissimilarity metric**: computation of a number to summarize the similarity/dissimilarity between time series.
  
**Main function**

Once all the steps above are implemented in their respective functions, we will wrap all them in a single function to streamline the DTW analysis.
  
# Implementation

In this section we will be developing the library function by function. Remember that the content of each code chunk should be added to the file `mini_dtw.R`.
    
### Linear Detrending

Applying linear detrending to a time series involves computing a linear model of each variable against time, and subtracting the result of the model prediction to the original data. This operation can be done in just two steps for a zoo object. 

First, the function `stats::lm()` can be applied to all variables in our time series at once


``` r
model_sweden <- stats::lm(
  formula = zoo_sweden ~ stats::time(zoo_sweden)
  )

model_sweden
```

```
## 
## Call:
## stats::lm(formula = zoo_sweden ~ stats::time(zoo_sweden))
## 
## Coefficients:
##                          evi         rain        temp      
## (Intercept)               8.965e-01  -1.710e+03  -5.706e+01
## stats::time(zoo_sweden)  -3.480e-05   1.202e-01   4.271e-03
```

Second, the residuals of the linear model represent the differences between the prediction and the observed data, which corresponds exactly with the detrended time series. As a plus, these residuals are returned as a zoo object.


``` r
zoo_sweden_detrended <- stats::residuals(model_sweden)
zoo_sweden_detrended
```

```
##                    evi         rain       temp
## 2010-01-01 -0.26214896 -13.62153187  -9.739028
## 2010-02-01 -0.19687011   6.25374419  -8.271433
## 2010-03-01 -0.11959566 -13.91052259  -3.791024
## 2010-04-01 -0.10641680 -36.13524652   1.276572
## 2010-05-01  0.32292725  -0.63981807   4.248439
## 2010-06-01  0.32570610   5.73545800   8.316034
## 2010-07-01  0.27625015  17.83088645  13.087901
## 2010-08-01  0.20242901  79.10616252  10.555496
## 2010-09-01  0.12400786   0.08143858   6.323092
## 2010-10-01 -0.01984809  -3.52313297   1.294959
## 2010-11-01 -0.15616924  32.45214310  -4.137446
## 2010-12-01 -0.22892518 -33.65242845 -11.465579
## 2011-01-01 -0.16134633 -39.97715238  -7.697983
## attr(,"name")
## [1] Sweden
```

``` r
plot(
  x = zoo_sweden_detrended, 
  col = "red4",
  mar = c(0.5, 5, 0, 5)
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-8-1.png" width="480" />

Then, the first function of our library could be something like this:


``` r
#' Linear Detrending
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_detrend <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  y
}
```

Notice that it could be more concise, but it is written to facilitate line-by-line debugging instead. I have also added minimal roxygen documentation. Future me usually appreciates this kind of extra effort.

We can now test the new function!


``` r
zoo_spain_detrended <- ts_detrend(x = zoo_spain)

plot(
  x = zoo_spain_detrended, 
  col = "red4",
  mar = c(0.5, 5, 0, 5)
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="480" />

The effect of our new function is not very noticeable because none of our time series have long-term trends, but let's try something different to check that our function actually detrends time series.

The code below creates a mock-up time series with an ascending trend.


``` r
x <- zoo::zoo(0:10)

plot(
  x = x, 
  col = "red4",
  mar = c(0.5, 1, 0, 1)
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-11-1.png" width="480" />

The detrending operation results in a horizontal line! Now we can be sure our detrending function works as expected.


``` r
x_detrended <- ts_detrend(x = x)

plot(
  x = x_detrended, 
  col = "red4",
  ylim = range(x),
  mar = c(0.5, 5, 0, 5)
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="672" />


### Z-score Normalization

The function `scale()`, from base R, already implements z-score normalization. When the library `zoo` is loaded, the method `zoo:::scale.zoo` (`:::` denotes unexported methods and functions) allows `scale()` to work seamlessly with zoo objects.


``` r
zoo_spain_scaled <- scale(
  x = zoo_spain,
  center = TRUE,
  scale = TRUE
  )

zoo_spain_scaled
```

```
##                    evi        rain        temp
## 2010-01-01 -1.12089017  1.51160789 -1.23268418
## 2010-02-01 -0.48784539 -0.07298081 -1.06804486
## 2010-03-01 -0.30228247 -0.31580088 -0.70217969
## 2010-04-01 -0.05190571 -0.55611765  0.04784391
## 2010-05-01  1.81615351 -0.13306001  0.17589672
## 2010-06-01  1.36423234  0.55034081  0.88933380
## 2010-07-01  1.06768681 -1.10934689  1.58447762
## 2010-08-01  0.82530080 -1.52239133  1.40154503
## 2010-09-01  0.23309762 -0.95414231  1.03567986
## 2010-10-01 -0.30494605  0.60040680  0.37712256
## 2010-11-01 -0.78705449  1.52913099 -0.44607407
## 2010-12-01 -1.38014553  1.16114593 -1.08633812
## 2011-01-01 -0.87140127 -0.68879254 -0.97657857
## attr(,"name")
## [1] Spain
## attr(,"scaled:center")
##        evi       rain       temp 
##  0.3405462 87.7153846 11.8384615 
## attr(,"scaled:scale")
##        evi       rain       temp 
##  0.1126303 39.9472745  5.4664947
```


``` r
class(zoo_spain_scaled)
```

```
## [1] "zoo"
```

Centering is performed by subtracting the column mean to each case, and results in a column mean equal to zero. Scaling divides each case by the standard deviation of the column, resulting in an overall standard deviation across cases equal to one.

This normalization step does not require a function in our library, but we can add it to our function `ts_detrend()` to encapsulate all pre-processing steps into a new function named `ts_preprocessing()`.


``` r
#' Linear Detrending and Normalization
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_preprocessing <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  y.scaled <- scale(x = y)
  y.scaled
}
```

Once we replace the old function with the new one, we can source the library and test it.


``` r
source("mini_dtw.R")

zoo_spain_ready <- ts_preprocessing(x = zoo_spain)

plot(
  x = zoo_spain_ready, 
  col = "red4",
  mar = c(0.5, 5, 0, 5)
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-16-1.png" width="480" />

### Distance Matrix

The computation of a distance matrix first requires a function to compute the multivariate distance between two arbitrary rows of separate zoo objects with the same number of columns.

#### Distance Function

The expression to compute Euclidean distances between two vectors `x` and `y` representing the rows of zoo objects is `sqrt(sum((x-y)^2))`. The function below implements this expression:


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
d_euclidean <- function(x, y){
  d <- sqrt(sum((x-y)^2))
  d
}
```

Implementing such a simple expression in a function is not a must, but it may facilitate the addition of new distance metrics to the library in the future.

We can test it right away, and let's ignore for now that none of our zoo objects are normalized yet.


``` r
d_euclidean(
  x = zoo::coredata(zoo_germany)[1, ],
  y = zoo::coredata(zoo_spain)[2, ]
)
```

```
## [1] 47.42971
```

Notice that I am using `zoo::coredata()` to extract the individual rows of each zoo object. Without this step, goofy things happen:


``` r
d_euclidean(
  x = zoo_germany[1, ],
  y = zoo_spain[2, ]
)
```

```
## [1] 0
```

We can also solve this quirk by using `as.numeric()` instead of `zoo::coredata()`:


``` r
d_euclidean(
  x = as.numeric(zoo_germany[1, ]),
  y = as.numeric(zoo_spain[2, ])
)
```

```
## [1] 47.42971
```

Then, moving these `as.numeric()` inside `d_euclidean()` will be helpful to simplify the usage of the function:


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
d_euclidean <- function(x, y){
  x <- as.numeric(x)
  y <- as.numeric(y)
  d <- sqrt(sum((x-y)^2))
  d
}

d_euclidean(
  x = zoo_germany[1, ],
  y = zoo_spain[2, ]
)
```

```
## [1] 47.42971
```

#### Distance Matrix

To generate the distance matrix, the new function must be applied to all pairs of rows in two zoo objects. A simple yet inefficient way to do this involves creating an empty matrix, and traversing it cell by cell to compute the euclidean distances between the corresponding pair of time series rows.


``` r
m_dist <- matrix(
  data = NA, 
  nrow = nrow(zoo_spain), 
  ncol = nrow(zoo_germany)
)

for(row.i in 1:nrow(zoo_spain)){
  for(col.j in 1:nrow(zoo_germany)){
    
    m_dist[row.i, col.j] <- d_euclidean(
      x = zoo_spain[row.i, ],
      y = zoo_germany[col.j, ]
    )
    
  }
}
```

This code generates a matrix in which the samples of `zoo_spain` are represented in the matrix rows from top to bottom, while `zoo_germany` is represented in the columns, from left to right.


``` r
m_dist[1:5, 1:5]
```

```
##           [,1]      [,2]      [,3]      [,4]     [,5]
## [1,] 110.30989 100.46823 113.10167 131.62363 51.83673
## [2,]  47.42971  37.38412  49.80095  68.36882 13.24344
## [3,]  38.34784  28.18370  40.16593  58.56706 21.93453
## [4,]  30.76948  20.76849  31.16425  48.91734 31.20312
## [5,]  46.71014  36.52524  47.92920  65.83052 14.33537
```

Now we can plot this distance matrix, but notice that the function `graphics::image()` rotates the distance matrix 90 degrees counter clock-wise before plotting, which can be pretty confusing at first.


``` r
par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_dist,
  xlab = "zoo_spain",
  ylab = "zoo_germany"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-24-1.png" width="240" />

Now first column in the plot represents the first row of our original matrix `m_dist`, so now `zoo_spain` is represented in the plot columns, and `zoo_germany` in the rows.

We can now wrap the code above (without the plot) in a new function named `distance_matrix()`.


``` r
#' Distance Matrix Between Time Series
#' @param x (required, zoo object) time series.
#' @param y (required, zoo object) time series with same columns as `x`
#' @return matrix
distance_matrix <- function(x, y){
  
  m_dist <- matrix(
    data = NA, 
    nrow = nrow(y), 
    ncol = nrow(x)
  )
  
  for(row.i in 1:nrow(y)){
    for(col.j in 1:nrow(x)){
      
      m_dist[row.i, col.j] <- d_euclidean(
        x = x[row.i, ],
        y = y[col.j, ]
      )
      
    }
  }
  
  m_dist
  
}
```

Let's run a little test before moving forward!


``` r
m_dist <- distance_matrix(
  x = zoo_spain,
  y = zoo_sweden
)

par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_dist,
  xlab = "zoo_sweden",
  ylab = "zoo_spain"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-26-1.png" width="240" />


### Cost Matrix

Now we are getting into the important parts of the DTW algorithm! 

A cost matrix is like a mountain landscape with a topography defined by the accumulation of distances across all possible alignment paths between two time series.  

First, we use the dimensions of the distance matrix to create an empty cost matrix.


``` r
m_cost <- matrix(
  data = NA, 
  nrow = nrow(m_dist), 
  ncol = ncol(m_dist)
  )
```

Second, to initialize the cost matrix we accumulate the values of the distance matrix across its first row and column using `cumsum()`, as follows:


``` r
m_cost[1, ] <- cumsum(m_dist[1, ])
m_cost[, 1] <- cumsum(m_dist[, 1])
```

This step is very important for the second part of the algorithm, as it provides the starting values.


``` r
par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_cost,
  xlab = "zoo_sweden",
  ylab = "zoo_spain"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-29-1.png" width="240" />

Now, before going into the third step, let's focus for a moment on the next cell of the cost matrix we need to fill. This cell, with coordinates `m_cost[2, 2]`, shown with value `NA` below.


``` r
m_cost[1:2, 1:2]
```

```
##          [,1]     [,2]
## [1,] 116.4881 209.3248
## [2,] 170.3028       NA
```
The new value of this cell must be the sum of its current value in the distance matrix `m_dist`, which is 30.4973625 with the minimum accumulated distance of its neighbors, which are `m_cost[1, 2]` with value 209.3248002, and `m_cost[2, 1]` with value 170.3027918. In summary, we have two possible steps, sum the distance in the empty cell with the cost of the upper one, or with the cost of the left one, and we have to choose the one that minimizes the value of the result.

For the target cell, this expression would be:


``` r
m_cost[2, 2] <- min(m_cost[1, 2], m_cost[2, 1 - 1]) + m_dist[2, 2]
```

Now, our cost matrix looks as follows:


``` r
m_cost[1:2, 1:2]
```

```
##          [,1]     [,2]
## [1,] 116.4881 209.3248
## [2,] 170.3028 239.8222
```

But there are many cells to fill yet!


``` r
par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_cost,
  xlab = "zoo_sweden",
  ylab = "zoo_spain"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-33-1.png" width="240" />

The expression we used to fill the cell `m_cost[2, 2]` can be generalized to fill the remaining empty cells using a nested loop that visits each new empty cell, identifies the neighbor with the smallest accumulated cost, and adds this accumulated cost to the distance value of the cell.


``` r
#iterate over rows of the cost matrix
for(row.i in 2:nrow(m_dist)){
  
  #iterate over columns of the cost matrix
  for(col.j in 2:ncol(m_dist)){
    
    #get cost of neighbor with minimum accumulated cost
    min_cost <- min(
      m_cost[row.i - 1, col.j], 
      m_cost[row.i, col.j - 1]
      )
    
    #add it to the distance of the target cell
    new_value <- min_cost + m_dist[row.i, col.j]
    
    #fill the empty cell with the new value
    m_cost[row.i, col.j] <- new_value
    
  }
}
```

Running the code above results in a nicely filled cost matrix!


``` r
par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_cost,
  xlab = "zoo_sweden",
  ylab = "zoo_spain"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-35-1.png" width="240" />

Now that we have all the pieces together, we can define our new function to compute the cost matrix.


``` r
#' Cost Matrix from Distance Matrix
#' @param m (required, matrix) distance matrix.
#' @return matrix
cost_matrix <- function(m){
  
  m_cost <- matrix(
    data = NA, 
    nrow = nrow(m), 
    ncol = ncol(m)
  )
  
  m_cost[1, ] <- cumsum(m[1, ])
  m_cost[, 1] <- cumsum(m[, 1])
  
  for(row.i in 2:nrow(m)){
    for(col.j in 2:ncol(m)){
      
      m_cost[row.i, col.j] <- min(
        m_cost[row.i - 1, col.j], 
        m_cost[row.i, col.j - 1]
      ) + m[row.i, col.j]
      
    }
  }
  
  m_cost
  
}
```

Let's run a small test using `m_dist` as input:


``` r
m_cost <- cost_matrix(m = m_dist)

par(mar = c(4, 4, 1, 1))
graphics::image(
  x = m_cost,
  xlab = "zoo_sweden",
  ylab = "zoo_spain"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-37-1.png" width="240" />

Yay, so far so good! Let's move onto the last step of the DTW algorithm.

### Least-Cost Path

### Dissimilarity Metric



## Library Source

Our library will *live* in a file named `mini_dtw.R`. We will be adding new R functions to this file as we progress with the implementation. Remember typing `source("mini_dtw.R")` everytime you add new code to this file to make the functions available in your R environment!
