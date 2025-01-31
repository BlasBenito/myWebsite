---
title: "{distantia} Demo: Covid-19 Prevalence in California"
author: ""
date: '2025-01-25'
slug: distantia-showcase-covid
categories: []
tags:
- Rstats
- Dynamic Time Warping
- Data Science
- Time Series Analysis
- Tutorial
subtitle: ''
summary: "Showcase with real examples of the analytical capabilities implemented in the R package 'distantia'."
authors: [admin]
lastmod: '2025-01-25T07:28:01+01:00'
featured: no
draft: true
image:
  caption: ''
  focal_point: Smart
  margin: auto
projects: []
toc: true
---

<link href="{{< blogdown/postref >}}index_files/htmltools-fill/fill.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dygraphs/dygraph.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dygraphs/dygraph-combined.js"></script>
<script src="{{< blogdown/postref >}}index_files/dygraphs/shapes.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment/moment.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment-timezone/moment-timezone-with-data.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment-fquarter/moment-fquarter.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dygraphs-binding/dygraphs.js"></script>
<link href="{{< blogdown/postref >}}index_files/htmltools-fill/fill.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/dygraphs/dygraph.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/dygraphs/dygraph-combined.js"></script>
<script src="{{< blogdown/postref >}}index_files/dygraphs/shapes.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment/moment.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment-timezone/moment-timezone-with-data.js"></script>
<script src="{{< blogdown/postref >}}index_files/moment-fquarter/moment-fquarter.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/dygraphs-binding/dygraphs.js"></script>

## Summary

This post showcases the capabilities of the R package [`distantia`](https://blasbenito.github.io/distantia/) to process, compare, and analyze different types of time series.

## Setup

This tutorial requires the following packages:

- [`distantia`](https://blasbenito.github.io/distantia/): time series analysis via dynamic time warping.
- [`dplyr`](https://dplyr.tidyverse.org/): data frame manipulation.
- [`mapview`](https://r-spatial.github.io/mapview/): easy to use interactive map visualization.
- [`gt`](https://github.com/rstudio/gt): table formatting.

``` r
library(distantia)
library(zoo)
library(dplyr)
library(mapview)
library(gt)
library(dygraphs)
```

## Example Data

This demo focuses on two example data frames shipped with the package `distantia`: `covid_counties`, and `covid_prevalence`.

### `covid_counties`

Stored as a [`simple features`](https://r-spatial.github.io/sf/) data frame, `covid_counties` contains county polygons and several socioeconomic variables. It is connected to `covid_prevalence` by county name, which is stored in the column `name`.

<iframe src="la_population.html" name="LA_Population" width="800" height="600" scrolling="auto" frameborder="0">
<p>
California counties represented in the Covid-19 dataset.
</p>
</iframe>

The socioeconomic variables available in `covid_counties` are:

- `area_hectares`: county surface.
- `population`: county population.
- `poverty_percentage`: population percentage below the poverty line.
- `median_income`: median county income in dollars.
- `domestic_product`: yearly domestic product in **b**illions (not a typo) of dollars.
- `daily_miles_traveled`: daily miles traveled by the average inhabitant.
- `employed_percentage`: percentage of the county population under employment.

Please, take in mind that these variables were included in the dataset because they were easy to capture from on-line sources, not because of their importance for epidemiological analyses.

### `covid_prevalence`

This data frame contains weekly Covid-19 prevalence in 36 California counties between 2020-03-16 and 2023-12-18. It is derived from a daily prevalence dataset available [here](https://github.com/BlasBenito/distantia/blob/main/data_full/covid_prevalence.rda).

The prevalence time series has the columns `name`, `time`, with the date of the first day of the week each data point represents, and `prevalence`, expressed as proportion of positive tests. The table below shows the first rows of this data frame.

<div id="xedxzskjty" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xedxzskjty table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#xedxzskjty thead, #xedxzskjty tbody, #xedxzskjty tfoot, #xedxzskjty tr, #xedxzskjty td, #xedxzskjty th {
  border-style: none;
}
&#10;#xedxzskjty p {
  margin: 0;
  padding: 0;
}
&#10;#xedxzskjty .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#xedxzskjty .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#xedxzskjty .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#xedxzskjty .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#xedxzskjty .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#xedxzskjty .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#xedxzskjty .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#xedxzskjty .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#xedxzskjty .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#xedxzskjty .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#xedxzskjty .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#xedxzskjty .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#xedxzskjty .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#xedxzskjty .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#xedxzskjty .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xedxzskjty .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#xedxzskjty .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#xedxzskjty .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#xedxzskjty .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xedxzskjty .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#xedxzskjty .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xedxzskjty .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#xedxzskjty .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xedxzskjty .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xedxzskjty .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xedxzskjty .gt_left {
  text-align: left;
}
&#10;#xedxzskjty .gt_center {
  text-align: center;
}
&#10;#xedxzskjty .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#xedxzskjty .gt_font_normal {
  font-weight: normal;
}
&#10;#xedxzskjty .gt_font_bold {
  font-weight: bold;
}
&#10;#xedxzskjty .gt_font_italic {
  font-style: italic;
}
&#10;#xedxzskjty .gt_super {
  font-size: 65%;
}
&#10;#xedxzskjty .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#xedxzskjty .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#xedxzskjty .gt_indent_1 {
  text-indent: 5px;
}
&#10;#xedxzskjty .gt_indent_2 {
  text-indent: 10px;
}
&#10;#xedxzskjty .gt_indent_3 {
  text-indent: 15px;
}
&#10;#xedxzskjty .gt_indent_4 {
  text-indent: 20px;
}
&#10;#xedxzskjty .gt_indent_5 {
  text-indent: 25px;
}
&#10;#xedxzskjty .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#xedxzskjty div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="name">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="time">time</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="prevalence">prevalence</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-03-16</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-03-23</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-03-30</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-04-06</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-04-13</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-04-20</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.02</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-04-27</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-05-04</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.02</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-05-11</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.02</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-05-18</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-05-25</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-06-01</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.02</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-06-08</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.02</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-06-15</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-06-22</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-06-29</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-07-06</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-07-13</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-07-20</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat; text-align: center;">Alameda</td>
<td headers="time" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">2020-07-27</td>
<td headers="prevalence" class="gt_row gt_right" style="font-family: Montserrat; text-align: center;">0.01</td></tr>
  </tbody>
  &#10;  
</table>
</div>

## Objective

This post focuses on the Covid-19 dataset described above to showcase the applications of `distantia` to the analysis of epidemiological time series.

- **Prepare**: transform the data into a format compatible with `distantia`.
- **Explore**:
- **Analyze**:
- **Model**:

**DISCLAIMER:** I am not an epidemiologist, so I will refrain from interpreting any results, and will focus on technical details about the usage of `distantia` insted.

## Data Preparation

This section shows how to transform the data frame `covid_prevalence` into a format compatible with `distantia`.

A **time series list**, or `tsl` for short, is a list of [`zoo`](https://cran.r-project.org/web/packages/zoo/index.html) time series representing unique realizations of the same phenomena observed in different sites, times, or individuals. All [data manipulation](https://blasbenito.github.io/distantia/articles/time_series_lists.html) and analysis functions in `distantia` are designed to be applied to all time series in a `tsl` at once.

The function `tsl_initialize()` transforms time series stored as long data frames into time series lists.

``` r
tsl <- distantia::tsl_initialize(
  x = covid_prevalence,
  name_column = "name",
  time_column = "time"
)
```

Each element in `tsl` is named after the county the data belongs to.

``` r
names(tsl)
```

    ##  [1] "Alameda"         "Butte"           "Contra_Costa"    "El_Dorado"      
    ##  [5] "Fresno"          "Humboldt"        "Imperial"        "Kern"           
    ##  [9] "Kings"           "Los_Angeles"     "Madera"          "Marin"          
    ## [13] "Merced"          "Monterey"        "Napa"            "Orange"         
    ## [17] "Placer"          "Riverside"       "Sacramento"      "San_Bernardino" 
    ## [21] "San_Diego"       "San_Francisco"   "San_Joaquin"     "San_Luis_Obispo"
    ## [25] "San_Mateo"       "Santa_Barbara"   "Santa_Clara"     "Santa_Cruz"     
    ## [29] "Shasta"          "Solano"          "Sonoma"          "Stanislaus"     
    ## [33] "Sutter"          "Tulare"          "Ventura"         "Yolo"

The `zoo` objects within `tsl` also have the attribute `name` to help track the data in case it is extracted from the time series list.

``` r
attributes(tsl[[1]])$name
```

    ## [1] "Alameda"

``` r
attributes(tsl[[2]])$name
```

    ## [1] "Butte"

Each individual `zoo` object comprises a time index and a data matrix.

``` r
zoo::index(tsl[["Alameda"]]) |> 
  head()
```

    ## [1] "2020-03-16" "2020-03-23" "2020-03-30" "2020-04-06" "2020-04-13"
    ## [6] "2020-04-20"

``` r
zoo::coredata(tsl[["Alameda"]]) |> 
  head()
```

    ##   prevalence
    ## 1       0.01
    ## 2       0.01
    ## 3       0.01
    ## 4       0.01
    ## 5       0.01
    ## 6       0.02

## Exploration

This section describes the tools in `distantia` that may help develop an intuition on the properties of the data at hand, either via visualization or descriptive analysis.

### Visualization

The individual `zoo` objects in `tsl` can be plotted right away using `plot()` or `distantia::zoo_plot()`, but `dygraphs::dygraph()` offers a fancier interactive visualization that helps localize specific events in time, and even compare two or more time series at once.

``` r
dygraphs::dygraph(
  data = tsl$Napa, 
  ylab = "Covid-19 Prevalence"
  )
```

<div class="dygraphs html-widget html-fill-item" id="htmlwidget-1" style="width:768px;height:192px;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"attrs":{"ylabel":"Covid-19 Prevalence","labels":["week","prevalence"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60}}},"scale":"weekly","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-03-16T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-22T00:00:00.000Z","2020-06-29T00:00:00.000Z","2020-07-06T00:00:00.000Z","2020-07-13T00:00:00.000Z","2020-07-20T00:00:00.000Z","2020-07-27T00:00:00.000Z","2020-08-03T00:00:00.000Z","2020-08-10T00:00:00.000Z","2020-08-17T00:00:00.000Z","2020-08-24T00:00:00.000Z","2020-08-31T00:00:00.000Z","2020-09-07T00:00:00.000Z","2020-09-14T00:00:00.000Z","2020-09-21T00:00:00.000Z","2020-09-28T00:00:00.000Z","2020-10-05T00:00:00.000Z","2020-10-12T00:00:00.000Z","2020-10-19T00:00:00.000Z","2020-10-26T00:00:00.000Z","2020-11-02T00:00:00.000Z","2020-11-09T00:00:00.000Z","2020-11-16T00:00:00.000Z","2020-11-23T00:00:00.000Z","2020-11-30T00:00:00.000Z","2020-12-07T00:00:00.000Z","2020-12-14T00:00:00.000Z","2020-12-21T00:00:00.000Z","2020-12-28T00:00:00.000Z","2021-01-04T00:00:00.000Z","2021-01-11T00:00:00.000Z","2021-01-18T00:00:00.000Z","2021-01-25T00:00:00.000Z","2021-02-01T00:00:00.000Z","2021-02-08T00:00:00.000Z","2021-02-15T00:00:00.000Z","2021-02-22T00:00:00.000Z","2021-03-01T00:00:00.000Z","2021-03-08T00:00:00.000Z","2021-03-15T00:00:00.000Z","2021-03-22T00:00:00.000Z","2021-03-29T00:00:00.000Z","2021-04-05T00:00:00.000Z","2021-04-12T00:00:00.000Z","2021-04-19T00:00:00.000Z","2021-04-26T00:00:00.000Z","2021-05-03T00:00:00.000Z","2021-05-10T00:00:00.000Z","2021-05-17T00:00:00.000Z","2021-05-24T00:00:00.000Z","2021-05-31T00:00:00.000Z","2021-06-07T00:00:00.000Z","2021-06-14T00:00:00.000Z","2021-06-21T00:00:00.000Z","2021-06-28T00:00:00.000Z","2021-07-05T00:00:00.000Z","2021-07-12T00:00:00.000Z","2021-07-19T00:00:00.000Z","2021-07-26T00:00:00.000Z","2021-08-02T00:00:00.000Z","2021-08-09T00:00:00.000Z","2021-08-16T00:00:00.000Z","2021-08-23T00:00:00.000Z","2021-08-30T00:00:00.000Z","2021-09-06T00:00:00.000Z","2021-09-13T00:00:00.000Z","2021-09-20T00:00:00.000Z","2021-09-27T00:00:00.000Z","2021-10-04T00:00:00.000Z","2021-10-11T00:00:00.000Z","2021-10-18T00:00:00.000Z","2021-10-25T00:00:00.000Z","2021-11-01T00:00:00.000Z","2021-11-08T00:00:00.000Z","2021-11-15T00:00:00.000Z","2021-11-22T00:00:00.000Z","2021-11-29T00:00:00.000Z","2021-12-06T00:00:00.000Z","2021-12-13T00:00:00.000Z","2021-12-20T00:00:00.000Z","2021-12-27T00:00:00.000Z","2022-01-03T00:00:00.000Z","2022-01-10T00:00:00.000Z","2022-01-17T00:00:00.000Z","2022-01-24T00:00:00.000Z","2022-01-31T00:00:00.000Z","2022-02-07T00:00:00.000Z","2022-02-14T00:00:00.000Z","2022-02-21T00:00:00.000Z","2022-02-28T00:00:00.000Z","2022-03-07T00:00:00.000Z","2022-03-14T00:00:00.000Z","2022-03-21T00:00:00.000Z","2022-03-28T00:00:00.000Z","2022-04-04T00:00:00.000Z","2022-04-11T00:00:00.000Z","2022-04-18T00:00:00.000Z","2022-04-25T00:00:00.000Z","2022-05-02T00:00:00.000Z","2022-05-09T00:00:00.000Z","2022-05-16T00:00:00.000Z","2022-05-23T00:00:00.000Z","2022-05-30T00:00:00.000Z","2022-06-06T00:00:00.000Z","2022-06-13T00:00:00.000Z","2022-06-20T00:00:00.000Z","2022-06-27T00:00:00.000Z","2022-07-04T00:00:00.000Z","2022-07-11T00:00:00.000Z","2022-07-18T00:00:00.000Z","2022-07-25T00:00:00.000Z","2022-08-01T00:00:00.000Z","2022-08-08T00:00:00.000Z","2022-08-15T00:00:00.000Z","2022-08-22T00:00:00.000Z","2022-08-29T00:00:00.000Z","2022-09-05T00:00:00.000Z","2022-09-12T00:00:00.000Z","2022-09-19T00:00:00.000Z","2022-09-26T00:00:00.000Z","2022-10-03T00:00:00.000Z","2022-10-10T00:00:00.000Z","2022-10-17T00:00:00.000Z","2022-10-24T00:00:00.000Z","2022-10-31T00:00:00.000Z","2022-11-07T00:00:00.000Z","2022-11-14T00:00:00.000Z","2022-11-21T00:00:00.000Z","2022-11-28T00:00:00.000Z","2022-12-05T00:00:00.000Z","2022-12-12T00:00:00.000Z","2022-12-19T00:00:00.000Z","2022-12-26T00:00:00.000Z","2023-01-02T00:00:00.000Z","2023-01-09T00:00:00.000Z","2023-01-16T00:00:00.000Z","2023-01-23T00:00:00.000Z","2023-01-30T00:00:00.000Z","2023-02-06T00:00:00.000Z","2023-02-13T00:00:00.000Z","2023-02-20T00:00:00.000Z","2023-02-27T00:00:00.000Z","2023-03-06T00:00:00.000Z","2023-03-13T00:00:00.000Z","2023-03-20T00:00:00.000Z","2023-03-27T00:00:00.000Z","2023-04-03T00:00:00.000Z","2023-04-10T00:00:00.000Z","2023-04-17T00:00:00.000Z","2023-04-24T00:00:00.000Z","2023-05-01T00:00:00.000Z","2023-05-08T00:00:00.000Z","2023-05-15T00:00:00.000Z","2023-05-22T00:00:00.000Z","2023-05-29T00:00:00.000Z","2023-06-05T00:00:00.000Z","2023-06-12T00:00:00.000Z","2023-06-19T00:00:00.000Z","2023-06-26T00:00:00.000Z","2023-07-03T00:00:00.000Z","2023-07-10T00:00:00.000Z","2023-07-17T00:00:00.000Z","2023-07-24T00:00:00.000Z","2023-07-31T00:00:00.000Z","2023-08-07T00:00:00.000Z","2023-08-14T00:00:00.000Z","2023-08-21T00:00:00.000Z","2023-08-28T00:00:00.000Z","2023-09-04T00:00:00.000Z","2023-09-11T00:00:00.000Z","2023-09-18T00:00:00.000Z","2023-09-25T00:00:00.000Z","2023-10-02T00:00:00.000Z","2023-10-09T00:00:00.000Z","2023-10-16T00:00:00.000Z","2023-10-23T00:00:00.000Z","2023-10-30T00:00:00.000Z","2023-11-06T00:00:00.000Z","2023-11-13T00:00:00.000Z","2023-11-20T00:00:00.000Z","2023-11-27T00:00:00.000Z","2023-12-04T00:00:00.000Z","2023-12-11T00:00:00.000Z","2023-12-18T00:00:00.000Z"],[0.01,0.01,0.01,0.02,0.01,0.02,0.02,0.02,0.04,0.03,0.02,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.04,0.04,0.06,0.08,0.08,0.08,0.09,0.1,0.08,0.1,0.08,0.05,0.05,0.03,0.02,0.01,0.02,0.01,0.01,0.02,0.02,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.03,0.04,0.03,0.04,0.04,0.03,0.04,0.03,0.02,0.02,0.02,0.02,0.02,0.01,0.02,0.02,0.01,0.02,0.01,0.02,0.03,0.05,0.17,0.39,0.37,0.32,0.25,0.14,0.12,0.06,0.04,0.03,0.04,0.02,0.01,0.01,0.01,0.02,0.03,0.03,0.03,0.03,0.04,0.05,0.04,0.09,0.06,0.05,0.06,0.05,0.05,0.05,0.04,0.05,0.04,0.03,0.02,0.02,0.01,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.02,0.03,0.02,0.03,0.04,0.02,0.02,0.02,0.01,0.01,0.01,0.02,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.02,0.02,0.02,0.04,0.03,0.02,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01]]},"evals":[],"jsHooks":[]}</script>

<br>

``` r
dygraphs::dygraph(
  data = cbind(tsl$Napa, tsl$Butte, tsl$Kings), 
  ylab = "Covid-19 Prevalence"
  )
```

<div class="dygraphs html-widget html-fill-item" id="htmlwidget-2" style="width:768px;height:192px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"attrs":{"ylabel":"Covid-19 Prevalence","labels":["week","prevalence.tsl$Napa","prevalence.tsl$Butte","prevalence.tsl$Kings"],"legend":"auto","retainDateWindow":false,"axes":{"x":{"pixelsPerLabel":60}}},"scale":"weekly","annotations":[],"shadings":[],"events":[],"format":"date","data":[["2020-03-16T00:00:00.000Z","2020-03-23T00:00:00.000Z","2020-03-30T00:00:00.000Z","2020-04-06T00:00:00.000Z","2020-04-13T00:00:00.000Z","2020-04-20T00:00:00.000Z","2020-04-27T00:00:00.000Z","2020-05-04T00:00:00.000Z","2020-05-11T00:00:00.000Z","2020-05-18T00:00:00.000Z","2020-05-25T00:00:00.000Z","2020-06-01T00:00:00.000Z","2020-06-08T00:00:00.000Z","2020-06-15T00:00:00.000Z","2020-06-22T00:00:00.000Z","2020-06-29T00:00:00.000Z","2020-07-06T00:00:00.000Z","2020-07-13T00:00:00.000Z","2020-07-20T00:00:00.000Z","2020-07-27T00:00:00.000Z","2020-08-03T00:00:00.000Z","2020-08-10T00:00:00.000Z","2020-08-17T00:00:00.000Z","2020-08-24T00:00:00.000Z","2020-08-31T00:00:00.000Z","2020-09-07T00:00:00.000Z","2020-09-14T00:00:00.000Z","2020-09-21T00:00:00.000Z","2020-09-28T00:00:00.000Z","2020-10-05T00:00:00.000Z","2020-10-12T00:00:00.000Z","2020-10-19T00:00:00.000Z","2020-10-26T00:00:00.000Z","2020-11-02T00:00:00.000Z","2020-11-09T00:00:00.000Z","2020-11-16T00:00:00.000Z","2020-11-23T00:00:00.000Z","2020-11-30T00:00:00.000Z","2020-12-07T00:00:00.000Z","2020-12-14T00:00:00.000Z","2020-12-21T00:00:00.000Z","2020-12-28T00:00:00.000Z","2021-01-04T00:00:00.000Z","2021-01-11T00:00:00.000Z","2021-01-18T00:00:00.000Z","2021-01-25T00:00:00.000Z","2021-02-01T00:00:00.000Z","2021-02-08T00:00:00.000Z","2021-02-15T00:00:00.000Z","2021-02-22T00:00:00.000Z","2021-03-01T00:00:00.000Z","2021-03-08T00:00:00.000Z","2021-03-15T00:00:00.000Z","2021-03-22T00:00:00.000Z","2021-03-29T00:00:00.000Z","2021-04-05T00:00:00.000Z","2021-04-12T00:00:00.000Z","2021-04-19T00:00:00.000Z","2021-04-26T00:00:00.000Z","2021-05-03T00:00:00.000Z","2021-05-10T00:00:00.000Z","2021-05-17T00:00:00.000Z","2021-05-24T00:00:00.000Z","2021-05-31T00:00:00.000Z","2021-06-07T00:00:00.000Z","2021-06-14T00:00:00.000Z","2021-06-21T00:00:00.000Z","2021-06-28T00:00:00.000Z","2021-07-05T00:00:00.000Z","2021-07-12T00:00:00.000Z","2021-07-19T00:00:00.000Z","2021-07-26T00:00:00.000Z","2021-08-02T00:00:00.000Z","2021-08-09T00:00:00.000Z","2021-08-16T00:00:00.000Z","2021-08-23T00:00:00.000Z","2021-08-30T00:00:00.000Z","2021-09-06T00:00:00.000Z","2021-09-13T00:00:00.000Z","2021-09-20T00:00:00.000Z","2021-09-27T00:00:00.000Z","2021-10-04T00:00:00.000Z","2021-10-11T00:00:00.000Z","2021-10-18T00:00:00.000Z","2021-10-25T00:00:00.000Z","2021-11-01T00:00:00.000Z","2021-11-08T00:00:00.000Z","2021-11-15T00:00:00.000Z","2021-11-22T00:00:00.000Z","2021-11-29T00:00:00.000Z","2021-12-06T00:00:00.000Z","2021-12-13T00:00:00.000Z","2021-12-20T00:00:00.000Z","2021-12-27T00:00:00.000Z","2022-01-03T00:00:00.000Z","2022-01-10T00:00:00.000Z","2022-01-17T00:00:00.000Z","2022-01-24T00:00:00.000Z","2022-01-31T00:00:00.000Z","2022-02-07T00:00:00.000Z","2022-02-14T00:00:00.000Z","2022-02-21T00:00:00.000Z","2022-02-28T00:00:00.000Z","2022-03-07T00:00:00.000Z","2022-03-14T00:00:00.000Z","2022-03-21T00:00:00.000Z","2022-03-28T00:00:00.000Z","2022-04-04T00:00:00.000Z","2022-04-11T00:00:00.000Z","2022-04-18T00:00:00.000Z","2022-04-25T00:00:00.000Z","2022-05-02T00:00:00.000Z","2022-05-09T00:00:00.000Z","2022-05-16T00:00:00.000Z","2022-05-23T00:00:00.000Z","2022-05-30T00:00:00.000Z","2022-06-06T00:00:00.000Z","2022-06-13T00:00:00.000Z","2022-06-20T00:00:00.000Z","2022-06-27T00:00:00.000Z","2022-07-04T00:00:00.000Z","2022-07-11T00:00:00.000Z","2022-07-18T00:00:00.000Z","2022-07-25T00:00:00.000Z","2022-08-01T00:00:00.000Z","2022-08-08T00:00:00.000Z","2022-08-15T00:00:00.000Z","2022-08-22T00:00:00.000Z","2022-08-29T00:00:00.000Z","2022-09-05T00:00:00.000Z","2022-09-12T00:00:00.000Z","2022-09-19T00:00:00.000Z","2022-09-26T00:00:00.000Z","2022-10-03T00:00:00.000Z","2022-10-10T00:00:00.000Z","2022-10-17T00:00:00.000Z","2022-10-24T00:00:00.000Z","2022-10-31T00:00:00.000Z","2022-11-07T00:00:00.000Z","2022-11-14T00:00:00.000Z","2022-11-21T00:00:00.000Z","2022-11-28T00:00:00.000Z","2022-12-05T00:00:00.000Z","2022-12-12T00:00:00.000Z","2022-12-19T00:00:00.000Z","2022-12-26T00:00:00.000Z","2023-01-02T00:00:00.000Z","2023-01-09T00:00:00.000Z","2023-01-16T00:00:00.000Z","2023-01-23T00:00:00.000Z","2023-01-30T00:00:00.000Z","2023-02-06T00:00:00.000Z","2023-02-13T00:00:00.000Z","2023-02-20T00:00:00.000Z","2023-02-27T00:00:00.000Z","2023-03-06T00:00:00.000Z","2023-03-13T00:00:00.000Z","2023-03-20T00:00:00.000Z","2023-03-27T00:00:00.000Z","2023-04-03T00:00:00.000Z","2023-04-10T00:00:00.000Z","2023-04-17T00:00:00.000Z","2023-04-24T00:00:00.000Z","2023-05-01T00:00:00.000Z","2023-05-08T00:00:00.000Z","2023-05-15T00:00:00.000Z","2023-05-22T00:00:00.000Z","2023-05-29T00:00:00.000Z","2023-06-05T00:00:00.000Z","2023-06-12T00:00:00.000Z","2023-06-19T00:00:00.000Z","2023-06-26T00:00:00.000Z","2023-07-03T00:00:00.000Z","2023-07-10T00:00:00.000Z","2023-07-17T00:00:00.000Z","2023-07-24T00:00:00.000Z","2023-07-31T00:00:00.000Z","2023-08-07T00:00:00.000Z","2023-08-14T00:00:00.000Z","2023-08-21T00:00:00.000Z","2023-08-28T00:00:00.000Z","2023-09-04T00:00:00.000Z","2023-09-11T00:00:00.000Z","2023-09-18T00:00:00.000Z","2023-09-25T00:00:00.000Z","2023-10-02T00:00:00.000Z","2023-10-09T00:00:00.000Z","2023-10-16T00:00:00.000Z","2023-10-23T00:00:00.000Z","2023-10-30T00:00:00.000Z","2023-11-06T00:00:00.000Z","2023-11-13T00:00:00.000Z","2023-11-20T00:00:00.000Z","2023-11-27T00:00:00.000Z","2023-12-04T00:00:00.000Z","2023-12-11T00:00:00.000Z","2023-12-18T00:00:00.000Z"],[0.01,0.01,0.01,0.02,0.01,0.02,0.02,0.02,0.04,0.03,0.02,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.04,0.04,0.06,0.08,0.08,0.08,0.09,0.1,0.08,0.1,0.08,0.05,0.05,0.03,0.02,0.01,0.02,0.01,0.01,0.02,0.02,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.03,0.04,0.03,0.04,0.04,0.03,0.04,0.03,0.02,0.02,0.02,0.02,0.02,0.01,0.02,0.02,0.01,0.02,0.01,0.02,0.03,0.05,0.17,0.39,0.37,0.32,0.25,0.14,0.12,0.06,0.04,0.03,0.04,0.02,0.01,0.01,0.01,0.02,0.03,0.03,0.03,0.03,0.04,0.05,0.04,0.09,0.06,0.05,0.06,0.05,0.05,0.05,0.04,0.05,0.04,0.03,0.02,0.02,0.01,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.02,0.03,0.02,0.03,0.04,0.02,0.02,0.02,0.01,0.01,0.01,0.02,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.02,0.02,0.02,0.04,0.03,0.02,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01],[0.01,0.01,0.02,0.03,0.02,0.02,0.02,0.02,0.02,0.05,0.04,0.03,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.02,0.05,0.07000000000000001,0.07000000000000001,0.09,0.07000000000000001,0.09,0.07000000000000001,0.05,0.04,0.03,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.04,0.04,0.06,0.06,0.08,0.07000000000000001,0.09,0.06,0.04,0.03,0.04,0.04,0.04,0.03,0.02,0.02,0.02,0.02,0.02,0.01,0.03,0.07000000000000001,0.16,0.18,0.18,0.18,0.11,0.08,0.04,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.03,0.03,0.03,0.04,0.04,0.04,0.03,0.03,0.05,0.03,0.03,0.03,0.03,0.02,0.02,0.02,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.03,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.03,0.02,0.02,0.02,0.02,0.02,0.05,0.04,0.03,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.02,0.05,0.07000000000000001,0.07000000000000001,0.09,0.07000000000000001,0.09,0.07000000000000001,0.05,0.04,0.03,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.01],[0.01,0.02,0.01,0.01,0.03,0.09,0.22,0.17,0.05,0.05,0.04,0.05,0.04,0.11,0.07000000000000001,0.16,0.07000000000000001,0.12,0.11,0.1,0.17,0.08,0.1,0.07000000000000001,0.09,0.06,0.01,0.16,0.1,0.1,0.12,0.17,0.27,0.23,0.18,0.14,0.16,0.18,0.18,0.17,0.11,0.08,0.06,0.04,0.03,0.02,0.03,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.03,0.06,0.07000000000000001,0.09,0.1,0.1,0.09,0.09,0.08,0.07000000000000001,0.07000000000000001,0.06,0.07000000000000001,0.08,0.06,0.06,0.04,0.03,0.05,0.04,0.03,0.04,0.1,0.21,0.43,0.4,0.73,0.37,0.23,0.12,0.07000000000000001,0.04,0.04,0.03,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.04,0.04,0.04,0.06,0.05,0.06,0.07000000000000001,0.06,0.11,0.1,0.08,0.09,0.06,0.04,0.05,0.04,0.04,0.04,0.02,0.01,0.01,0.01,0.01,0.01,0.04,0.03,0.03,0.05,0.05,0.04,0.04,0.03,0.03,0.03,0.03,0.02,0.02,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.02,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.02,0.01,0.01,0.03,0.09,0.22,0.17,0.05,0.05,0.04,0.05,0.04,0.11,0.07000000000000001,0.16]]},"evals":[],"jsHooks":[]}</script>

<br>

On the other hand, `distantia::tsl_plot()` facilitates a fast visual exploration of a larger number of time series at once.

``` r
distantia::tsl_plot(
  tsl = tsl[1:12],
  columns = 2,
  guide = FALSE,
  text_cex = 1.2
)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-11-1.png" width="768" />

Combined with `tsl_subset()`, it can provide a more focused view of particular elements of the data, such as specific counties and time periods.

``` r
distantia::tsl_plot(
  tsl = tsl_subset(
    tsl = tsl,
    names = c("Los_Angeles", "Kings"),
    time = c("2021-09-01", "2022-01-31")
  ),
  guide = FALSE
)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-12-1.png" width="768" />

## Data Exploration

Time summary

``` r
df_time <- tsl_time(
  tsl = tsl
)
```

<div id="vejjgfomka" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#vejjgfomka table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#vejjgfomka thead, #vejjgfomka tbody, #vejjgfomka tfoot, #vejjgfomka tr, #vejjgfomka td, #vejjgfomka th {
  border-style: none;
}
&#10;#vejjgfomka p {
  margin: 0;
  padding: 0;
}
&#10;#vejjgfomka .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#vejjgfomka .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#vejjgfomka .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#vejjgfomka .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#vejjgfomka .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#vejjgfomka .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#vejjgfomka .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#vejjgfomka .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#vejjgfomka .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#vejjgfomka .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#vejjgfomka .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#vejjgfomka .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#vejjgfomka .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#vejjgfomka .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#vejjgfomka .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vejjgfomka .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#vejjgfomka .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#vejjgfomka .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#vejjgfomka .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vejjgfomka .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#vejjgfomka .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vejjgfomka .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#vejjgfomka .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vejjgfomka .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#vejjgfomka .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vejjgfomka .gt_left {
  text-align: left;
}
&#10;#vejjgfomka .gt_center {
  text-align: center;
}
&#10;#vejjgfomka .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#vejjgfomka .gt_font_normal {
  font-weight: normal;
}
&#10;#vejjgfomka .gt_font_bold {
  font-weight: bold;
}
&#10;#vejjgfomka .gt_font_italic {
  font-style: italic;
}
&#10;#vejjgfomka .gt_super {
  font-size: 65%;
}
&#10;#vejjgfomka .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#vejjgfomka .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#vejjgfomka .gt_indent_1 {
  text-indent: 5px;
}
&#10;#vejjgfomka .gt_indent_2 {
  text-indent: 10px;
}
&#10;#vejjgfomka .gt_indent_3 {
  text-indent: 15px;
}
&#10;#vejjgfomka .gt_indent_4 {
  text-indent: 20px;
}
&#10;#vejjgfomka .gt_indent_5 {
  text-indent: 25px;
}
&#10;#vejjgfomka .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#vejjgfomka div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="name">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="class">class</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="units">units</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="length">length</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="resolution">resolution</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="begin">begin</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="end">end</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="class" class="gt_row gt_left" style="font-family: Montserrat;">Date</td>
<td headers="units" class="gt_row gt_left" style="font-family: Montserrat;">days</td>
<td headers="length" class="gt_row gt_right" style="font-family: Montserrat;">1372</td>
<td headers="resolution" class="gt_row gt_right" style="font-family: Montserrat;">7</td>
<td headers="begin" class="gt_row gt_right" style="font-family: Montserrat;">2020-03-16</td>
<td headers="end" class="gt_row gt_right" style="font-family: Montserrat;">2023-12-18</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="class" class="gt_row gt_left" style="font-family: Montserrat;">Date</td>
<td headers="units" class="gt_row gt_left" style="font-family: Montserrat;">days</td>
<td headers="length" class="gt_row gt_right" style="font-family: Montserrat;">1372</td>
<td headers="resolution" class="gt_row gt_right" style="font-family: Montserrat;">7</td>
<td headers="begin" class="gt_row gt_right" style="font-family: Montserrat;">2020-03-16</td>
<td headers="end" class="gt_row gt_right" style="font-family: Montserrat;">2023-12-18</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="class" class="gt_row gt_left" style="font-family: Montserrat;">Date</td>
<td headers="units" class="gt_row gt_left" style="font-family: Montserrat;">days</td>
<td headers="length" class="gt_row gt_right" style="font-family: Montserrat;">1372</td>
<td headers="resolution" class="gt_row gt_right" style="font-family: Montserrat;">7</td>
<td headers="begin" class="gt_row gt_right" style="font-family: Montserrat;">2020-03-16</td>
<td headers="end" class="gt_row gt_right" style="font-family: Montserrat;">2023-12-18</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="class" class="gt_row gt_left" style="font-family: Montserrat;">Date</td>
<td headers="units" class="gt_row gt_left" style="font-family: Montserrat;">days</td>
<td headers="length" class="gt_row gt_right" style="font-family: Montserrat;">1372</td>
<td headers="resolution" class="gt_row gt_right" style="font-family: Montserrat;">7</td>
<td headers="begin" class="gt_row gt_right" style="font-family: Montserrat;">2020-03-16</td>
<td headers="end" class="gt_row gt_right" style="font-family: Montserrat;">2023-12-18</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="class" class="gt_row gt_left" style="font-family: Montserrat;">Date</td>
<td headers="units" class="gt_row gt_left" style="font-family: Montserrat;">days</td>
<td headers="length" class="gt_row gt_right" style="font-family: Montserrat;">1372</td>
<td headers="resolution" class="gt_row gt_right" style="font-family: Montserrat;">7</td>
<td headers="begin" class="gt_row gt_right" style="font-family: Montserrat;">2020-03-16</td>
<td headers="end" class="gt_row gt_right" style="font-family: Montserrat;">2023-12-18</td></tr>
  </tbody>
  &#10;  
</table>
</div>

Time series stats ordered from max prevalence.

``` r
df_stats <- tsl_stats(
  tsl = tsl,
  lags = 1:12 #weeks
)
```

<div id="dfpjhwbiwx" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#dfpjhwbiwx table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#dfpjhwbiwx thead, #dfpjhwbiwx tbody, #dfpjhwbiwx tfoot, #dfpjhwbiwx tr, #dfpjhwbiwx td, #dfpjhwbiwx th {
  border-style: none;
}
&#10;#dfpjhwbiwx p {
  margin: 0;
  padding: 0;
}
&#10;#dfpjhwbiwx .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#dfpjhwbiwx .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#dfpjhwbiwx .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#dfpjhwbiwx .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#dfpjhwbiwx .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#dfpjhwbiwx .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#dfpjhwbiwx .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#dfpjhwbiwx .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#dfpjhwbiwx .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#dfpjhwbiwx .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#dfpjhwbiwx .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#dfpjhwbiwx .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#dfpjhwbiwx .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#dfpjhwbiwx .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#dfpjhwbiwx .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dfpjhwbiwx .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#dfpjhwbiwx .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#dfpjhwbiwx .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#dfpjhwbiwx .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dfpjhwbiwx .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#dfpjhwbiwx .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dfpjhwbiwx .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#dfpjhwbiwx .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dfpjhwbiwx .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#dfpjhwbiwx .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#dfpjhwbiwx .gt_left {
  text-align: left;
}
&#10;#dfpjhwbiwx .gt_center {
  text-align: center;
}
&#10;#dfpjhwbiwx .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#dfpjhwbiwx .gt_font_normal {
  font-weight: normal;
}
&#10;#dfpjhwbiwx .gt_font_bold {
  font-weight: bold;
}
&#10;#dfpjhwbiwx .gt_font_italic {
  font-style: italic;
}
&#10;#dfpjhwbiwx .gt_super {
  font-size: 65%;
}
&#10;#dfpjhwbiwx .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#dfpjhwbiwx .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#dfpjhwbiwx .gt_indent_1 {
  text-indent: 5px;
}
&#10;#dfpjhwbiwx .gt_indent_2 {
  text-indent: 10px;
}
&#10;#dfpjhwbiwx .gt_indent_3 {
  text-indent: 15px;
}
&#10;#dfpjhwbiwx .gt_indent_4 {
  text-indent: 20px;
}
&#10;#dfpjhwbiwx .gt_indent_5 {
  text-indent: 25px;
}
&#10;#dfpjhwbiwx .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#dfpjhwbiwx div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="name">name</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="q1">q1</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="median">median</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="q3">q3</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="max">max</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="ac_lag_1">ac_lag_1</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.08</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.73</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.80</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.59</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.48</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.47</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.06</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.44</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.05</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.41</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.41</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.93</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.40</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.39</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.05</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.37</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.37</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.37</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.36</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.36</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.93</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.36</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.35</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.35</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.34</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.05</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.33</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.33</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.33</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.32</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.32</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.31</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.30</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.30</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.28</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.88</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.04</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.28</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.27</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.25</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.25</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.91</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.05</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.24</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.92</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.23</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.89</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.19</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.03</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.18</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
    <tr><td headers="name" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="q1" class="gt_row gt_right" style="font-family: Montserrat;">0.01</td>
<td headers="median" class="gt_row gt_right" style="font-family: Montserrat;">0.02</td>
<td headers="q3" class="gt_row gt_right" style="font-family: Montserrat;">0.05</td>
<td headers="max" class="gt_row gt_right" style="font-family: Montserrat;">0.16</td>
<td headers="ac_lag_1" class="gt_row gt_right" style="font-family: Montserrat;">0.90</td></tr>
  </tbody>
  &#10;  
</table>
</div>

Computation of time series dissimilarity with dynamic time warping, and restricted permutation test with a block size of 12 weeks to assess significance.

``` r
future::plan(
  strategy = future::multisession,
  workers = future::availableCores() - 1
)

df_psi_dtw <- distantia(
  tsl = tsl,
  distance = "euclidean",
  permutation = "restricted",
  block_size = 12, #3 months, one season
  repetitions = 1000
)

df_psi_ls <- distantia(
  tsl = tsl,
  lock_step = TRUE,
  distance = "euclidean",
  permutation = "restricted",
  block_size = 12, #3 months, one season
  repetitions = 1000
)
```

``` r
save(df_psi_dtw, df_psi_ls, file = "distantia_output.RData")
```

<div id="pylutjjzdn" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#pylutjjzdn table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#pylutjjzdn thead, #pylutjjzdn tbody, #pylutjjzdn tfoot, #pylutjjzdn tr, #pylutjjzdn td, #pylutjjzdn th {
  border-style: none;
}
&#10;#pylutjjzdn p {
  margin: 0;
  padding: 0;
}
&#10;#pylutjjzdn .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#pylutjjzdn .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#pylutjjzdn .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#pylutjjzdn .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#pylutjjzdn .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#pylutjjzdn .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#pylutjjzdn .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#pylutjjzdn .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#pylutjjzdn .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#pylutjjzdn .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#pylutjjzdn .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#pylutjjzdn .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#pylutjjzdn .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#pylutjjzdn .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#pylutjjzdn .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#pylutjjzdn .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#pylutjjzdn .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#pylutjjzdn .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#pylutjjzdn .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#pylutjjzdn .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#pylutjjzdn .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#pylutjjzdn .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#pylutjjzdn .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#pylutjjzdn .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#pylutjjzdn .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#pylutjjzdn .gt_left {
  text-align: left;
}
&#10;#pylutjjzdn .gt_center {
  text-align: center;
}
&#10;#pylutjjzdn .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#pylutjjzdn .gt_font_normal {
  font-weight: normal;
}
&#10;#pylutjjzdn .gt_font_bold {
  font-weight: bold;
}
&#10;#pylutjjzdn .gt_font_italic {
  font-style: italic;
}
&#10;#pylutjjzdn .gt_super {
  font-size: 65%;
}
&#10;#pylutjjzdn .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#pylutjjzdn .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#pylutjjzdn .gt_indent_1 {
  text-indent: 5px;
}
&#10;#pylutjjzdn .gt_indent_2 {
  text-indent: 10px;
}
&#10;#pylutjjzdn .gt_indent_3 {
  text-indent: 15px;
}
&#10;#pylutjjzdn .gt_indent_4 {
  text-indent: 20px;
}
&#10;#pylutjjzdn .gt_indent_5 {
  text-indent: 25px;
}
&#10;#pylutjjzdn .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#pylutjjzdn div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="x">x</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="y">y</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="psi">psi</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="p_value">p_value</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.352</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.364</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.371</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.375</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.375</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.397</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.405</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.411</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.414</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.415</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.419</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.425</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.427</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.433</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.442</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.446</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.471</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.478</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.485</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.493</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.495</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.500</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.516</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.516</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.519</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.535</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.538</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.543</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.545</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.547</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.547</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.548</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.551</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.559</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.559</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.560</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.568</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.570</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.571</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.573</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.574</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.575</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.583</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.584</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.589</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.593</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.593</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.608</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.609</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.610</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.611</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.613</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.624</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.629</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.630</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.632</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.632</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.645</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.646</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.648</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.652</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.658</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.658</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.661</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.661</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.662</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.665</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.669</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.671</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.672</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.674</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.677</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.679</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.687</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.689</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.692</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.694</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.698</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.699</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.700</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.701</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.702</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.705</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.713</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.713</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.715</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.716</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.717</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.723</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.726</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.726</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.727</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.730</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.730</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.731</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.733</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.735</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.738</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.738</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.739</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.739</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.739</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.742</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.744</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.744</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.745</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.747</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.747</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.749</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.751</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.754</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.757</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.759</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.761</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.761</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.762</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.763</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.764</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.769</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.771</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.774</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.784</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.784</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.785</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.788</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.794</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.799</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.800</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.805</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.805</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.810</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.813</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.814</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.816</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.820</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.824</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.826</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.829</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.830</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.831</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.832</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.833</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.834</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.836</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.837</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.838</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.838</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.839</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.840</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.844</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.845</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.847</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.854</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.856</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.858</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.859</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.859</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.861</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.862</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.866</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.868</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.868</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.871</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.871</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.872</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.876</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.876</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.878</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.879</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.881</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.883</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.887</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.888</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.891</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.892</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.892</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.896</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.898</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.898</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.898</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.900</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.904</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.905</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.910</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.911</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.913</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.915</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.918</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.920</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.921</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.924</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.931</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.935</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.941</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.945</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.946</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.948</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.949</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.951</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.953</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.953</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.954</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.955</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.955</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.955</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.958</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.958</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.966</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.970</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.974</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.975</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.977</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.977</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.979</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.981</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.982</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.982</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.982</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.982</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.983</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.984</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.989</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.991</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.991</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.992</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.992</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.994</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">0.996</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.000</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.000</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.003</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.003</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.003</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.003</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.004</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.005</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.007</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.008</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.011</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.011</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.014</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.014</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.016</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.018</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.019</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.019</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.020</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.022</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.022</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.023</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.027</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.027</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.028</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.028</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.028</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.029</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.030</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.031</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.031</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.034</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.035</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.036</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.037</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.040</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.043</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.043</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.044</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.046</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.046</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.048</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.049</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.050</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.052</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.052</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.054</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.055</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.059</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.061</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.061</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.061</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.062</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.065</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.068</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.068</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.068</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.071</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.073</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.074</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.075</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.079</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.080</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.081</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.086</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.086</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.088</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.088</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.095</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.100</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.100</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.103</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.104</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.105</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.105</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.107</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.108</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.108</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.109</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.113</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.113</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.116</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.117</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.118</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.119</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.120</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.122</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.123</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.124</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.125</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.126</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.126</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.128</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.129</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.130</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.132</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.134</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.135</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.136</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.136</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.137</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.137</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.138</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.138</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.138</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.139</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.141</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.142</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.143</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.150</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.152</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.153</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.156</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.157</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.157</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.158</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.159</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.163</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.164</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.166</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.167</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.167</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.171</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.171</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.172</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.172</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.174</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.175</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.175</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.176</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.178</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.180</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.180</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.181</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.182</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.184</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.188</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.189</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.190</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.191</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.191</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.193</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.193</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.194</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.194</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.196</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.196</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.197</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.199</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.200</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.200</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.202</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.203</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.204</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.204</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.206</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.208</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.208</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.209</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.209</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.210</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.212</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.213</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.214</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.215</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.215</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.218</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.220</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.224</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.226</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.226</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.227</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.227</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.227</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.231</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.233</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.237</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.239</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.242</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.242</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.243</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.244</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.244</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.246</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.249</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.249</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.250</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.251</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.252</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.254</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.258</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.260</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.262</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.262</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.263</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.264</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.265</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.265</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.268</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.269</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.269</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.270</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.271</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.272</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.273</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.275</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.275</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.278</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.280</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.280</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.287</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.289</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.289</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.291</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.291</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.295</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.298</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.299</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.299</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.300</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.301</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.304</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.306</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.307</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.319</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.321</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.323</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.324</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.324</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.325</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.326</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.327</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.333</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.333</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.338</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.338</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.338</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.348</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.348</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.348</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.359</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.359</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.359</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.360</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.360</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.360</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.362</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.363</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.363</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.364</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.364</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.368</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.369</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.372</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.374</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.375</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.376</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.376</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.382</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.384</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Barbara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.386</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.388</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.389</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.390</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.392</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.395</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.395</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.399</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.400</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.401</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.403</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.405</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.408</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.410</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.410</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.411</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.412</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.415</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.416</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.418</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.418</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.422</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.423</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.427</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.434</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.434</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.435</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.436</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.437</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.438</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.440</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.444</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.447</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.450</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.451</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.453</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.455</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.456</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.457</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.459</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.462</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.469</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.471</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.475</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.477</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.478</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.479</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.481</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.482</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.488</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Napa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.490</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Cruz</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.491</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.492</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.493</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.495</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.496</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.496</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.498</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.498</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.503</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.505</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.506</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.507</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Luis_Obispo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.507</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.508</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Madera</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.509</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.513</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.519</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.521</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Joaquin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.524</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.525</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.529</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.534</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.535</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.535</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.539</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.540</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.547</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.548</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.548</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.559</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.560</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.566</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.567</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Tulare</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.580</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.582</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Fresno</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.583</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.593</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Merced</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.597</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.600</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.602</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Yolo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.605</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.607</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.612</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.615</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.623</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Ventura</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.632</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.640</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.641</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.646</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.652</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.652</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.657</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.657</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Orange</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.659</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.667</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kern</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.690</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.711</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.720</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Santa_Clara</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.724</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Stanislaus</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.733</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.747</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.761</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Diego</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.762</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Solano</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.766</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sutter</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.780</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.781</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.788</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">El_Dorado</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.793</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.793</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.811</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.816</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.824</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Sonoma</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.843</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.853</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Imperial</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.864</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Kings</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.864</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.048</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.885</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Sacramento</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.888</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Riverside</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.935</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.002</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Monterey</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">1.949</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.003</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Alameda</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.034</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.059</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Francisco</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.066</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Contra_Costa</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.079</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Mateo</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.095</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Butte</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.100</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.145</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Los_Angeles</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">Shasta</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.173</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Marin</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.337</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.004</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Humboldt</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.384</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
    <tr><td headers="x" class="gt_row gt_left" style="font-family: Montserrat;">Placer</td>
<td headers="y" class="gt_row gt_left" style="font-family: Montserrat;">San_Bernardino</td>
<td headers="psi" class="gt_row gt_right" style="font-family: Montserrat;">2.390</td>
<td headers="p_value" class="gt_row gt_right" style="font-family: Montserrat;">0.001</td></tr>
  </tbody>
  &#10;  
</table>
</div>

The p-value represents the probability of finding a lower psi (higher similarity) when the time series are permuted. Low p-values indicate a strong similarity, better than expected by chance.
