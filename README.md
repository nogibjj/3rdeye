# 3rdeye
* [![Code Climate](https://codeclimate.com/github/sqor/3rdeye/badges/gpa.svg)](https://codeclimate.com/github/sqor/3rdeye)

Mystical stats for git (Data Science for Git Repos in both R and Python..pick your poison).  Generates both CSV file of all git history with advanced metrics, and many charts using R for charting and R for advanced statistics and prediction.

###How to use:

A.  import and play with log_df DataFrame or log_to_dict (dictionary of log) in Python and Pandas

B.  Generate csv metadata:

  ./giteye.py ../web ~/Desktop/web-report

This generates metadata about the web repo and outputs csv file to (creates directory you specify for you):  
  ~/Desktop/web-report/web_git_metadata.csv

Finally, from the R terminal you can explore the dataframe created by calling:

  `my_repo <- git_metadata(path)`

###Dependencies:

1.  Python
2.  R 
3.  R packages::  
      ``` library("ggplot2")
          library(plyr)
          library(stringdist)
          library(dplyr)
      ```

####Charts
* Author Percentile Report: ![Author Percentile Report](http://s21.postimg.org/thxzjeyw7/elixir_git_metadata_csv_Percentile_Page_1.jpg)
* Project History ![Project History](http://s27.postimg.org/t5y0v3rub/elixir_git_metadata_csv_Project_History_Page_1.jpg)
* Hour Histogram ![Hour Histogram](http://s1.postimg.org/t0sjijgkv/elixir_git_metadata_csv_commits_by_hour_Page_1.jpg)
* Day of Week Histogram ![dweek Histogram](http://s11.postimg.org/mamyx52f7/elixir_git_metadata_csv_commits_by_week_Page_1.jpg)
