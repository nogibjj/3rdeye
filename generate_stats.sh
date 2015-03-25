#!/usr/bin/env bash
#./giteye.py ../web ~/Desktop
#Rscript repoStats.R ~/Desktop/

#Generate CSV
./giteye.py $1 $2

#Generate Chart
Rscript repoStats.R $2/web_git_metadata.csv