f <- function(n = 1e7){
     stats::cor.test(
       x = stats::rnorm(n = n), 
       y = stats::runif(n = n)
     )
   }
