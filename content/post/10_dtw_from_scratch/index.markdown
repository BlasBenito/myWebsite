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
  caption: Dynamic time warping represented as a landscape.
  focal_point: Smart
  margin: auto
projects: []
---




# Summary

This post walks you through the implementation of a minimalistic yet fully functional [Dynamic Time Warping](https://www.blasbenito.com/post/dynamic-time-warping/) (DTW) library in R, built entirely from scratch without dependencies or complex abstractions. While there are many [open-source DTW implementations](https://blasbenito.github.io/distantia/articles/dtw_applications.html) readily available, understanding the inner workings of the algorithm can be invaluable. Whether you’re simply curious or need a deeper grasp of DTW for your projects, this step-by-step guide offers a hands-on approach to demystify the method.

# Design

## Example Data

Having good example data at hand is a must when developing new code. For this tutorial we use a subset of two multivariate time series of temperature, rainfall, and normalized vegetation index. To facilitate our development, the time series, named `zoo_spain` and `zoo_sweden`, are stored as objects of the class [zoo](https://CRAN.R-project.org/package=zoo), which is a very robust time series management library.



<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" /><img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-2.png" width="672" />

Each zoo object has a *core data* of the class `matrix` with one observation per row and one variable per column, and an *index*, which is a vector of dates, one per row in the core data.


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
zoo::index(zoo_sweden)
```

```
##  [1] "2010-01-01" "2010-02-01" "2010-03-01" "2010-04-01" "2010-05-01"
##  [6] "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" "2010-10-01"
## [11] "2010-11-01" "2010-12-01" "2011-01-01"
```


## Required Library Functions

The section *DTW Step by Step* from the previous article [A Gentle Intro to Dynamic Time Warping](https://www.blasbenito.com/post/dynamic-time-warping/) describes the computational steps required by the algorithm. Below, these steps are broken down into sub-steps that will correspond to specific functions in our library:

**Time Series Pre-processing** 

These steps help DTW work seamlessly with the input time series.

  - **Linear detrending**: forces time series to be stationary by removing any upwards or downwards trends. 
  - **Z-score normalization**: equalizes the range of the time series to ensure that the different variables contribute evenly to the distance computation.

**Dynamic Time Warping*

These steps perform dynamic time warping and evaluate the similarity between the time series.

  - **Multivariate distance**: compute distances between pairs of samples from each time series.
  - **Distance matrix**: organize the multivariate distances in a matrix in which each axis represents a time series.
  - **Cost matrix**: this matrix accumulates the distances in the distance matrix across time and represents all possible alignments between two time series.
  - **Least-cost path**: path in the cost matrix that minimizes the overall distance between two time series.
  - **Dissimilarity metric**: value to summarize the similarity/dissimilarity between time series.
  
**Main function**

Once all the steps above are implemented in their respective functions, we will wrap all them in a single function to streamline the DTW analysis.
  
# Implementation

In this section we will be developing the library function by function. Remember that the content of each code chunk should be added to the file `mini_dtw.R`.

## Time Series Pre-processing

In this section we create the function `ts_preprocessing()`, which will prepare the time series data for dynamic time warping. This function contains two functionalities: linear detrending, and z-score normalization.
    
### Linear Detrending

Applying linear detrending to a multivariate time series involves computing a linear model of each variable against time, and subtracting the the model prediction to the original data. This operation only requires two steps: 

First, the function `stats::lm()` can be applied to all variables in one of our time series at once


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

Second, the residuals of the linear model, which represent the differences between the prediction and the observed data, correspond exactly with the detrended time series. As a plus, these residuals are returned as a zoo object when the `zoo` library is loaded.


``` r
stats::residuals(model_sweden)
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

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-7-1.png" width="672" />
Then, the first function of our library could be something like this:


``` r
#' Linear Detrending
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_preprocessing <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  y
}
```

This function could be more concise, but it is written to facilitate line-by-line debugging instead. I have also added minimal roxygen documentation. Future me usually appreciates this kind of extra effort.

This function should check that `x` is really a zoo object, and any other condition that would make it fail. However, to keep code simple, in this tutorial we won't do any error catching.

Ok, we can now test the new function:


``` r
ts_preprocessing(x = zoo_spain)
```

```
##                    evi       rain       temp
## 2010-01-01 -0.16148483  60.641746 -5.7441690
## 2010-02-01 -0.08417502  -2.702107 -5.0137415
## 2010-03-01 -0.05784680 -12.441715 -3.1669038
## 2010-04-01 -0.02363699 -22.085568  0.7635236
## 2010-05-01  0.19257896  -5.228006  1.2994212
## 2010-06-01  0.14768877  22.028142  5.0298487
## 2010-07-01  0.12010472 -44.314296  8.6657462
## 2010-08-01  0.09881453 -60.858149  7.4961737
## 2010-09-01  0.03812435 -38.202002  5.3266012
## 2010-10-01 -0.01665971  23.855560  1.5624987
## 2010-11-01 -0.06494989  60.911708 -3.1070738
## 2010-12-01 -0.12593395  46.169270 -6.7711763
## 2011-01-01 -0.06262413 -27.774583 -6.3407488
## attr(,"name")
## [1] Spain
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-10-1.png" width="672" />
The effect of our new function is not very noticeable because none of our time series have long-term trends, but let's try something different to check that our function actually detrends time series. The code below creates a mock-up time series with an ascending trend.


``` r
x <- zoo::zoo(0:10)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="672" />

If we apply `ts_preprocessing()` to this time series, the result shows a horizontal line, which is a perfect linear detrending. Now we can be sure our implementation works!


``` r
x_detrended <- ts_preprocessing(x = x)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-14-1.png" width="672" />


### Z-score Normalization

Normalization consists of two operations: 

  - **Centering**: performed by subtracting the column mean to each case, and results in a column mean equal to zero. 
  - **Scaling**: divides each case by the standard deviation of the column, resulting in a column standard deviation equal to one.

The R base function `scale()` implements z-score normalization, so there's not much we have to do from scratch here. Also, when the library `zoo` is loaded, the method `zoo:::scale.zoo` (`:::` denotes methods and functions that are not exported) allows `scale()` to work seamlessly with zoo objects.


``` r
scale(
  x = zoo_spain,
  center = TRUE,
  scale = TRUE
  )
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

Normalization can be easily added to `ts_preprocessing()`:


``` r
#' Linear Detrending and Normalization
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_preprocessing <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  z <- scale(y)
  z
}
```

If you like pipes, a slightly more concise version of the same function is shown below. Both produce exaclty the same results, so it is just a matter of preference here.


``` r
ts_preprocessing <- function(x){
  y <- stats::lm(formula = x ~ stats::time(x)) |> 
    stats::residuals() |> 
    scale()
  y
}
```

You might find that using the intermediate object `y` is kinda silly, but being explicit about what the function should return might prevent a headache later on.

Anyway, we are ready to test `ts_preprocessing()` and move forward with our implementation


``` r
ts_preprocessing(x = zoo_spain)
```

```
##                   evi        rain       temp
## 2010-01-01 -1.4645859  1.51805802 -1.0582707
## 2010-02-01 -0.7634249 -0.06764242 -0.9237012
## 2010-03-01 -0.5246413 -0.31145617 -0.5834511
## 2010-04-01 -0.2143756 -0.55287283  0.1406669
## 2010-05-01  1.7465939 -0.13087381  0.2393974
## 2010-06-01  1.3394626  0.55143526  0.9266687
## 2010-07-01  1.0892892 -1.10932942  1.5965243
## 2010-08-01  0.8961979 -1.52347529  1.3810494
## 2010-09-01  0.3457686 -0.95631902  0.9813406
## 2010-10-01 -0.1510951  0.59718143  0.2878652
## 2010-11-01 -0.5890628  1.52481603 -0.5724284
## 2010-12-01 -1.1421573  1.15576538 -1.2474803
## 2011-01-01 -0.5679693 -0.69528717 -1.1681809
## attr(,"name")
## [1] Spain
## attr(,"scaled:center")
##           evi          rain          temp 
## -2.135044e-18  3.552714e-15  3.416071e-17 
## attr(,"scaled:scale")
##        evi       rain       temp 
##  0.1102597 39.9469224  5.4278824
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-19-1.png" width="672" />

## Dynamic Time Warping Functions

This section describes the implementation of the DTW algorithm, which requires functions to compute a distance matrix, convert it to a cost matrix, find a least-cost path maximizing the alignment between the time series, and compute their similarity.

### Distance Matrix

In DTW, a distance matrix represents all the distances between all pairs of samples in two time series. Hence, each time series is represented in one axis of the matrix. But before getting there, we need a function to obtain the distance between arbitrary pairs of rows from two separate zoo objects.

#### Distance Function

Let's say we have two vectors, `x` with one row of `zoo_spain`, and `y` with one row of `zoo_sweden`. Then, the expression to compute the Euclidean distances `x` and `y` is `sqrt(sum((x-y)^2))`. From there, implementing the distance function seems pretty trivial.


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
d_euclidean <- function(x, y){
  sqrt(sum((x - y)^2))
}
```

Notice that the function does not indicate the return explicitly. Since the function's body is a one-liner, one cannot be really worried about the function returning something unexpected. Also, implementing such a simple expression in a function might seem like too much, but it may facilitate the addition of new distance metrics to the library in the future. For example, we could create something like `d_manhattan()` with the Manhattan distance, and later switch between one or another depending on the user's needs.

The code below tests the function by computing the euclidean distance between the row 1 from `zoo_sweden` and the row 2 from `zoo_spain`.


``` r
zoo_sweden[1, ]
```

```
##               evi rain temp
## 2010-01-01 0.1259   32 -4.4
```

``` r
zoo_spain[2, ]
```

```
##               evi rain temp
## 2010-02-01 0.2856 84.8    6
```

``` r
d_euclidean(
  x = zoo_sweden[1, ],
  y = zoo_spain[2, ]
)
```

```
## [1] 0
```

What? That doesn't seem right! For whatever reason, `zoo_sweden[1, ]` and `zoo_spain[2, ]` are not being interpreted as numeric vectors by `d_euclidean()`. Let's try something different:


``` r
d_euclidean(
  x = as.numeric(zoo_sweden[1, ]),
  y = as.numeric(zoo_spain[2, ])
)
```

```
## [1] 53.81473
```
Ok, that makes more sense! Then, we just have to move these `as.numeric()` inside `d_euclidean()` to simplify the usage of the function:


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
d_euclidean <- function(x, y){
  x <- as.numeric(x)
  y <- as.numeric(y)
  z <- sqrt(sum((x - y)^2))
  z
}
```

The new function should have no issues returning the right distance between these rows now:


``` r
d_euclidean(
  x = zoo_sweden[1, ],
  y = zoo_spain[2, ]
)
```

```
## [1] 53.81473
```

That was kinda bumpy, but we can move on and go compute the distance matrix now.

#### Distance Matrix

To generate the distance matrix, the function `d_euclidean()` must be applied to all pairs of rows in the two zoo objects. A simple yet inefficient way to do this involves creating an empty matrix, and traversing it cell by cell to compute the euclidean distances between the corresponding pair of rows.


``` r
#empty distance matrix
m_dist <- matrix(
  data = NA, 
  nrow = nrow(zoo_spain), 
  ncol = nrow(zoo_sweden)
)

#iterate over rows
for(row in 1:nrow(zoo_spain)){
  
  #iterate over columns
  for(col in 1:nrow(zoo_sweden)){
    
    #distance between time series rows
    m_dist[row, col] <- d_euclidean(
      x = zoo_spain[row, ],
      y = zoo_sweden[col, ]
    )
    
  }
}
```

This code generates a matrix with `zoo_spain` in the rows, from top to bottom, and `zoo_sweden` in the columns, from left to right. The first five rows and columns are shown below.


``` r
m_dist[1:5, 1:5]
```

```
##           [,1]     [,2]      [,3]      [,4]      [,5]
## [1,] 116.48806 92.83674 109.34982 127.81414 88.842178
## [2,]  53.81473 30.49736  46.19135  64.50775 25.732225
## [3,]  44.84866 22.29133  36.82569  54.80913 15.844881
## [4,]  37.34359 17.88969  28.61791  45.48685  6.430277
## [5,]  53.25576 31.01171  44.96707  62.37084 23.158501
```

This matrix can be plotted with the function `graphics::image()`, but please be aware that it rotates the distance matrix 90 degrees counter clock-wise, which can be pretty confusing at first. Remember this: **in the matrix plot, the x axis represents the matrix rows**.


``` r
graphics::image(
  x = seq_len(ncol(m_dist)),
  y = seq_len(nrow(m_dist)),
  z = m_dist,
  xlab = "zoo_spain",
  ylab = "zoo_sweden",
  main = "Euclidean Distance"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-27-1.png" width="672" />

Darker values in the plot above indicate larger distances between pairs of samples in each time series.

We can now wrap the code above (without the plot) in a new function named `distance_matrix()`.


``` r
#' Distance Matrix Between Time Series
#' @param a (required, zoo object) time series.
#' @param b (required, zoo object) time series with same columns as `x`
#' @return matrix
distance_matrix <- function(a, b){
  
  m <- matrix(
    data = NA, 
    nrow = nrow(b), 
    ncol = nrow(a)
  )
  
  for(row in 1:nrow(b)){
    for(col in 1:nrow(a)){
      
      m[row, col] <- d_euclidean(
        x = a[row, ],
        y = b[col, ]
      )
      
    }
  }
  
  m
  
}
```

Let's run a little test before moving forward!


``` r
m_dist <- distance_matrix(
  a = zoo_spain,
  b = zoo_sweden
)

m_dist[1:5, 1:5]
```

```
##           [,1]     [,2]      [,3]      [,4]      [,5]
## [1,] 116.48806 92.83674 109.34982 127.81414 88.842178
## [2,]  53.81473 30.49736  46.19135  64.50775 25.732225
## [3,]  44.84866 22.29133  36.82569  54.80913 15.844881
## [4,]  37.34359 17.88969  28.61791  45.48685  6.430277
## [5,]  53.25576 31.01171  44.96707  62.37084 23.158501
```

We are good to go! The next function will transform this distance matrix into a *cost matrix*.

### Cost Matrix

Now we are getting into the important parts of the DTW algorithm! 

A cost matrix is like a valley's landscape, with hills in regions where the time series are different, and ravines where they are more similar. Such landscape is built by accumulating the values of the distance matrix cell by cell, from `[1, 1]` at the bottom of the valley (upper left corner of the matrix, but lower left in the plot), to `[m, n]` at the top (lower right corner of the matrix, upper right in the plot).

Let's see how that works.

First, we use the dimensions of the distance matrix to create an empty cost matrix.


``` r
m_cost <- matrix(
  data = NA, 
  nrow = nrow(m_dist), 
  ncol = ncol(m_dist)
  )
```

Second, to initialize the cost matrix we accumulate the values of the first row and the first column of the distance matrix using `cumsum()`. This step is very important for the second part of the algorithm, as it provides the starting values.


``` r
m_cost[1, ] <- cumsum(m_dist[1, ])
m_cost[, 1] <- cumsum(m_dist[, 1])
```


<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-32-1.png" width="672" />

Now, before going into the third step, let's focus for a moment on the next cell of the cost matrix we need to fill, with coordinates `[2, 2]` and value `NA`.


``` r
m_cost[1:2, 1:2]
```

```
##          [,1]     [,2]
## [1,] 116.4881 209.3248
## [2,] 170.3028       NA
```

The new value of this cell results from the addition of:

  - Its value in the distance matrix `m_dist` (30.5).
  - The minimum accumulated distance of its neighbors, which are:
      - Upper neighbor with coordinates `[1, 2]`.
      - Left neighbor with coordinates `[2, 1]`. 
      
NOTE: DTW can also consider diagonal neighborhood, but in this tutorial we only focus on orthogonal moves to keep the code as simple as possible.

The general expression to find the value of the empty cell is shown below. It uses `min()` to get the value of the *smallest* neighbor, and then adds it to the vaue of the target cell in the distance matrix.


``` r
m_cost[2, 2] <- min(
  m_cost[1, 2], 
  m_cost[2, 1]
  ) + m_dist[2, 2]

m_cost[1:2, 1:2]
```

```
##          [,1]     [,2]
## [1,] 116.4881 209.3248
## [2,] 170.3028 200.8002
```

But there are many cells to fill yet!

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-35-1.png" width="672" />

The expression we used to fill the cell `m_cost[2, 2]` can be generalized to fill all remaining empty cells. We just have to wrap it in a nested loop that for each new empty cell identifies the smallest neighbor in the x and y axies, and adds its cumulative cost to the distance of new cell.


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

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-37-1.png" width="672" />

Still, there is one more step left! For a reason that will remain unclear until the next section, the terminal cell `[13, 13]` of the cost matrix must have a higher value than any pf its immediate neighbors. If we look at the lower left corner (upper left in the plot) of our cost matrix, this is not the case yet.


``` r
m <- nrow(m_cost)
n <- ncol(m_cost)
m_cost[(m-1):m, (n-1):n]
```

```
##          [,1]     [,2]
## [1,] 763.3223 848.1872
## [2,] 749.0092 761.9623
```

To fix this issue, it is customary to sum the cost of the first cell of the cost matrix, `m_cost[1, 1]`, to the last one `m_cost[m, n]`.


``` r
m_cost[m, n] <- m_cost[m, n] + m_cost[1, 1]

m_cost[(m-1):m, (n-1):n]
```

```
##          [,1]     [,2]
## [1,] 763.3223 848.1872
## [2,] 749.0092 878.4503
```

Now that we have all the pieces figured out, we can define our new function to compute the cost matrix. Notice that the code within the nested loops is slightly more concise than shown before.


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
  
  for(row in 2:nrow(m)){
    for(col in 2:ncol(m)){
      
      m_cost[row, col] <- min(
        m_cost[row - 1, col], 
        m_cost[row, col - 1]
      ) + m[row, col]
      
    }
  }
  
  m_cost[row.i, col.j] <- m_cost[row.i, col.j] + m_cost[1, 1]
  
  m_cost
  
}
```

Let's test our new function using `m_dist` as input!


``` r
m_cost <- cost_matrix(m = m_dist)
```


``` r
graphics::image(
  x = seq_len(ncol(m_cost)),
  y = seq_len(nrow(m_cost)),
  z = m_cost,
  xlab = "zoo_spain",
  ylab = "zoo_sweden",
  main = "Cost Matrix"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-42-1.png" width="672" />

So far so good! We can now dive into the generation of the least-cost path.

### Least-Cost Path

If we describe the cost matrix as a valley with its hills and ravines, then the least-cost path is the river flowing all its way to the bottom following the line of maximum slope. Following the analogy, the least-cost path starts in the terminal cell of the cost matrix (`[13, 13]`), and ends in the first cell.

To find the least-cost path we first define a data frame with the coordinates of the terminal cell in the cost matrix.


``` r
path <- data.frame(
  row = ncol(m_cost),
  col = nrow(m_cost)
)

path
```

```
##   row col
## 1  13  13
```

This is the first step of the least cost path. Now, there are two alternative new steps to consider:

  - *one column left*: `[row, col - 1]`.
  - *one row up*: `[row - 1, col]`.
  
But before moving forward, notice that if we apply these steps indefinitely in our cost matrix, at some point a move up `row - 1` or left `col - 1` will go out of bounds and produce an error. That's why it's safer to define the next move as...

  - *one column left*: `[row, max(col - 1, 1)]`.
  - *one row up*: `[max(row - 1, 1), col]`


...which confines all steps within the first row and column of the cost matrix. 

With that out of the way, now we have to select the move towards a cell with a lower cost. There are many ways to accomplish this task! Let's look one of them.

First, we define the candidate moves using the first row of the least-cost path as reference.


``` r
steps <- list(
  left = c(path$row, max(path$col - 1, 1)),
  up = c(max(path$row - 1, 1), path$col)
)

steps
```

```
## $left
## [1] 13 12
## 
## $up
## [1] 12 13
```
Notice that the function returns a list with the coordinates of the candidate moves. The move `left` is one column to the left (second number is 12 instead of 13), and the move `up` is one row above (first number is 12 instead of 13).

Second, we need to extract the values of the cost matrix for the coordinates of these two steps.


``` r
costs <- list(
  left = m_cost[steps$left[1], steps$left[2]],
  up = m_cost[steps$up[1], steps$up[2]]
)

costs
```

```
## $left
## [1] 749.0092
## 
## $up
## [1] 848.1872
```

Finally, we choose the candidate step with the lower cost using `which.min()`, a function that returns the index of the smallest value in a vector or list. Notice that we use `[1]` in `which.min(costs)[1]` to resolve potential ties that may be returned by `which.min()` if the two costs are the same (unlikely, but possible).


``` r
steps[[which.min(costs)[1]]]
```

```
## [1] 13 12
```

Combining these pieces we can now build a function named `next_step()` that takes the cost matrix and the last row of a least cost path, and returns a new row with the coordinates of the next step.
  

``` r
#' Identify Next Step of Least-Cost Path
#' @param m (required, matrix) cost matrix.
#' @param step one row data frame with columns "row" and "col"
#' @return one row data frame
next_step <- function(m, step){
  
  steps <- list(
    left = c(step$row, max(step$col - 1, 1)),
    up = c(max(step$row - 1, 1), step$col)
  )
  
  costs <- list(
    left = m[steps$left[1], steps$left[2]],
    up = m[steps$up[1], steps$up[2]]
  )
  
  coords <- steps[[which.min(costs)[1]]]
  
  #rewrite input with new values
  step[,] <- c(coords[1], coords[2])
  
  step
  
}
```

Notice that the function overwrites the input data frame `step` with the new values. Let's check how it works:


``` r
next_step(
  m = m_cost, 
  step = path
  )
```

```
##   row col
## 1  13  12
```

Good, it returned the move to the left. Now, if you think about the function for a bit, you'll see that it takes a step in the least-cost path, and returns a new one. From there, it seems we can feed it its own result again and again until it runs out of steps to find.

We can do that in a concise way using a `repeat{}` loop. Notice that it will keep running until both coordinates in the last row of the path are equal to 1.


``` r
repeat{
  
  #find next step
  new.step <- next_step(
    m = m_cost, 
    step = tail(path, n = 1)
    )
  
  #join the new step with path
  path <- rbind(
    path, new.step,
    make.row.names = FALSE
    )
  
  #stop when coordinates are 1, 1
  if(all(tail(path, n = 1) == 1)){break}
  
}

path
```

```
##    row col
## 1   13  13
## 2   13  12
## 3   13  11
## 4   12  11
## 5   11  11
## 6   10  11
## 7   10  10
## 8    9  10
## 9    8  10
## 10   7  10
## 11   6  10
## 12   5  10
## 13   5   9
## 14   5   8
## 15   5   7
## 16   5   6
## 17   4   6
## 18   4   5
## 19   4   4
## 20   4   3
## 21   4   2
## 22   3   2
## 23   2   2
## 24   2   1
## 25   1   1
```
  
The resulting least-cost path can be plotted on top of the cost matrix. Please, remember that the data is not pre-processed, and the plot below does not represent the real alignment (yet) between our target time series.


``` r
graphics::image(
    x = seq_len(ncol(m_cost)),
    y = seq_len(nrow(m_cost)),
    z = m_cost,
    xlab = "zoo_spain",
    ylab = "zoo_sweden",
    main = "Cost Matrix and Least-Cost Path"
    )

graphics::lines(
  x = path$row, 
  y = path$col,
  lwd = 2
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-50-1.png" width="672" />
At this point we have all the pieces required to write the function `least_cost_path()`. Notice that the `repeat{}` statement is slightly more concise than before, as `next_step()` is directly wrapped within `rbind()`


``` r
#' Least-Cost Path from Cost Matrix
#' @param m (required, matrix) cost matrix.
#' @return data frame with least-cost path coordinates
least_cost_path <- function(m){
  
  #first step of the least cost path
  path <- data.frame(
    row = ncol(m),
    col = nrow(m)
  )
  
  #iterate until path is completed
  repeat{
    
    #merge path with result of next_step()
    path <- rbind(
      path, 
      #find next step
      next_step(
        m = m, 
        step = tail(path, n = 1)
      ),
      make.row.names = FALSE
    )
    
    #stop when coordinates are 1, 1
    if(all(tail(path, n = 1) == 1)){break}
    
  }
  
  path
  
}
```

We can give it a go to see that it works as expected:


``` r
least_cost_path(m = m_cost)
```

```
##    row col
## 1   13  13
## 2   13  12
## 3   13  11
## 4   12  11
## 5   11  11
## 6   10  11
## 7   10  10
## 8    9  10
## 9    8  10
## 10   7  10
## 11   6  10
## 12   5  10
## 13   5   9
## 14   5   8
## 15   5   7
## 16   5   6
## 17   4   6
## 18   4   5
## 19   4   4
## 20   4   3
## 21   4   2
## 22   3   2
## 23   2   2
## 24   2   1
## 25   1   1
```






``` r
distantia::distantia_dtw_plot(
  tsl = tsl,
  diagonal = FALSE
)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-53-1.png" width="672" />


### Dissimilarity Metric

Once the least-cost path is defined, we need to extract the value of the **distance matrix** for each one of its coordinates.


``` r
path$distance <- m_dist[as.matrix(path)]
```

## Library Source

Our library will *live* in a file named `mini_dtw.R`. We will be adding new R functions to this file as we progress with the implementation. Remember typing `source("mini_dtw.R")` everytime you add new code to this file to make the functions available in your R environment!
