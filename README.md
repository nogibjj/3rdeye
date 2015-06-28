# 3rdeye
* [![Code Climate](https://codeclimate.com/github/sqor/3rdeye/badges/gpa.svg)](https://codeclimate.com/github/sqor/3rdeye)

Mystical stats for git.  Generates both CSV file of all git history, but all generates useful charts.

###How to use:

A.  import and play with log_df DataFrame or log_to_dict (dictionary of log)
B.  Generate csv metadata:

  ./giteye.py ../web ~/Desktop

This generates metadata about the web repo and outputs csv file to:  
  ~/Desktop/web_git_metadata.csv

This also generates a PNG report of top contributors as show below:

![PNG Report](http://s13.postimg.org/ty6ipfetz/elixir_git_metadata_csv_Page_1.jpg)

###Dependencies:

1.  Python
2.  R 
3.  R packages::  
      ``` library("ggplot2")
          library(plyr)
          library(stringdist)
          library(dplyr)```
