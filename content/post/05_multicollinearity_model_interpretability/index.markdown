---
title: "Multicollinearity Hinders Model Interpretability"
author: ''
date: '2023-10-29'
slug: multicollinearity-model-interpretability
output:
  blogdown::html_page:
    toc: true
categories: []
tags:
- Quantitative Methods
- Multicollinearity
- Data Science
- Linear Modelling
subtitle: ''
summary: 'In this post, I delve into the intricacies of model interpretation under the influence of multicollinearity, and use R and a toy data set to demonstrate how this phenomenon impacts both linear and machine learning models.'
authors: [admin]
lastmod: '2023-10-29T08:14:23+02:00'
featured: no
image:
  caption: "Adapted from XKCD: https://xkcd.com/2347/"
  focal_point: Smart
  margin: auto
projects: []
toc: true
---

{{% alert note %}}
This post is written for beginner to intermediate R users wishing to learn what multicollinearity is and how it can turn model interpretation into a challenge. 
{{% /alert %}}

## Summary

In this post, I delve into the intricacies of model interpretation under the influence of multicollinearity, and use R and a toy data set to demonstrate how this phenomenon impacts both linear and machine learning models:

  + The section *Multicollinearity Explained* explains the origin of the word and the nature of the problem. 
  + The section *Model Interpretation Challenges* describes how to create the toy data set, and applies it to *Linear Models* and *Random Forest* to explain how multicollinearity can make model interpretation a challenge.
  + The *Appendix* shows extra examples of linear and machine learning models affected by multicollinearity.
  
I hope you'll enjoy it!

## R packages

This tutorial requires the newly released R package [`collinear`](https://blasbenito.github.io/collinear/), and a few more listed below. The optional ones are used only in the *Appendix* at the end of the post.


```r
#required
install.packages("collinear")
install.packages("ranger")
install.packages("dplyr")

#optional
install.packages("nlme")
install.packages("glmnet")
install.packages("xgboost")
```

## Multicollinearity Explained

This cute word comes from the amalgamation of these three Latin terms:
  + *multus*: adjective meaning *many* or *multiple*.
  + *con*: preposition often converted to *co-* (as in *co-worker*) meaning *together* or *mutually*.
  + *linealis* (later converted to *linearis*): from *linea* (line), adjective meaning "resembling a line" or "belonging to a line", among others. 
  
After looking at these serious words, we can come up with a (VERY) liberal translation: "several things together in the same line". From here, we just have to replace the word "things" with "predictors" (or "features", or "independent variables", whatever rocks your boat) to build an intuition of the whole meaning of the word in the context of statistical and machine learning modeling.

If I lost you there, we can move forward with this idea instead: **multicollinearity happens when there are redundant predictors in a modeling dataset**. A predictor can be redundant because it shows a high pairwise correlation with other predictors, or because it is a linear combination of other predictors. For example, in a data frame with the columns `a`, `b`, and `c`, if the correlation between `a` and `b` is high, we can say that `a` and `b` are mutually redundant and there is multicollinearity. But also, if `c` is the result of a linear operation between `a` and `b`, like `c <- a + b`, or `c <- a * 1 + b * 0.5`, then we can also say that there is multicollinearity between `c`, `a`, and `b`.

Multicollinearity is a fact of life that lurks in most data sets. For example, in climate data, variables like temperature, humidity and air pressure are closely intertwined, leading to multicollinearity. That's the case as well in medical research, where parameters like blood pressure, heart rate, and body mass index frequently display common patterns. Economic analysis is another good example, as variables such as Gross Domestic Product (GDP), unemployment rate, and consumer spending often exhibit multicollinearity.


## Model Interpretation Challenges

Multicollinearity isn't inherently problematic, but it can be a real buzz kill when the goal is interpreting predictor importance in explanatory models. In the presence of highly correlated predictors, most modelling methods, from the veteran linear models to the fancy gradient boosting, attribute a large part of the importance to only one of the predictors and not the others. In such cases, neglecting multicollinearity will certainly lead to underestimate the relevance of certain predictors.

Let me go ahead and develop a toy data set to showcase this issue. But let's load the required libraries first.


```r
#load the collinear package and its example data
library(collinear)
data(toy)

#other required libraries
library(ranger)
library(dplyr)
```

In the `toy` data frame shipped with [`collinear`](https://blasbenito.github.io/collinear/) contains these columns:
  + `a` and `b`: uncorrelated predictors
  + `y`: response variable resulting from a linear model where `a` has a slope of 0.75, `b` has a slope of 0.25, plus a bit of white noise generated with `runif()`.
  + `c`: a predictor highly correlated with `a`.
  + `d`: a predictor resulting from a linear combination of `a` and `b`.

The Pearson correlation between all pairs of these predictors is shown below.


```r
collinear::cor_df(
  df = toy,
  predictors = c("a", "b", "c", "d")
)
```

```
##   x y correlation  metric
## 1 a c  0.96154984 Pearson
## 2 b d  0.63903887 Pearson
## 3 a d  0.63575882 Pearson
## 4 c d  0.61480312 Pearson
## 5 a b -0.04740881 Pearson
## 6 b c -0.04218308 Pearson
```

At this point, we have are two groups of predictors useful to understand how multicollinearity muddles model interpretation:

  + Non-collinear predictors: `a` and `b`.
  + Collinear predictors: `a`, `b`, `c`, and `d`.

In the next two sections and the *Appendix*, I show how and why model interpretation becomes challenging when multicollinearity is high. Let's start with linear models.

### Linear Models

The code below fits *multiple linear regression models* for both groups of predictors.


```r
#non-collinear predictors
lm_ab <- lm(
  formula = y ~ a + b,
  data = toy
  )

#collinear predictors
lm_abcd <- lm(
  formula = y ~ a + b + c + d,
  data = toy
  )
```

I would like you to pay attention to the estimates of the predictors `a` and `b` for both models. The estimates are the slopes in the linear model, a direct indication of the effect of a predictor over the response.


```r
coefficients(lm_ab)[2:3] |> 
  round(4)
```

```
##      a      b 
## 0.7477 0.2616
```


```r
coefficients(lm_abcd)[2:5] |> 
  round(4)
```

```
##      a      b      c      d 
## 0.7184 0.2596 0.0273 0.0039
```

On one hand, the model with no multicollinearity (`lm_ab`) achieved a pretty good solution for the coefficients of `a` and `b`. Remember that we created `y` as `a * 0.75 + b * 0.25` plus some noise, and that's exactly what the model is telling us here, so the interpretation is pretty straightforward.

On the other hand, the model with multicollinearity (`lm_abcd`) did well with `b`, but there are a few things in there that make the interpretation harder.

  + The coefficient of `a` (0.7165) is slightly smaller than the true one (0.75), which could lead us to downplay its relationship with `y` by a tiny bit. This is kinda OK though, as long as one is not using the model's results to build nukes in the basement.
  + The coefficient of `c` is so small that it could led us to believe that this predictor not important at all to explain `y`. But we know that `a` and `c` are almost identical copies, so model interpretation here is being definitely muddled by multicollinearity.
  + The coefficient of `d` is tiny. Since `d` results from the sum of `a` and `b`, we could expect this predictor to be important in explaining `y`, but it got the shorter end of the stick in this case.
  
It is not that the model it's wrong though. This behavior of the linear model results from the *QR decomposition* (also *QR factorization*) applied by functions like `lm()`, `glm()`, `glmnet::glmnet()`, and `nlme::gls()` to improve numerical stability and computational efficiency, and to... address multicollinearity in the model predictors.

The QR decomposition transforms the original predictors into a set of orthogonal predictors with no multicollinearity. This is the *Q matrix*, created in a fashion that resembles the way in which a Principal Components Analysis generates uncorrelated components from a set of correlated variables. 

The code below applies QR decomposition to our multicollinear predictors, extracts the Q matrix, and shows the correlation between the new versions of `a`, `b`, `c`, and `d`.


```r
#predictors names
predictors <- c("a", "b", "c", "d")

#QR decomposition of predictors
toy.qr <- qr(toy[, predictors])

#extract Q matrix
toy.q <- as.data.frame(qr.Q(toy.qr))
colnames(toy.q) <- predictors

#correlation between transformed predictors
collinear::cor_df(df = toy.q)
```

```
##   x y   correlation  metric
## 1 c d  4.823037e-04 Pearson
## 2 b c -5.439847e-17 Pearson
## 3 b d  3.894252e-17 Pearson
## 4 a d  3.836795e-17 Pearson
## 5 a c -3.788868e-17 Pearson
## 6 a b -1.100264e-17 Pearson
```
The new set of predictors we are left with after the QR decomposition have exactly zero correlation! And now they are not our original predictors anymore, and have a different interpretation:

  + `a` is now "the part of `a` not in `b`, `c`, and `d`".
  + `b` is now "the part of `b` not in `a`, `c`, and `d`".
  + ...and so on...

The result of the QR decomposition can be plugged into the `solve()` function along with the response vector to estimate the coefficients of the linear model.


```r
solve(a = toy.qr, b = toy$y) |> 
  round(4)
```

```
##      a      b      c      d 
## 0.7189 0.2595 0.0268 0.0040
```
These are almost exactly the ones we got for our model with multicollinearity. In the end, the coefficients resulting from a linear model are not those of the original predictors, but the ones of their uncorrelated versions generated by the QR decomposition. 

But this is not the only issue of model interpretability under multicollinearity. Let's take a look at the standard errors of the estimates. These are a measure of the coefficient estimation uncertainty, and are used to compute the p-values of the estimates. As such, they are directly linked with the "statistical significance" (whatever that means) of the predictors within the model.

The code below shows the standard errors of the model without and with multicollinearity.


```r
summary(lm_ab)$coefficients[, "Std. Error"][2:3] |> 
  round(4)
```

```
##      a      b 
## 0.0066 0.0066
```

```r
summary(lm_abcd)$coefficients[, "Std. Error"][2:5] |> 
  round(4)
```

```
##      a      b      c      d 
## 0.0267 0.0134 0.0232 0.0230
```
These standard errors of the model with multicollinearity are an order of magnitude higher than the ones of the model without multicollinearity.

Since our toy dataset is relatively large (2000 cases) and the relationship between the response and a few of the predictors pretty robust, there are no real issues arising, as these differences in estimation precision are not enough to change the p-values of the estimates. However, in a small data set with high multicollinearity and a weaker relationship between the response and the predictors, standard errors of the estimate become wide, which increases p-values and reduces "significance". Such a situation might lead us to believe that a predictor does not explain the response, when in fact it does. And this, again, is a model interpretability issue caused by multicollinearity.

At the end of this post there is an appendix with code examples of other types of linear models that use QR decomposition and become challenging to interpret in the presence of multicollinearity. Play with them as you please!

Now, let's take a look at how multicollinearity can also mess up the interpretation of a commonly used machine learning algorithm.

### Random Forest

It is not uncommon to hear something like "random forest is insensitive to multicollinearity". Actually, I cannot confirm nor deny that I have said that before. Anyway, it is kind of true if one is focused on prediction-only problems. However, when the aim is interpreting predictor importance scores, then one has to be mindful about multicollinearity as well. 

Let's see an example. The code below fits two random forest models with our two sets of predictors.


```r
#non-collinear predictors
rf_ab <- ranger::ranger(
  formula = y ~ a + b,
  data = toy,
  importance = "permutation",
  seed = 1 #for reproducibility
)

#collinear predictors
rf_abcd <- ranger::ranger(
  formula = y ~ a + b + c + d,
  data = toy,
  importance = "permutation",
  seed = 1
)
```

Let's take a look at the prediction error the two models on the out-of-bag data. While building each regression tree, Random Forest leaves a random subset of the data out. Then, each case gets a prediction from all trees that had it in the out-of-bag data, and the prediction error is averaged across all cases to get the numbers below.


```r
rf_ab$prediction.error
```

```
## [1] 0.1026779
```

```r
rf_abcd$prediction.error
```

```
## [1] 0.1035678
```

According to these numbers, these two models are basically equivalent in their ability to predict our response `y`.

But now, you noticed that I set the argument `importance` to "permutation". Permutation importance quantifies how the out-of-bag error increases when a predictor is permuted across all trees where the predictor is used. It is pretty robust importance metric that bears no resemblance whatsoever with the coefficients of a linear model. Think of it as a very different way to answer the question "what variables are important in this model?". 

The permutation importance scores of the two random forest models are show below. 


```r
rf_ab$variable.importance |> round(4)
```

```
##      a      b 
## 1.0702 0.1322
```

```r
rf_abcd$variable.importance |> round(4)
```

```
##      a      b      c      d 
## 0.5019 0.0561 0.1662 0.0815
```

There is one interesting detail here. The predictor `a` has a permutation error three times higher than `c` in the second model, even though we could expect them to be similar due to their very high correlation. There are two reasons for this mismatch:

  + Random Forest is much more sensitive to the white noise in `c` than linear models, especially in the deep parts of the regression trees, due to local (within-split data) decoupling with the response `y`. In consequence, it does not get selected as often as `a` in these deeper areas of the trees, and has less overall importance. 
  + The predictor `c` competes with `d`, that has around 50% of the information in `c` (and `a`). If we remove `d` from the model, then the permutation importance of `c` doubles up. Then, with `d` in the model, we underestimate the real importance of `c` due to multicollinearity alone.
  

```r
rf_abc <- ranger::ranger(
  formula = y ~ a + b + c,
  data = toy,
  importance = "permutation",
  seed = 1
)
rf_abc$variable.importance |> round(4)
```

```
##      a      b      c 
## 0.5037 0.1234 0.3133
```

With all that in mind, we can conclude that interpreting importance scores in Random Forest models is challenging when multicollinearity is high. But Random Forest is not the only machine learning affected by this issue. In the Appendix below I have left an example with Extreme Gradient Boosting so you can play with it.

And that's all for now, folks, I hope you found this post useful!

## Appendix

This section shows several extra examples of linear and machine learning models you can play with.

### Other Linear Models using QR Decomposition

As I commented above, many linear modeling functions use QR decomposition, and you will have to be careful interpreting model coefficients in the presence of strong multicollinearity in the predictors. 

Here I show several examples with `glm()` (Generalized Linear Models), `nlme::gls()` (Generalized Least Squares), and `glmnet::cv.glmnet()` (Elastic Net Regularization). In all them, no matter how fancy, the interpretation of coefficients becomes tricky when multicollinearity is high.

**Generalized Linear Models with glm()**


```r
#Generalized Linear Models
#non-collinear predictors
glm_ab <- glm(
  formula = y ~ a + b,
  data = toy
  )

round(coefficients(glm_ab), 4)[2:3]
```

```
##      a      b 
## 0.7477 0.2616
```

```r
#collinear predictors
glm_abcd <- glm(
  formula = y ~ a + b + c + d,
  data = toy
  )

round(coefficients(glm_abcd), 4)[2:5]
```

```
##      a      b      c      d 
## 0.7184 0.2596 0.0273 0.0039
```

**Generalized Least Squares with nlme::gls()**


```r
library(nlme)
```

```
## 
## Attaching package: 'nlme'
```

```
## The following object is masked from 'package:dplyr':
## 
##     collapse
```

```r
#Generalized Least Squares
#non-collinear predictors
gls_ab <- nlme::gls(
  model = y ~ a + b,
  data = toy
  )

round(coefficients(gls_ab), 4)[2:3]
```

```
##      a      b 
## 0.7477 0.2616
```

```r
#collinear predictors
gls_abcd <- nlme::gls(
  model = y ~ a + b + c + d,
  data = toy
  )

round(coefficients(gls_abcd), 4)[2:5]
```

```
##      a      b      c      d 
## 0.7184 0.2596 0.0273 0.0039
```

**Elastic Net Regularization and Lasso penalty with glmnet::glmnet()**


```r
library(glmnet)
```

```
## Loading required package: Matrix
```

```
## Loaded glmnet 4.1-10
```

```r
#Elastic net regularization with Lasso penalty
#non-collinear predictors
glmnet_ab <- glmnet::cv.glmnet(
  x = as.matrix(toy[, c("a", "b")]),
  y = toy$y,
  alpha = 1 #lasso penalty
)

round(coef(glmnet_ab$glmnet.fit, s = glmnet_ab$lambda.min), 4)[2:3]
```

```
## [1] 0.7438 0.2578
```

```r
#collinear predictors
glmnet_abcd <- glmnet::cv.glmnet(
  x = as.matrix(toy[, c("a", "b", "c", "d")]),
  y = toy$y,
  alpha = 1 
)

#notice that the lasso regularization nuked the coefficients of predictors b and c
round(coef(glmnet_abcd$glmnet.fit, s = glmnet_abcd$lambda.min), 4)[2:5]
```

```
## [1] 0.7101 0.2507 0.0267 0.0149
```


### Extreme Gradient Boosting and Multicollinearity

Gradient Boosting models trained with multicollinear predictors behave in a way similar to linear models with QR decomposition. When two variables are highly correlated, one of them is going to have an importance much higher than the other.


```r
library(xgboost)

#without multicollinearity
gb_ab <- xgboost::xgboost(
  data = as.matrix(toy[, c("a", "b")]),
  label = toy$y,
  objective = "reg:squarederror",
  nrounds = 100,
  verbose = FALSE
  )
```

```
## Warning in throw_err_or_depr_msg("Passed unrecognized parameters: ",
## paste(head(names_unrecognized), : Passed unrecognized parameters: verbose. This
## warning will become an error in a future version.
```

```
## Warning in throw_err_or_depr_msg("Parameter '", match_old, "' has been renamed
## to '", : Parameter 'data' has been renamed to 'x'. This warning will become an
## error in a future version.
```

```
## Warning in throw_err_or_depr_msg("Parameter '", match_old, "' has been renamed
## to '", : Parameter 'label' has been renamed to 'y'. This warning will become an
## error in a future version.
```

```r
#with multicollinearity
gb_abcd <- xgboost::xgboost(
  data = as.matrix(toy[, c("a", "b", "c", "d")]),
  label = toy$y,
  objective = "reg:squarederror",
  nrounds = 100,
  verbose = FALSE
)
```

```
## Warning in throw_err_or_depr_msg("Passed unrecognized parameters: ",
## paste(head(names_unrecognized), : Passed unrecognized parameters: verbose. This
## warning will become an error in a future version.
```

```
## Warning in throw_err_or_depr_msg("Parameter '", match_old, "' has been renamed
## to '", : Parameter 'data' has been renamed to 'x'. This warning will become an
## error in a future version.
```

```
## Warning in throw_err_or_depr_msg("Parameter '", match_old, "' has been renamed
## to '", : Parameter 'label' has been renamed to 'y'. This warning will become an
## error in a future version.
```


```r
xgb.importance(model = gb_ab)[, c(1:2)]
```

```
##    Feature      Gain
## 1:       a 0.8583137
## 2:       b 0.1416863
```


```r
xgb.importance(model = gb_abcd)[, c(1:2)] |> 
  dplyr::arrange(Feature)
```

```
##    Feature       Gain
## 1:       a 0.77891575
## 2:       b 0.08050964
## 3:       c 0.03198638
## 4:       d 0.10858823
```

But there is a twist too. When two variables are perfectly correlated, one of them is removed right away from the model!


```r
#replace c with perfect copy of a
toy$c <- toy$a

#with multicollinearity
gb_abcd <- xgboost::xgboost(
  x = as.matrix(toy[, c("a", "b", "c", "d")]),
  y = toy$y,
  objective = "reg:squarederror",
  nrounds = 100
)

xgboost::xgb.importance(model = gb_abcd)[, c(1:2)] |> 
  dplyr::arrange(Feature)
```

```
##    Feature       Gain
## 1:       a 0.79846929
## 2:       b 0.08155586
## 3:       d 0.11997485
```




