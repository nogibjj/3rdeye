# 3rdeye
* [![Code Climate](https://codeclimate.com/github/sqor/3rdeye/badges/gpa.svg)](https://codeclimate.com/github/sqor/3rdeye)

Mystical stats for git.  Generates both CSV file of all git history, but all generates useful charts.

###How to use:

A.  import and play with log_df DataFrame or log_to_dict (dictionary of log)

B.  Generate csv metadata:

  ./giteye.py ../web ~/Desktop/web-report

This generates metadata about the web repo and outputs csv file to:  
  ~/Desktop/web_git_metadata.csv

This also generates a PNG report of both the entire repo history and top contributors as show below:

![PNG Report](http://s10.postimg.org/i77jlttrd/elixir_git_metadata_csv_Full_Page_1.jpg)

Finally, from the R terminal you can explore the dataframe created by calling:

  `my_repo <- git_metadata(path)`

###Dependencies:

1.  Python
2.  R 
3.  R packages::  
      ``` library("ggplot2")
          library(plyr)
          library(stringdist)
          library(dplyr)```
