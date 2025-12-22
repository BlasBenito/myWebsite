---
title: "Coding a Minimalistic Dynamic Time Warping Library with R"
author: ''
date: '2025-01-13'
slug: dynamic-time-warping-from-scratch
categories: []
tags: 
- Rstats
- Dynamic Time Warping
- Data Science
- Scientific Programming
- Tutorial
- Time Series Analysis
subtitle: ''
summary: 'Tutorial on how to implement dynamic time warping in R'
authors: [admin]
lastmod: '2025-01-13T05:14:20+01:00'
featured: yes
draft: false
image:
  caption: Dynamic time warping represented as a landscape.
  focal_point: Smart
  margin: auto
projects: []
toc: true
---




## Summary

This post walks you through the implementation of a minimalistic yet fully functional [Dynamic Time Warping](https://www.blasbenito.com/post/dynamic-time-warping/) (DTW) library in R, built entirely from scratch without dependencies or complex abstractions. While there are many [open-source DTW implementations](https://blasbenito.github.io/distantia/articles/dtw_applications.html) readily available, understanding the inner workings of the algorithm can be invaluable. Whether you’re simply curious or need a deeper grasp of DTW for your projects, this step-by-step guide offers a hands-on approach to demystify the method.

## Design

### Example Data

Having good example data at hand is a must when developing new code. For this tutorial we use three multivariate time series of temperature, rainfall, and normalized vegetation index. These time series are named `zoo_germany`, `zoo_sweden`, and `zoo_spain`, and are stored as objects of the class [zoo](https://CRAN.R-project.org/package=zoo), which is a very robust time series management library.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-2-1.png" alt="" width="672" />

Each zoo object has a *core data* of the class `matrix` with one observation per row and one variable per column, and an *index*, which is a vector of dates, one per row in the time series.


``` r
zoo::coredata(zoo_sweden)
```

```
##         evi rainfall temperature
## 1092 0.1259     32.0        -4.4
## 1132 0.1901     55.6        -2.8
## 1142 0.2664     38.8         1.8
## 1152 0.2785     20.3         7.0
## 1162 0.7068     59.4        10.1
## 1172 0.7085     69.5        14.3
## 1182 0.6580     85.2        19.2
## 1192 0.5831    150.2        16.8
## 1202 0.5036     74.9        12.7
## 1103 0.3587     74.9         7.8
## 1113 0.2213    114.6         2.5
## 1122 0.1475     52.1        -4.7
## 1213 0.2140     49.5        -0.8
## attr(,"name")
## [1] "zoo_sweden"
```

``` r
zoo::index(zoo_sweden)
```

```
##  [1] "2010-01-01" "2010-02-01" "2010-03-01" "2010-04-01" "2010-05-01"
##  [6] "2010-06-01" "2010-07-01" "2010-08-01" "2010-09-01" "2010-10-01"
## [11] "2010-11-01" "2010-12-01" "2011-01-01"
```


### Required Library Functions

The section *DTW Step by Step* from the previous article [A Gentle Intro to Dynamic Time Warping](https://www.blasbenito.com/post/dynamic-time-warping/) describes the computational steps required by the algorithm. Below, these steps are broken down into sub-steps that will correspond to specific functions in our library:

**Time Series Pre-processing** 

These steps help DTW work seamlessly with the input time series.

  - **Linear detrending**: forces time series to be stationary by removing any upwards or downwards trends. 
  - **Z-score normalization**: equalizes the range of the time series to ensure that the different variables contribute evenly to the distance computation.

**Dynamic Time Warping**

These steps perform dynamic time warping and evaluate the dissimilarity between the time series.

  - **Multivariate distance**: compute distances between pairs of samples from each time series.
  - **Distance matrix**: organize the multivariate distances in a matrix in which each axis represents a time series.
  - **Cost matrix**: this matrix accumulates the distances in the distance matrix across time and represents all possible alignments between two time series.
  - **Least-cost path**: path in the cost matrix that minimizes the overall distance between two time series.
  - **Dissimilarity metric**: value to summarize the dissimilarity between time series.
  
**Main function**

Once all the steps above are implemented in their respective functions, we will wrap all them in a single function to streamline the DTW analysis.
  
## Implementation

In this section we will be developing the library concept by concept and function by function.

## Time Series Pre-processing

In this section we develop the function `ts_preprocessing()`, which will prepare the time series data for dynamic time warping. This function contains two functionalities: **linear detrending**, and **z-score normalization**.
    
### Linear Detrending

Applying linear detrending to a multivariate time series involves computing a linear model of each variable against time, and subtracting the model prediction to the original data. This can be performed in two steps: 

First, the function `stats::lm()` can be applied to all variables in one of our time series at once.



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
##                          evi         rainfall    temperature
## (Intercept)               8.965e-01  -1.710e+03  -5.706e+01 
## stats::time(zoo_sweden)  -3.480e-05   1.202e-01   4.271e-03
```

Second, the residuals of the linear model, which represent the differences between observations and predictions, correspond exactly with the detrended time series. As a plus, these residuals are returned as a zoo object when the `zoo` library is loaded!


``` r
stats::residuals(model_sweden)
```

```
##                    evi     rainfall temperature
## 2010-01-01 -0.26214896 -13.62153187   -9.739028
## 2010-02-01 -0.19687011   6.25374419   -8.271433
## 2010-03-01 -0.11959566 -13.91052259   -3.791024
## 2010-04-01 -0.10641680 -36.13524652    1.276572
## 2010-05-01  0.32292725  -0.63981807    4.248439
## 2010-06-01  0.32570610   5.73545800    8.316034
## 2010-07-01  0.27625015  17.83088645   13.087901
## 2010-08-01  0.20242901  79.10616252   10.555496
## 2010-09-01  0.12400786   0.08143858    6.323092
## 2010-10-01 -0.01984809  -3.52313297    1.294959
## 2010-11-01 -0.15616924  32.45214310   -4.137446
## 2010-12-01 -0.22892518 -33.65242845  -11.465579
## 2011-01-01 -0.16134633 -39.97715238   -7.697983
## attr(,"name")
## [1] zoo_sweden
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-6-1.png" alt="" width="672" />
Then, the pre-processing function of our library could be something like this:



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

The function could be more concise, but it is written to facilitate line-by-line debugging instead. I have also added minimal roxygen documentation. Future me usually appreciates this kind of extra effort. Any kind of effort actually.

This function should check that `x` is really a zoo object, and any other condition that would make it fail, but to keep code simple, in this tutorial we won't do any error catching.

We can use a mock-up time series with an ascending trend to really test the effect of our detrending function.


``` r
x <- zoo::zoo(0:10)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-9-1.png" alt="" width="672" />

If we apply `ts_preprocessing()` to this time series, the result shows a horizontal line, which is a perfect linear detrending. Now we can be sure our implementation works!


``` r
x_detrended <- ts_preprocessing(x = x)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-11-1.png" alt="" width="672" />




### Z-score Normalization

Normalization (also named *standardization*) consists of two operations: 

  - **Centering**: performed by subtracting the column mean to each case, resulting in a column mean equal to zero. 
  - **Scaling**: divides each case by the standard deviation of the column, resulting in a standard deviation equal to one.

The R base function `scale()` implements z-score normalization, so there's not much we have to do from scratch here. Also, when the library `zoo` is loaded, the method `zoo:::scale.zoo` (`:::` denotes methods and functions that are not exported by a package) allows `scale()` to work seamlessly with zoo objects.


``` r
scale(
  x = zoo_germany,
  center = TRUE,
  scale = TRUE
  )
```

```
##                   evi    rainfall temperature
## 2010-01-01 -2.1072111 -0.77369778 -1.37937171
## 2010-02-01 -0.5757809 -0.44531242 -0.97212864
## 2010-03-01 -0.4963522 -0.87526026 -0.40724308
## 2010-04-01 -0.1500661 -1.49817681  0.26273747
## 2010-05-01  1.2590783  1.21354145  0.39410620
## 2010-06-01  1.3482213 -0.06614582  1.20859236
## 2010-07-01  0.9973637  0.53307282  1.61583543
## 2010-08-01  0.9990780  1.72812469  1.19545548
## 2010-09-01  0.3750773 -0.07630207  0.66998055
## 2010-10-01  0.2670772 -0.94973941  0.05254749
## 2010-11-01 -0.3477806  0.33671869 -0.38096933
## 2010-12-01 -0.7843525  1.44713515 -1.36623484
## 2011-01-01 -0.7843525 -0.57395823 -0.89330739
## attr(,"name")
## [1] zoo_germany
## attr(,"scaled:center")
##         evi    rainfall temperature 
##   0.4376615  60.8538462   8.8000000 
## attr(,"scaled:scale")
##         evi    rainfall temperature 
##   0.1749998  29.5384669   7.6121613
```

Thanks to this seamless integration with `zoo` time series, z-score normalization can be easily added to our pre-processing function!



``` r
#' Linear Detrending and Normalization
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_preprocessing <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  z <- scale(y) #new
  z
}
```

We can now test `ts_preprocessing()` and move forward with our implementation.


``` r
ts_preprocessing(x = zoo_germany)
```

```
##                    evi     rainfall temperature
## 2010-01-01 -1.91389650 -0.254652344 -1.35356479
## 2010-02-01 -0.40410400 -0.001606348 -0.95069824
## 2010-03-01 -0.35682407 -0.548358009 -0.38973731
## 2010-04-01 -0.04363355 -1.310450989  0.27590451
## 2010-05-01  1.34386644  1.489002490  0.40300011
## 2010-06-01  1.39742780  0.026066230  1.21316833
## 2010-07-01  1.00791041  0.571260913  1.61617795
## 2010-08-01  0.97319785  1.749131031  1.19130241
## 2010-09-01  0.30672100 -0.273757334  0.66131677
## 2010-10-01  0.16240893 -1.300041138  0.03950285
## 2010-11-01 -0.49483667 -0.024630977 -0.39851146
## 2010-12-01 -0.97089711  1.066065435 -1.38821075
## 2011-01-01 -1.00734053 -1.188028960 -0.91965038
## attr(,"name")
## [1] zoo_germany
## attr(,"scaled:center")
##          evi     rainfall  temperature 
## 2.135044e-18 8.113168e-16 5.465713e-16 
## attr(,"scaled:scale")
##         evi    rainfall temperature 
##   0.1733241  27.6809389   7.6110663
```

## Dynamic Time Warping Functions

This section describes the implementation of the DTW algorithm, which requires functions to compute a distance matrix, convert it to a cost matrix, find a least-cost path maximizing the alignment between the time series, and compute their dissimilarity.

### Distance Matrix

In DTW, a distance matrix represents the distances between all pairs of samples in two time series. Hence, each time series is represented in one axis of the matrix. But before getting there, we need a function to obtain the distance between arbitrary pairs of rows from two separate zoo objects.

#### Distance Function

Let's say we have two vectors, `x` with one row of `zoo_germany`, and `y` with one row of `zoo_sweden`. Then, the expression to compute the Euclidean distances between `x` and `y` becomes `sqrt(sum((x-y)^2))`. From there, implementing a distance function is kinda trivial.


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
distance_euclidean <- function(x, y){
  sqrt(sum((x - y)^2))
}
```

Notice that the function does not indicate the return explicitly. Since the function's body is a one-liner, one cannot be really worried about the function returning something unexpected. Also, implementing such a simple expression in a function might seem like too much, but it may facilitate the addition of new distance metrics to the library in the future. For example, we could create something like `distance_manhattan()` with the Manhattan distance, and later switch between one or another depending on the user's needs.

The code below tests the function by computing the euclidean distance between the row 1 from `zoo_sweden` and the row 2 from `zoo_germany`.


``` r
zoo_sweden[1, ]
```

```
##               evi rainfall temperature
## 2010-01-01 0.1259       32        -4.4
```

``` r
zoo_germany[2, ]
```

```
##               evi rainfall temperature
## 2010-02-01 0.3369     47.7         1.4
```

``` r
distance_euclidean(
  x = zoo_sweden[1, ],
  y = zoo_germany[2, ]
)
```

```
## [1] 0
```

Sorry, what? That doesn't seem right! 

For whatever reason, `zoo_sweden[1, ]` and `zoo_germany[2, ]` are not being interpreted as numeric vectors by `distance_euclidean()`. 

Let's try something different:


``` r
distance_euclidean(
  x = as.numeric(zoo_sweden[1, ]),
  y = as.numeric(zoo_germany[2, ])
)
```

```
## [1] 16.73841
```

Ok, that makes more sense! 

Then, we just have to move these `as.numeric()` commands inside `distance_euclidean()` to simplify the usage of the function:


``` r
#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
distance_euclidean <- function(x, y){
  x <- as.numeric(x) #new
  y <- as.numeric(y) #new
  z <- sqrt(sum((x - y)^2))
  z
}
```

The new function should have no issues returning the right distance between these rows now:


``` r
distance_euclidean(
  x = zoo_sweden[1, ],
  y = zoo_germany[2, ]
)
```

```
## [1] 16.73841
```

Now we can go compute the distance matrix.

#### Distance Matrix

To generate the distance matrix, the function `distance_euclidean()` must be applied to all pairs of rows in the two time series. 

A simple yet inefficient way to do this involves creating an empty matrix, and traversing it cell by cell to compute the euclidean distances between the corresponding pair of rows.


``` r
#empty distance matrix
m_dist <- matrix(
  data = NA, 
  nrow = nrow(zoo_germany), 
  ncol = nrow(zoo_sweden)
)

#iterate over rows
for(row in 1:nrow(zoo_germany)){
  
  #iterate over columns
  for(col in 1:nrow(zoo_sweden)){
    
    #distance between time series rows
    m_dist[row, col] <- distance_euclidean(
      x = zoo_germany[col, ],
      y = zoo_sweden[row, ]
    )
    
  }
}
```

This code generates a matrix with `zoo_germany` in the rows, from top to bottom, and `zoo_sweden` in the columns, from left to right. The first five rows and columns are shown below.


``` r
m_dist[1:5, 1:5]
```

```
##           [,1]      [,2]      [,3]      [,4]     [,5]
## [1,]  6.579761 16.738415 10.538528 21.639813 66.69942
## [2,] 17.634758  8.948271 22.285328 41.303861 43.61868
## [3,]  3.595693  8.909263  5.445835 23.955397 58.75852
## [4,] 19.723690 27.966469 14.757548  5.305437 76.55158
## [5,] 24.446000 14.584815 24.796103 42.806743 37.33875
```

This matrix can be plotted with the function `graphics::image()`, but please be aware that it rotates the distance matrix 90 degrees counter clock-wise, which can be pretty confusing at first. 

Remember this: **in the matrix plot, the x axis represents the matrix rows**.


``` r
graphics::image(
  x = seq_len(nrow(m_dist)),
  y = seq_len(ncol(m_dist)),
  z = m_dist,
  xlab = "zoo_germany",
  ylab = "zoo_sweden",
  main = "Euclidean Distance"
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-23-1.png" alt="" width="672" />

Darker values indicate larger distances between pairs of samples in each time series.

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
  
  for (row in 1:nrow(b)) {
    for (col in 1:nrow(a)) {
      m[row, col] <- distance_euclidean(
        x = a[col, ],
        y = b[row, ] 
      )
    }
  }
  
  m
  
}
```

Let's run a little test before moving forward!


``` r
m_dist <- distance_matrix(
  a = zoo_germany,
  b = zoo_sweden
)

m_dist[1:5, 1:5]
```

```
##           [,1]      [,2]      [,3]      [,4]     [,5]
## [1,]  6.579761 16.738415 10.538528 21.639813 66.69942
## [2,] 17.634758  8.948271 22.285328 41.303861 43.61868
## [3,]  3.595693  8.909263  5.445835 23.955397 58.75852
## [4,] 19.723690 27.966469 14.757548  5.305437 76.55158
## [5,] 24.446000 14.584815 24.796103 42.806743 37.33875
```

We are good to go! The next function will transform this distance matrix into a *cost matrix*.




### Cost Matrix

Now we are getting into the important parts of the DTW algorithm! 

A cost matrix is like a valley's landscape, with hills in regions where the time series are different, and ravines where they are more similar. Such landscape is built by accumulating the values of the distance matrix cell by cell, from `[1, 1]` at the bottom of the valley (upper left corner of the matrix, but lower left in the plot), to `[m, n]` at the top (lower right corner of the matrix, upper right in the plot).

Let's see how that works!

First, we use the dimensions of the distance matrix to create an empty cost matrix.


``` r
m_cost <- matrix(
  data = NA, 
  nrow = nrow(m_dist), 
  ncol = ncol(m_dist)
  )
```

Second, to initialize the cost matrix we accumulate the values of the first row and column of the distance matrix using `cumsum()`. This step is very important for the second part of the algorithm, as it provides the starting values of the cost matrix.


``` r
m_cost[1, ] <- cumsum(m_dist[1, ])
m_cost[, 1] <- cumsum(m_dist[, 1])
```


<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-29-1.png" alt="" width="672" />

Now, before going into the third step, let's focus for a moment on the first cell of the cost matrix we need to fill, with coordinates `[2, 2]` and value `NA`.


``` r
m_cost[1:2, 1:2]
```

```
##           [,1]     [,2]
## [1,]  6.579761 23.31818
## [2,] 24.214519       NA
```

The new value of this cell results from the addition of:

  - Its value in the distance matrix `m_dist` (8.95).
  - The minimum accumulated distance of its neighbors, which are:
      - Upper neighbor with coordinates `[1, 2]`.
      - Left neighbor with coordinates `[2, 1]`. 

The general expression to find the value of the empty cell is shown below. It uses `min()` to get the value of the *smallest* neighbor, and then adds it to the vaue of the target cell in the distance matrix.


``` r
m_cost[2, 2] <- min(
  m_cost[1, 2], 
  m_cost[2, 1]
  ) + m_dist[2, 2]

m_cost[1:2, 1:2]
```

```
##           [,1]     [,2]
## [1,]  6.579761 23.31818
## [2,] 24.214519 32.26645
```

But there are many cells to fill yet!

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-32-1.png" alt="" width="672" />

The expression we used to fill the cell `m_cost[2, 2]` can be generalized to fill all remaining empty cells. We just have to wrap it in a nested loop that for each new empty cell identifies the smallest neighbor in the x and y axies, and adds its cumulative cost to the distance of the new cell.


``` r
#iterate over rows of the cost matrix
for(row in 2:nrow(m_dist)){
  
  #iterate over columns of the cost matrix
  for(col in 2:ncol(m_dist)){
    
    #get cost of neighbor with minimum accumulated cost
    min_cost <- min(
      m_cost[row - 1, col], 
      m_cost[row, col - 1]
      )
    
    #add it to the distance of the target cell
    new_value <- min_cost + m_dist[row, col]
    
    #fill the empty cell with the new value
    m_cost[row, col] <- new_value
    
  }
}
```

Running the code above results in a nicely filled cost matrix!

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-34-1.png" alt="" width="672" />

Now that we have all the pieces figured out, we can define our new function to compute the cost matrix. Notice that the code within the nested loops is slightly more concise than shown before.


``` r
#' Cost Matrix from Distance Matrix
#' @param distance_matrix (required, matrix) distance matrix.
#' @return matrix
cost_matrix <- function(distance_matrix){
  
  m <- matrix(
    data = NA, 
    nrow = nrow(distance_matrix), 
    ncol = ncol(distance_matrix)
  )
  
  m[1, ] <- cumsum(distance_matrix[1, ])
  m[, 1] <- cumsum(distance_matrix[, 1])
  
  for(row in 2:nrow(distance_matrix)){
    for(col in 2:ncol(distance_matrix)){
      
      m[row, col] <- min(
        m[row - 1, col], 
        m[row, col - 1]
      ) + distance_matrix[row, col]
      
    }
  }
  
  m
  
}
```

Let's test our new function using `m_dist` as input:


``` r
m_cost <- cost_matrix(distance_matrix = m_dist)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-37-1.png" alt="" width="672" />

So far so good! We can now dive into the generation of the least-cost path.



### Least-Cost Path

If we describe the cost matrix as a valley with its hills and ravines, then the least-cost path is the river following the line of maximum slope all the way to the bottom of the valley. Following the analogy, the least-cost path starts in the terminal cell of the cost matrix (`[13, 13]`), and ends in the first cell.

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

This is the first step of the least cost path. From here, there are two candidate steps:

  - *one column left*: `[row, col - 1]`.
  - *one row up*: `[row - 1, col]`.
  
But before moving forward, notice that if we apply these steps indefinitely in our cost matrix, at some point a move up `row - 1` or left `col - 1` will go out of bounds and produce an error. That's why it's safer to define the next move as...

  - *one column left*: `[row, max(col - 1, 1)]`.
  - *one row up*: `[max(row - 1, 1), col]`


...which confines all steps within the first row and column of the cost matrix. 

With that out of the way, now we have to select the move towards a cell with a lower cost. There are many ways to accomplish this task! Let's look one of them.

First, we define the candidate moves using the first row of the least-cost path as reference, and generate a list with the coordinates of the candidate steps.


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

Second, we extract the values of the cost matrix for the coordinates of these two steps.


``` r
costs <- list(
  left = m_cost[steps$left[1], steps$left[2]],
  up = m_cost[steps$up[1], steps$up[2]]
)

costs
```

```
## $left
## [1] 495.481
## 
## $up
## [1] 457.7403
```

Finally, we choose the candidate step with the lower cost using `which.min()`, a function that returns the index of the smallest value in a vector or list. Notice that we use `[1]` in `which.min(costs)[1]` to resolve potential ties that may be returned by `which.min()` if the two costs are the same (unlikely, but possible).


``` r
steps[[which.min(costs)[1]]]
```

```
## [1] 12 13
```

Combining these pieces we can now build a function named `least_cost_step()` that takes the cost matrix and the last row of a least-cost path, and returns a new row with the coordinates of the next step.
  

``` r
#' Identify Next Step of Least-Cost Path
#' @param cost_matrix (required, matrix) cost matrix.
#' @param last_step (required, data frame) one row data frame with columns "row" and "col" representing the last step of a least-cost path.
#' @return one row data frame, new step in least-cost path
least_cost_step <- function(cost_matrix, last_step){
  
  #define candidate steps
  steps <- list(
    left = c(last_step$row, max(last_step$col - 1, 1)),
    up = c(max(last_step$row - 1, 1), last_step$col)
  )
  
  #obtain their costs
  costs <- list(
    left = cost_matrix[steps$left[1], steps$left[2]],
    up = cost_matrix[steps$up[1], steps$up[2]]
  )
  
  #select the one with a smaller cost
  coords <- steps[[which.min(costs)[1]]]
  
  #rewrite input with new values
  last_step[,] <- c(coords[1], coords[2])
  
  last_step
  
}
```

Notice that the function overwrites the input data frame `step` with the new values to avoid generating a new data frame, making the code a bit more concise. 

Let's check how it works:


``` r
least_cost_step(
  cost_matrix = m_cost, 
  last_step = path
  )
```

```
##   row col
## 1  12  13
```

Good, it returned the move to the upper neighbor! 

Now, if you think about the function for a bit, you'll see that it takes a step in the least-cost path, and returns a new one. From there, it seems we can feed it its own result again and again until it runs out of new steps to find.

We can do that in a concise way using a `repeat{}` loop. Notice that it will keep running until both coordinates in the last row of the path are equal to 1.


``` r
repeat{
  
  #find next step
  new.step <- least_cost_step(
    cost_matrix = m_cost, 
    last_step = tail(path, n = 1)
    )
  
  #join the new step with path
  path <- rbind(
    path, new.step,
    make.row.names = FALSE
    )
  
  #stop when step coordinates are 1, 1
  if(all(tail(path, n = 1) == 1)){break}
  
}

path
```

```
##    row col
## 1   13  13
## 2   12  13
## 3   12  12
## 4   11  12
## 5   10  12
## 6   10  11
## 7    9  11
## 8    9  10
## 9    9   9
## 10   9   8
## 11   8   8
## 12   7   8
## 13   7   7
## 14   6   7
## 15   6   6
## 16   5   6
## 17   5   5
## 18   5   4
## 19   4   4
## 20   4   3
## 21   3   3
## 22   3   2
## 23   3   1
## 24   2   1
## 25   1   1
```
  
The resulting least-cost path can be plotted on top of the cost matrix. Please, remember that the data is not pre-processed, and the plot below does not represent the real alignment (yet) between our target time series.


``` r
graphics::image(
    x = seq_len(nrow(m_cost)),
    y = seq_len(ncol(m_cost)),
    z = m_cost,
    xlab = "zoo_germany",
    ylab = "zoo_sweden",
    main = "Cost Matrix and Least-Cost Path"
    )

graphics::lines(
  x = path$row, 
  y = path$col,
  lwd = 2
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-46-1.png" alt="" width="672" />

At this point we have all the pieces required to write the function `least_cost_path()`. Notice that the `repeat{}` statement is slightly more concise than before, as `least_cost_step()` is directly wrapped within `rbind()`. However, using `rbind()` in a loop to add rows to a data frame is not a computationally efficient operation, but it was used here anyway because it makes the code more concise.


``` r
#' Least-Cost Path from Cost Matrix
#' @param cost_matrix (required, matrix) cost matrix.
#' @return data frame with least-cost path coordinates
least_cost_path <- function(cost_matrix){
  
  #first step of the least cost path
  path <- data.frame(
    row = nrow(cost_matrix),
    col = ncol(cost_matrix)
  )
  
  #iterate until path is completed
  repeat{
    
    #merge path with result of least_cost_step()
    path <- rbind(
      path, 
      #find next step
      least_cost_step(
        cost_matrix = cost_matrix, 
        last_step = tail(path, n = 1)
      ),
      make.row.names = FALSE
    )
    
    #stop when coordinates are 1, 1
    if(all(tail(path, n = 1) == 1)){break}
    
  }
  
  path
  
}
```

We can give it a go now to see that it works as expected.


``` r
least_cost_path(cost_matrix = m_cost)
```

```
##    row col
## 1   13  13
## 2   12  13
## 3   12  12
## 4   11  12
## 5   10  12
## 6   10  11
## 7    9  11
## 8    9  10
## 9    9   9
## 10   9   8
## 11   8   8
## 12   7   8
## 13   7   7
## 14   6   7
## 15   6   6
## 16   5   6
## 17   5   5
## 18   5   4
## 19   4   4
## 20   4   3
## 21   3   3
## 22   3   2
## 23   3   1
## 24   2   1
## 25   1   1
```

Nice, it worked, and now we have a nice least-cost path.

But before continuing, there is just a little detail to notice about the least-cost path. Every time the same row index (such as `9`) is linked to different column indices (`8` to `11`), it means that the samples of the time series identified by these column indices are having their time *compressed* (or *warped*) to the time of the row index. Hence, according to the least-cost path, the samples `8` to `11` of `zoo_sweden` would be aligned in time with the sample `9` of `zoo_germany`. 

Now it's time to use the least-cost path to quantify the similarity between the time series.




### Dissimilarity Metric

The objective of dynamic time warping is to compute a metric of *dissimilarity* (or *similarity*, it just depends on the side from where you are looking at the issue) between time series. This operation requires two steps:

  - Obtain the accumulated distance of the least cost path.
  - Normalize the sum of distances by some number to help make results comparable across pairs of time series of different lengths.

First, the method designed to build the cost matrix accumulates the distance of the least-cost path in the terminal cell, so we just have to extract it.


``` r
distance <- m_cost[nrow(m_cost), ncol(m_cost)]
distance
```

```
## [1] 464.0019
```

Second, we need to find a number to normalize this distance value to make it comparable across different time series. There are several options, such as dividing `distance` by the sum of lengths of the two time series, or by the length of the least-cost path (`nrow(path)`). 


``` r
distance/sum(dim(m_cost))
```

```
## [1] 17.84623
```

``` r
distance/nrow(path)
```

```
## [1] 18.56008
```
Another elegant normalization option requires computing the sum of distances between consecutive samples on each time series. This operation, named *auto-sum*, requires applying `distance_euclidean()` between the samples 1 and 2 of the given time series, then between the samples 2 and the 3, and so on until all consecutive sample pairs are processed, to finally sum all computed distances.

To apply this operation to a time series we iterate between pairs of consecutive samples and save their distance in a vector (named `autodistance` in the code below). Once the loop is done, then the auto-sum of the time series is the sum of this vector. 

For example, for `zoo_germany` we would have:


``` r
#vector to store auto-distances
autodistance <- vector(
  mode = "numeric", 
  length = nrow(zoo_germany) - 1
  )

#compute of row-to-row distance
for (row in 2:nrow(zoo_germany)) {
  autodistance[row - 1] <- distance_euclidean(
    x = zoo_germany[row, ],
    y = zoo_germany[row - 1, ]
  )
}

#compute autosum
sum(autodistance)
```

```
## [1] 425.7877
```

Since we'll need to apply this operation to many time series, it's better to formalize this logic as a function:


``` r
#' Time Series Autosum
#' @param x (required, zoo object) time series
#' @return numeric
auto_sum <- function(x){
  
  autodistance <- vector(
    mode = "numeric", 
    length = nrow(x) - 1
  )
  
  for (row in 2:nrow(x)) {
    autodistance[row - 1] <- distance_euclidean(
      x = x[row, ],
      y = x[row - 1, ]
    )
  }
  
  sum(autodistance)
  
}
```

We can now apply it to our two time series:


``` r
zoo_germany_autosum <- auto_sum(
  x = zoo_germany
)

zoo_germany_autosum
```

```
## [1] 425.7877
```

``` r
zoo_sweden_autosum <- auto_sum(
  x = zoo_sweden
)

zoo_sweden_autosum
```

```
## [1] 379.9118
```

Once we have the auto-sum of both time series, we just have to add them together to obtain our normalization value.


``` r
normalizer <- zoo_germany_autosum + zoo_sweden_autosum
normalizer
```

```
## [1] 805.6995
```

Now that we obtained `distance` from the cost matrix and the `normalizer` from the auto-sum of the two time series, we can compute our dissimilarity score, which follows the expression below:


``` r
((2 * distance) / normalizer) - 1
```

```
## [1] 0.1517989
```
Why this particular formula? Because it returns zero when comparing a time series with itself! 

When the two time series are the same, `2 * distance` equals `normalizer` because DTW and auto-sum are equivalent (sample-to-sample distances!), and dividing them returns one. We then subtract one to it, and get zero, which represents a perfect similarity score. 

The same affect cannot be achieved when using other normalization values, such as the sum of lengths of the time series, or the length of the least cost path.

We can integrate these pieces into the function `dissimilarity_score()`.


``` r
#' Similarity Metric from Least Cost Path and Cost Matrix
#' @param a (required, zoo object) time series.
#' @param b (required, zoo object) time series with same columns as `x`
#' @param cost_path (required, data frame) least cost path with the columns "row" and "col".
#' @return numeric, similarity metric
dissimilarity_score <- function(a, b, cost_matrix){
  
  #distance of the least cost path
  distance <- cost_matrix[nrow(cost_matrix), ncol(cost_matrix)]
  
  #compute normalization factor from autosum
  autosum_a <- auto_sum(x = a)
    
  autosum_b <- auto_sum(x = b)
  
  normalizer <- autosum_a + autosum_b
  
  #compute dissimilarity
  psi <- ((2 * distance) / normalizer) - 1
  
  psi
  
}
```

We can give it a test run now:


``` r
dissimilarity_score(
  a = zoo_germany,
  b = zoo_sweden,
  cost_matrix = m_cost
)
```

```
## [1] 0.1517989
```

With the `dissimilarity_score()` function ready, it is time to go write our main function!




## Main Function

To recapitulate before moving forward, we have the following functions:

  - `ts_preprocessing()` applies linear detrending and z-score normalization to a time series.
  - `distance_matrix()` and `distance_euclidean()` work together to compute a distance matrix.
  - `cost_matrix()` transforms the distance matrix into a cost matrix.
  - `least_cost_path()` applies `least_cost_step()` recursively to build a least-cost path.
  - `dissimilarity_score()`, which calls `auto_sum()` and quantifies time series dissimilarity.
  
We can wrap together all these functions into a new one with the unimaginative name `dynamic_time_warping()`.


``` r
#' Similarity Between Time Series
#' @param a (required, zoo object) time series.
#' @param b (required, zoo object) time series with same columns as `x`
#' @param plot (optional, logical) if `TRUE`, a dynamic time warping plot is produced.
#' @return psi score
dynamic_time_warping <- function(a, b, plot = FALSE){
  
  #linear detrending and z-score normalization
  a_ <- ts_preprocessing(x = a)
  b_ <- ts_preprocessing(x = b)
  
  #distance matrix
  m_dist <- distance_matrix(
    a = a_,
    b = b_
  )
  
  #cost matrix
  m_cost <- cost_matrix(
    distance_matrix = m_dist
  )
  
  #least-cost path
  cost_path <- least_cost_path(
    cost_matrix = m_cost
  )
  
  #similarity metric
  score <- dissimilarity_score(
    a = a_,
    b = b_,
    cost_matrix = m_cost
  )
  
  #plot
  if(plot == TRUE){
    
    graphics::image(
      x = seq_len(nrow(m_cost)),
      y = seq_len(ncol(m_cost)),
      z = m_cost,
      xlab = "a",
      ylab = "b",
      main = paste0("Similarity score = ", round(score, 3))
    )
    
    graphics::lines(
      x = cost_path$row, 
      y = cost_path$col,
      lwd = 2
    )
    
  }
  
  score
  
}
```

Before I said that one advantage of the presented dissimilarity formula is that it returns 0 when comparing a time series with itself. Let's see if that's true by comparing `zoo_germany` with itself:


``` r
dynamic_time_warping(
  a = zoo_germany,
  b = zoo_germany
)
```

```
## [1] 0
```

That's good, right? Perfect similarity happens at 0, which is a lovely number to start with. If we now compare `zoo_germany` and `zoo_sweden`, we should expect a larger number:


``` r
dynamic_time_warping(
  a = zoo_germany,
  b = zoo_sweden
)
```

```
## [1] 0.2366642
```

And now, when comparing `zoo_sweden` with `zoo_spain` we should expect an even higher dissimilarity score, given that they are quite far apart. As a bonus, we let the function plot their alignment.


``` r
dynamic_time_warping(
  a = zoo_sweden,
  b = zoo_spain,
  plot = TRUE
)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-63-1.png" alt="" width="672" />

```
## [1] 0.509285
```

Well, that was freaking long, but these are such nice results, aren't they? I hope it was worth it! One minute more, and we are done.

## Library Source

Once we have all our DTW functions written and tested, the easiest way to make them usable without any extra hassle is to write them to a source file. Having them all in a single file allows loading them at once via the `source()` command. 

For example, if our library file is [`dtw.R`](https://www.dropbox.com/scl/fi/z2n9hnenxwuxwol5i0zcn/dtw.R?rlkey=bhsyew12r1glnqihtnocxwri6&dl=1), running `source("dtw.R")` will load all functions into your R environment and they will be readily available for your DTW analysis.

## Closing Thoughts

I hope you found this tutorial useful in one way or another. Writing a methodological library from scratch is hard work. There are many moving parts to consider, many concepts that need to be mapped and then translated into code, that making mistakes becomes exceedingly easy. Never worry about that and take your time until things start clicking. 

But above everything, enjoy the learning journey!

## Coming Next

In my TODO list there is a post focused on identifying computational bottlenecks in the DTW library we just wrote, and optimize the parts worth optimizing. There's no timeline yet though, so stay tuned!

Blas

