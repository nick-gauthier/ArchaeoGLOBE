---
title: "ArchaeoGLOBE trend analysis"
author: "Nick Gauthier"
date: "Last knit on: 15 October, 2018"
output: 
  html_document: 
    highlight: pygments
    keep_md: yes
    theme: cosmo
  pdf_document: 
    highlight: pygments
    latex_engine: lualatex
---


Sample analysis code for the ArchaeoGlobe database. Here we fit Generalized Additive Models (GAMs), a flexible form of nonlinear regression model capable of fitting smooth, time-varying trends to the ordered categorical ArchaeoGLOBE response data.

We model ordered categorical data using a latent variable following a logistic distribution. The model identifies a series of cut points, which correspond the the probabilities of the latent variable falling within each of our categories.

We fit two sets of trends. One trend is fitted to all the data simultaneously, representing the global trend across all archaeological regions. Then we fit region-level trends, which represent the deviation of each region from the global trend. By penalizing the "wiggliness" of the trend lines, we allow regional trends that don't significantly deviate from the global trend to be penalized to 0, effectively reducing that particular region to the global trend. This is a form of partial pooling, allowing the model to share information between groups and in so doing make the results less sensitive to regions with exceptionally low response rates.

After fitting the model, we can extract the region-specific diviations from the global trend, use a k-means clustering alogirithm to group together regions with similar trends, and map the results. We repeat this analysis for both self-reported expertise and perceived data quality.

# Setup

Import packages needed for analysis. We'll use packages from the `tidyverse`, such as `readr`, `dplyr`, and `ggplot2` for data import, processing, and plotting. We'll also use `mgcv` for fitting nonlinear trends to the data. We'll use the `sf` package to help us plot shapefiles in a tidy context. Finally, we'll use `patchwork` to combine multiple ggplots in the same image.


```r
library(tidyverse)
library(mgcv)
library(sf)

#install patchwork from github 
#devtools::install_github('thomasp85/patchwork')
library(patchwork)
```

## Data import

Read in the latest version of the ArchaeoGLOBE database and the regions shapefile.


```r
archaeoglobe <- read_csv('data/Survey_scrubbed_Aug20_IDs.csv')
regions <- st_read('data/Simplified_Regions2.shp', quiet = TRUE)
```

## Analysis functions

Define some analysis functions that we'll be using repeatedly in the analysis, so that we don't have to keep copying and pasting the same lines of code.

This function subsets the data to highlight a variable of interest, and converts it from a wide to a long "tidy" format to make analysis and plotting easier.


```r
preprocess <- function(prefix, categories){
  archaeoglobe %>% # start with the full ArcheoGlobe data
    # drop columns not related to the variable of interest
    select(c(CONTRIBUTR:LAND_AREA, starts_with(prefix))) %>%
    gather(time, value, starts_with(prefix)) %>% # one value per row
    mutate(time = parse_number(time) * -1, # convert time period labels to years
           value = ordered(value, levels = categories),
           cat_num = as.numeric(value)) %>%
    mutate_if(is.character, as.factor) # convert characters to factors
}
```

This function takes a data frame produced by the above function and fits GAM to the global trend and local deviations for each region, accounting for inter-observer variability. This function takes as arguments a preprocessed data frame containing time slices, regions, contributors, and the ordered categorical response variable transformed to a numeric vector. 


```r
fit_model <- function(x, n_cats){
  bam(cat_num ~ 
        # this spline is for the global trend
        s(time, bs = 'cr', m = 2) + 
        # region-specific trends. bs = 'ts' and m = 1 
        # help penalize deviation from the global model
        s(time, by = REGION_LAB, bs = 'cs', m = 1) + 
        # add back in region-specific intercepts
        REGION_LAB +
        # model contributor as a random effect
        s(CONTRIBUTR, bs = 're', k = 252),
      data = x, # data frame to analyize
      family = ocat(R = n_cats), # ordered categorical with n levels
      # final 3 arguments just speed up the model fitting
      method = 'fREML',
      discrete = TRUE,
      nthreads = 2)
}
```

This function extracts the fitted splines for each region, ignoring factors such as the global trend and region and contributor specific intercepts so that the focus is on the shape of the local trends. Then it clusters these local deviations from the global trend into discrete clusters.


```r
extract_trends <-function(mod, n_clusters = 6){
  set.seed(1000)
  mod %>%
  plot(select = 0, n = 25) %>% # plot for the side effect of printing smoothed fits
  .[2:147] %>% # extract the local trends
  map(~tibble(region =.$ylab, time = .$x, fit = c(.$fit))) %>% 
  bind_rows %>%
  mutate(fit = plogis(fit)) %>%
  spread(time, fit) %>%
  mutate(cluster = kmeans(.[,-1], n_clusters, iter.max = 100, nstart = 100)$cluster)
}
```

# Analysis

Now we use the functions defined above on the ArchaeoGlobe data. For convenience, first define a data frame that lists the prefixes of the variables we are interested in (e.g. "EXP" for expertise) and the levels of the ordered factors associated with each variable. This will make it easier to quickly focus on a specific variable. The `tribble` command is simply a way to make a data frame by row rather than column, which makes the code easier to read.


```r
response_levels <- tribble(
  ~prefix, ~categories,
  'EXP', c('None', 'Low', 'High'),
  'DQ', c('Unknown', 'Low', 'Moderate', 'Good'),
  'HUNT', c('none', 'minimal (<1%)', 'common (1-20%)', 'widespread (>20%)'),
  'EXAG', c('none', 'minimal (<1%)', 'common (1-20%)', 'widespread (>20%)'),
  'INAG', c('none', 'minimal (<1%)', 'common (1-20%)', 'widespread (>20%)'),
  'PAST', c('none', 'minimal (<1%)', 'common (1-20%)', 'widespread (>20%)'),
  'URBN', c('Absent', 'Present')
)
```

Now map each of the above functions to each variable. This allows us to run the analysis for all variables of interest in a single goal, and save all the outputs in a tibble format for easy plotting. This will take a long time, so the results are cached by default for future use.


```r
trend_dat <- response_levels %>%
  mutate(data = map2(prefix, categories, ~preprocess(.x, .y)),
         n_cats = map_dbl(categories, length), 
         mod = map2(data, n_cats, fit_model),
         trends = map(mod, extract_trends))
```

# Results





## Expertise

How does self-professed level of expertise vary in each region over time? The global trend is a roughly linear increase in self-reported expertise from 10ka BP up to 2ka BP, then a falloff continuing to the present day. The present day expertise values are approximately the same as at 10ka BP. This makes sense, as it points to both the increased frequency of preserved archaeological materials with time as well as the reduction in archaeological attention in periods with extensive historical records.

Now we cluster together the local deviations from the global trend using a k-means algorithm. The selection of 6 clusters is somewhat arbitrary, and is made simply based on visual comparisons of different cluster solutions with the goal making the results visually interpretable. The trajectories in these clusters are deviations from the global trend, so a horizontal line would indicate no deviation from the global trend.

![Global and regional trends in self-reported expertise. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-10-1.png)


## Data Quality

The global trend in data quality is more or less the same as the expertise data, with the peak in data quality occurring more recently than for expertise and with a less dramatic falloff leading to the present day. Unlike expertise, which reaches the same values at 10ky BP and present, data quality in the present day remains high in spite of the falloff in the last 2 millennia. Also note the confidence interval for the global trend is generally wider than for the expertise responses.

![Global and regional trends in perceived data quality. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-11-1.png)

## Hunting

The global trend in hunting shows constant high prevalence until around 6,000 years ago, after which there is a smooth decline until the present day when it is very rare. Mapping out the clusters reveals a clear east-west divide, which regions in Afro-eurasia seeing hunting earlier then the global mean, and regions in the Americas and Oceania seeing later peaks in hunting.

![Global and regional trends in the areal extent of hunting. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-12-1.png)

## Extensive Agriculture

The global trends in the prevalence of pastoralism, extensive and intensive agriculture, and urbanism all follow a sigmoidal curve, which means the trend is linear on the scale of the linear predictor (the ordered categorical GAM uses a logit transform as a latent link function). This means that there is a simple increase in the probability of each land use type being prevalent over time.

![Global and regional trends in the areal extent of extensive agriculture. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-13-1.png)

## Intensive Agriculture

See above.

![Global and regional trends in the areal extent of intensive agriculture. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-14-1.png)

## Pastoralism

See above.

![Global and regional trends in the areal extent of pastoralism. (A) Global trend (all regions) with 95% confidence interval. (B) Regional deviations from global trend, clustered via k-means. (C) Map of the local deviations from the global trend, same clusters as in B.](archaeoglobe_files/figure-html/unnamed-chunk-15-1.png)






