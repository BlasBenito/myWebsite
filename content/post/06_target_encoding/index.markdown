---
title: Mapping Categorical Predictors to Numeric With Target Encoding
author: ''
date: '2023-11-05'
slug: multicollinearity-management
links:
- icon: github
  icon_pack: fab
  name: GitHub
  url: https://github.com/BlasBenito/collinear
categories: []
tags: [R packages, Multicollinearity, Variable Selection]
subtitle: ''
summary: 'Target encoding is commonly used to map categorical variables to numeric with the objective of facilitating exploratory data analysis and machine learning modeling. This post covers the basics of this method, and explains how and when to use it.'
authors: [admin]
lastmod: '2023-11-05T08:14:23+02:00'
featured: no
draft: true
image:
  caption: Graph by Blas M. Benito
  focal_point: Smart
  margin: auto
projects: []
---


# Summary

TODO

# Resources

# R packages

This tutorial requires the development version (>= 1.0.3) of the newly released R package [`collinear`](https://blasbenito.github.io/collinear/), and a few more.


```r
#required
install.packages("remotes")
remotes::install_github(
  repo = "blasbenito/collinear", 
  ref = "development"
  )
install.packages("fastDummies")
install.packages("caret")
install.packages("ranger")
install.packages("dplyr")
install.packages("ggplot2")
```

# Categorical Predictors are Kinda Annoying

I mean, the title of this section says it already, and I bet you have experienced it during an Exploratory Data Analysis (EDA) or a feature selection for model training and the likes. You likely had a nice bunch of numerical variables to use as predictors, no issues there. But then, you discovered among your columns thingies like "sampling_location", "region_name", "favorite_color", or any other type of predictor made of strings, lots of strings. And some of these made sense, and some of them didn't, because who knows where they came from. And you had to branch your code to deal with numeric and categorical variables separately. Or maybe chose to ignore them, as I have done plenty of times.

Yeah, nobody likes them much at all, But sometimes, these stringy monsters are all you have to move on with your work. And you are not the only one. That's why many efforts have been made to convert them to numeric and kill the problem at once, so now we all have two problems instead.

Let me go ahead and illustrate the issue. There is a nice data frame in the `collinear` R package named `vi`, with one response variable named `vi_mean`, and several numeric and categorical predictors named in the vector `vi_predictors`.


```r
library(collinear)

data(
  vi,
  vi_predictors
)

dplyr::glimpse(vi)
```

```
## Rows: 30,000
## Columns: 67
## $ longitude                  <dbl> -114.254306, 114.845693, -122.145972, 108.3…
## $ latitude                   <dbl> 45.0540272, 26.2706940, 56.3790272, 29.9456…
## $ vi_mean                    <dbl> 0.38, 0.53, 0.45, 0.69, 0.42, 0.68, 0.70, 0…
## $ vi_max                     <dbl> 0.57, 0.67, 0.65, 0.85, 0.64, 0.78, 0.77, 0…
## $ vi_min                     <dbl> 0.12, 0.41, 0.25, 0.50, 0.25, 0.48, 0.60, 0…
## $ vi_range                   <dbl> 0.45, 0.26, 0.40, 0.34, 0.39, 0.31, 0.17, 0…
## $ koppen_zone                <chr> "BSk", "Cfa", "Dfc", "Cfb", "Aw", "Cfa", "A…
## $ koppen_group               <chr> "Arid", "Temperate", "Cold", "Temperate", "…
## $ koppen_description         <chr> "steppe, cold", "no dry season, hot summer"…
## $ soil_type                  <chr> "Cambisols", "Acrisols", "Luvisols", "Aliso…
## $ topo_slope                 <int> 6, 2, 0, 10, 0, 10, 6, 0, 2, 0, 0, 1, 0, 1,…
## $ topo_diversity             <int> 29, 24, 21, 25, 19, 30, 26, 20, 26, 22, 25,…
## $ topo_elevation             <int> 1821, 143, 765, 1474, 378, 485, 604, 1159, …
## $ swi_mean                   <dbl> 27.5, 56.1, 41.4, 59.3, 37.4, 56.3, 52.3, 2…
## $ swi_max                    <dbl> 62.9, 74.4, 81.9, 81.1, 83.2, 73.8, 55.8, 3…
## $ swi_min                    <dbl> 24.5, 33.3, 42.2, 31.3, 8.3, 28.8, 25.3, 11…
## $ swi_range                  <dbl> 38.4, 41.2, 39.7, 49.8, 74.9, 45.0, 30.5, 2…
## $ soil_temperature_mean      <dbl> 4.8, 19.9, 1.2, 13.0, 28.2, 18.1, 21.5, 23.…
## $ soil_temperature_max       <dbl> 29.9, 32.6, 20.4, 24.6, 41.6, 29.1, 26.4, 4…
## $ soil_temperature_min       <dbl> -12.4, 3.9, -16.0, -0.4, 16.8, 4.1, 17.3, 5…
## $ soil_temperature_range     <dbl> 42.3, 28.8, 36.4, 25.0, 24.8, 24.9, 9.1, 38…
## $ soil_sand                  <int> 41, 39, 27, 29, 48, 33, 30, 78, 23, 64, 54,…
## $ soil_clay                  <int> 20, 24, 28, 31, 27, 29, 40, 15, 26, 22, 23,…
## $ soil_silt                  <int> 38, 35, 43, 38, 23, 36, 29, 6, 49, 13, 22, …
## $ soil_ph                    <dbl> 6.5, 5.9, 5.6, 5.5, 6.5, 5.8, 5.2, 7.1, 7.3…
## $ soil_soc                   <dbl> 43.1, 14.6, 36.4, 34.9, 8.1, 20.8, 44.5, 4.…
## $ soil_nitrogen              <dbl> 2.8, 1.3, 2.9, 3.6, 1.2, 1.9, 2.8, 0.6, 3.1…
## $ solar_rad_mean             <dbl> 17.634, 19.198, 13.257, 14.163, 24.512, 17.…
## $ solar_rad_max              <dbl> 31.317, 24.498, 25.283, 17.237, 28.038, 22.…
## $ solar_rad_min              <dbl> 5.209, 13.311, 1.587, 9.642, 19.102, 12.196…
## $ solar_rad_range            <dbl> 26.108, 11.187, 23.696, 7.595, 8.936, 10.20…
## $ growing_season_length      <dbl> 139, 365, 164, 333, 228, 365, 365, 60, 365,…
## $ growing_season_temperature <dbl> 12.65, 19.35, 11.55, 12.45, 26.45, 17.75, 2…
## $ growing_season_rainfall    <dbl> 224.5, 1493.4, 345.4, 1765.5, 984.4, 1860.5…
## $ growing_degree_days        <dbl> 2140.5, 7080.9, 2053.2, 4162.9, 10036.7, 64…
## $ temperature_mean           <dbl> 3.65, 19.35, 1.45, 11.35, 27.55, 17.65, 22.…
## $ temperature_max            <dbl> 24.65, 33.35, 21.15, 23.75, 38.35, 30.55, 2…
## $ temperature_min            <dbl> -14.05, 3.05, -18.25, -3.55, 19.15, 2.45, 1…
## $ temperature_range          <dbl> 38.7, 30.3, 39.4, 27.3, 19.2, 28.1, 7.0, 29…
## $ temperature_seasonality    <dbl> 882.6, 786.6, 1070.9, 724.7, 219.3, 747.2, …
## $ rainfall_mean              <int> 446, 1493, 560, 1794, 990, 1860, 3150, 356,…
## $ rainfall_min               <int> 25, 37, 24, 29, 0, 60, 122, 1, 10, 12, 0, 0…
## $ rainfall_max               <int> 62, 209, 87, 293, 226, 275, 425, 62, 256, 3…
## $ rainfall_range             <int> 37, 172, 63, 264, 226, 215, 303, 61, 245, 2…
## $ evapotranspiration_mean    <dbl> 78.32, 105.88, 50.03, 64.65, 156.60, 108.50…
## $ evapotranspiration_max     <dbl> 164.70, 190.86, 117.53, 115.79, 187.71, 191…
## $ evapotranspiration_min     <dbl> 13.67, 50.44, 3.53, 28.01, 128.59, 51.39, 8…
## $ evapotranspiration_range   <dbl> 151.03, 140.42, 113.99, 87.79, 59.13, 139.9…
## $ cloud_cover_mean           <int> 31, 48, 42, 64, 38, 52, 60, 13, 53, 20, 11,…
## $ cloud_cover_max            <int> 39, 61, 49, 71, 58, 67, 77, 18, 60, 27, 23,…
## $ cloud_cover_min            <int> 16, 34, 33, 54, 19, 39, 45, 6, 45, 14, 2, 1…
## $ cloud_cover_range          <int> 23, 27, 15, 17, 38, 27, 32, 11, 15, 12, 21,…
## $ aridity_index              <dbl> 0.54, 1.27, 0.90, 2.08, 0.55, 1.67, 2.88, 0…
## $ humidity_mean              <dbl> 55.56, 62.14, 59.87, 69.32, 51.60, 62.76, 7…
## $ humidity_max               <dbl> 63.98, 65.00, 68.19, 71.90, 67.07, 65.68, 7…
## $ humidity_min               <dbl> 48.41, 58.97, 53.75, 67.21, 33.89, 59.92, 7…
## $ humidity_range             <dbl> 15.57, 6.03, 14.44, 4.69, 33.18, 5.76, 3.99…
## $ biogeo_ecoregion           <chr> "South Central Rockies forests", "Jian Nan …
## $ biogeo_biome               <chr> "Temperate Conifer Forests", "Tropical & Su…
## $ biogeo_realm               <chr> "Nearctic", "Indomalayan", "Nearctic", "Pal…
## $ country_name               <chr> "United States of America", "China", "Canad…
## $ country_population         <dbl> 313973000, 1338612970, 33487208, 1338612970…
## $ country_gdp                <dbl> 15094000, 7973000, 1300000, 7973000, 15860,…
## $ country_income             <chr> "1. High income: OECD", "3. Upper middle in…
## $ continent                  <chr> "North America", "Asia", "North America", "…
## $ region                     <chr> "Americas", "Asia", "Americas", "Asia", "Af…
## $ subregion                  <chr> "Northern America", "Eastern Asia", "Northe…
```

The categorical variables in this dataset are identified below:


```r
vi_categorical <- collinear::identify_non_numeric_predictors(
  df = vi,
  predictors = vi_predictors
)
vi_categorical
```

```
##  [1] "koppen_zone"        "koppen_group"       "koppen_description"
##  [4] "soil_type"          "biogeo_ecoregion"   "biogeo_biome"      
##  [7] "biogeo_realm"       "country_name"       "country_income"    
## [10] "continent"          "region"             "subregion"
```

And their number of categories:


```r
data.frame(
  name = vi_categorical,
  categories = lapply(
  X = vi_categorical,
  FUN = function(x) length(unique(vi[[x]]))
) |> 
  unlist()
) |> 
  dplyr::arrange(
    dplyr::desc(categories)
  )
```

```
##                  name categories
## 1    biogeo_ecoregion        604
## 2        country_name        176
## 3           soil_type         29
## 4         koppen_zone         25
## 5           subregion         21
## 6  koppen_description         19
## 7        biogeo_biome         13
## 8        biogeo_realm          7
## 9           continent          7
## 10     country_income          6
## 11             region          6
## 12       koppen_group          5
```

A few, like `country_name` and `biogeo_ecoregion` are here to ruin your day, aren't they? But ok, let's start with one with a moderate number of categories, like `koppen_zone`. This variable has 25 categories representing climate zones.


```r
sort(unique(vi$koppen_zone))
```

```
##  [1] "Af"  "Am"  "Aw"  "BSh" "BSk" "BWh" "BWk" "Cfa" "Cfb" "Cfc" "Csa" "Csb"
## [13] "Cwa" "Cwb" "Dfa" "Dfb" "Dfc" "Dfd" "Dsa" "Dsb" "Dsc" "Dwa" "Dwb" "Dwc"
## [25] "ET"
```

Let's use it as predictor of `vi_mean` in a linear model and take a look at the summary.


```r
lm(
  formula = vi_mean ~ koppen_zone, 
  data = vi
  ) |> 
  summary()
```

```
## 
## Call:
## lm(formula = vi_mean ~ koppen_zone, data = vi)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.57090 -0.05592 -0.00305  0.05695  0.49212 
## 
## Coefficients:
##                 Estimate Std. Error  t value Pr(>|t|)    
## (Intercept)     0.670899   0.002054  326.651  < 2e-16 ***
## koppen_zoneAm  -0.022807   0.003151   -7.239 4.64e-13 ***
## koppen_zoneAw  -0.143375   0.002434  -58.903  < 2e-16 ***
## koppen_zoneBSh -0.347894   0.002787 -124.839  < 2e-16 ***
## koppen_zoneBSk -0.422162   0.002823 -149.523  < 2e-16 ***
## koppen_zoneBWh -0.537854   0.002392 -224.859  < 2e-16 ***
## koppen_zoneBWk -0.543022   0.002906 -186.883  < 2e-16 ***
## koppen_zoneCfa -0.104730   0.003087  -33.928  < 2e-16 ***
## koppen_zoneCfb -0.081909   0.003949  -20.744  < 2e-16 ***
## koppen_zoneCfc -0.120899   0.017419   -6.941 3.99e-12 ***
## koppen_zoneCsa -0.274720   0.005145  -53.399  < 2e-16 ***
## koppen_zoneCsb -0.136575   0.006142  -22.237  < 2e-16 ***
## koppen_zoneCwa -0.149006   0.003318  -44.910  < 2e-16 ***
## koppen_zoneCwb -0.177753   0.004579  -38.817  < 2e-16 ***
## koppen_zoneDfa -0.214981   0.004437  -48.453  < 2e-16 ***
## koppen_zoneDfb -0.179080   0.003347  -53.499  < 2e-16 ***
## koppen_zoneDfc -0.237050   0.003937  -60.207  < 2e-16 ***
## koppen_zoneDfd -0.395899   0.065900   -6.008 1.91e-09 ***
## koppen_zoneDsa -0.462494   0.011401  -40.567  < 2e-16 ***
## koppen_zoneDsb -0.330969   0.008056  -41.084  < 2e-16 ***
## koppen_zoneDsc -0.327097   0.011244  -29.090  < 2e-16 ***
## koppen_zoneDwa -0.282620   0.005248  -53.850  < 2e-16 ***
## koppen_zoneDwb -0.254027   0.005981  -42.473  < 2e-16 ***
## koppen_zoneDwc -0.306156   0.005660  -54.096  < 2e-16 ***
## koppen_zoneET  -0.297869   0.011649  -25.571  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.09315 on 29975 degrees of freedom
## Multiple R-squared:  0.805,	Adjusted R-squared:  0.8049 
## F-statistic:  5157 on 24 and 29975 DF,  p-value: < 2.2e-16
```

Look at this monster. What the hell happened here? Linear models cannot deal with categorical predictors, so they create numeric **dummy variables** instead. The function `stats::model.matrix()` does exactly that:


```r
dummy_variables <- stats::model.matrix( ~ koppen_zone, data = vi)
ncol(dummy_variables)
```

```
## [1] 25
```

```r
dummy_variables[1:10, 1:10]
```

```
##    (Intercept) koppen_zoneAm koppen_zoneAw koppen_zoneBSh koppen_zoneBSk
## 1            1             0             0              0              1
## 2            1             0             0              0              0
## 3            1             0             0              0              0
## 4            1             0             0              0              0
## 5            1             0             1              0              0
## 6            1             0             0              0              0
## 7            1             0             0              0              0
## 8            1             0             0              1              0
## 9            1             0             0              0              0
## 10           1             0             0              0              0
##    koppen_zoneBWh koppen_zoneBWk koppen_zoneCfa koppen_zoneCfb koppen_zoneCfc
## 1               0              0              0              0              0
## 2               0              0              1              0              0
## 3               0              0              0              0              0
## 4               0              0              0              1              0
## 5               0              0              0              0              0
## 6               0              0              1              0              0
## 7               0              0              0              0              0
## 8               0              0              0              0              0
## 9               0              0              0              0              0
## 10              1              0              0              0              0
```

This function first creates an Intercept column with all ones. Then, for each original category except the first one ("Af"), a new column with value 1 in the cases where the given category was present and 0 otherwise is created. The category with no column ("Af") is represented in these cases in the intercept where all other dummy columns are zero. This is, essentially, **one-hot encoding** with a little twist. You will find most people use the terms *dummy variables* and *one-hot encoding* interchangeably, and that's ok. But in the end, the little twist of omitting the first category is what differentiates them. Most functions performing one-hot encoding, no matter their name, are creating as many columns as categories. That is for example the case of `fastDummies::dummy_cols()`, from the R package [`fastDummies`](https://jacobkap.github.io/fastDummies/):


```r
df <- fastDummies::dummy_cols(
  .data = vi[, "koppen_zone", drop = FALSE],
  select_columns = "koppen_zone",
  remove_selected_columns = TRUE
)
dplyr::glimpse(df)
```

```
## Rows: 30,000
## Columns: 25
## $ koppen_zone_Af  <int> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Am  <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Aw  <int> 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_BSh <int> 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, …
## $ koppen_zone_BSk <int> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_BWh <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, …
## $ koppen_zone_BWk <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, …
## $ koppen_zone_Cfa <int> 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Cfb <int> 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, …
## $ koppen_zone_Cfc <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Csa <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Csb <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Cwa <int> 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Cwb <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dfa <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, …
## $ koppen_zone_Dfb <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dfc <int> 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dfd <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dsa <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dsb <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dsc <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dwa <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dwb <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_Dwc <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
## $ koppen_zone_ET  <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
```

As good as dummy variables are to patch linear models when predictors are categorical, it creates a couple of glaring issues that are hard to address when the number of categories (cardinality) is high. The first is **increased dimensionality**. For example, if create dummy variables for all categorical predictors in `vi`, then we'd go from the original 61 predictors to a total of 967. That's a real **dimensionality explosion**! This alone can degrade the computational performance of a model due to increased data size. But other issues can arise as well, like, what happens if a new category shows up in your prediction data? Also, one-hot encoding induces multicollinearity, and makes very hard obtaining accurate estimates for the coefficientes of the encoded categories. Look at the Variance Inflation Factors of the encoded Koppen zones, they have absurd values!


```r
collinear::vif_df(
  df = df
)
```

```
##           variable          vif
## 1  koppen_zone_Dfd 1.031226e+12
## 2  koppen_zone_Cfc 1.493932e+13
## 3   koppen_zone_ET 3.395786e+13
## 4  koppen_zone_Dsa 3.549784e+13
## 5  koppen_zone_Dsc 3.652432e+13
## 6  koppen_zone_Dsb 7.338609e+13
## 7  koppen_zone_Csb 1.323997e+14
## 8  koppen_zone_Dwb 1.405032e+14
## 9  koppen_zone_Dwc 1.592088e+14
## 10 koppen_zone_Dwa 1.894423e+14
## 11 koppen_zone_Csa 1.984881e+14
## 12 koppen_zone_Cwb 2.624933e+14
## 13 koppen_zone_Dfa 2.838687e+14
## 14 koppen_zone_Cfb 3.834325e+14
## 15 koppen_zone_Dfc 3.863684e+14
## 16 koppen_zone_Dfb 6.139201e+14
## 17 koppen_zone_Cwa 6.309241e+14
## 18  koppen_zone_Am 7.440723e+14
## 19 koppen_zone_Cfa 7.966760e+14
## 20 koppen_zone_BWk 9.866240e+14
## 21  koppen_zone_Af 9.879589e+14
## 22 koppen_zone_BSk 1.100300e+15
## 23 koppen_zone_BSh 1.158438e+15
## 24  koppen_zone_Aw 2.177627e+15
## 25 koppen_zone_BWh 2.403991e+15
```









```r
df <- fastDummies::dummy_cols(
  .data = vi,
  select_columns = vi_categorical,
  remove_selected_columns = TRUE
)
ncol(df)
```

```
## [1] 973
```






https://www.reddit.com/r/statistics/comments/7oe8xi/why_is_it_possible_to_have_n1_dummy_variables/


Cannot be easily used in EDAs
their importance is hard to quantify
high cardinlity makes things difficult
methods created to deal with them (like one-hot encoding) aren't ideal for tree based models

# Target encoding

What is target encoding?
How it works?
A couple of examples

# Target encoding vs one-hot encoding

Two random forest models, one done with one-hot encoding, and another with target encoding

# Final remarks

