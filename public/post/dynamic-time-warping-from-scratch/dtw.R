#' Linear Detrending and Normalization
#' @param x (required, zoo object) time series to detrend.
#' @return zoo object
ts_preprocessing <- function(x){
  m <- stats::lm(formula = x ~ stats::time(x))
  y <- stats::residuals(object = m)
  z <- scale(y)
  z
}

#' Euclidean Distance
#' @param x (required, numeric) row of a zoo object.  
#' @param y (required, numeric) row of a zoo object.
#' @return numeric
distance_euclidean <- function(x, y){
  x <- as.numeric(x)
  y <- as.numeric(y)
  z <- sqrt(sum((x - y)^2))
  z
}

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


#' Identify Next Step of Least-Cost Path
#' @param cost_matrix (required, matrix) cost matrix.
#' @param last_step (required, data frame) one row data frame with columns "row" and "col" representing the last step of a least-cost path.
#' @return one row data frame, new step in least-cost path
least_cost_step <- function(cost_matrix, last_step){
  
  steps <- list(
    left = c(last_step$row, max(last_step$col - 1, 1)),
    up = c(max(last_step$row - 1, 1), last_step$col)
  )
  
  costs <- list(
    left = cost_matrix[steps$left[1], steps$left[2]],
    up = cost_matrix[steps$up[1], steps$up[2]]
  )
  
  coords <- steps[[which.min(costs)[1]]]
  
  #rewrite input with new values
  last_step[,] <- c(coords[1], coords[2])
  
  last_step
  
}

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