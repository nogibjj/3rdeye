#!/usr/bin/env python
"""
Advanced Statistics for Git log.

How to use:

A.  import and play with log_df DataFrame or log_to_dict (dictionary of log)
B.  Generate csv metadata:

./giteye.py ../web ~/Desktop

This generates metadata about the web repo and outputs csv file to:  
~/Desktop/web_git_metadata.csv

It also creates a chart called:  web_git_metadata.csv.pdf

"""

from subprocess import (call, Popen, PIPE)
import sys
import os
import csv
#Pandas is optional, only needed for some things
#Trying to avoid being an irritating tool and requiring it
try:
    import pandas as pd
except ImportError:
    pass

GIT_COMMIT_FIELDS = ['id', 'author_name', 'author_email', 'date', 'message']
GIT_LOG_FORMAT = ['%H', '%an', '%ae', '%ad', '%s']
GIT_LOG_FORMAT = '%x1f'.join(GIT_LOG_FORMAT) + '%x1e'

def log_to_dict():
    """Converts Git Log To A Python Dict"""
    
    p = Popen('git log --date=local --format="%s"' % GIT_LOG_FORMAT, shell=True, stdout=PIPE)
    (log, _) = p.communicate()
    log = log.strip('\n\x1e').split("\x1e")
    log = [row.strip().split("\x1f") for row in log]
    log = [dict(zip(GIT_COMMIT_FIELDS, row)) for row in log]
    return log

def log_df():
    """Returns a Pandas DataFrame of git log history"""

    log = log_to_dict()
    df = pd.DataFrame.from_dict(log)
    return df

def generate_repo_name():
    """Returns short name of git repo"""

    cmd = """basename `git rev-parse --show-toplevel`"""
    p = Popen(cmd, shell=True, stdout=PIPE)
    return p.stdout.read().strip() 

def log_to_csv(path=""):
    """Writes python dict of git log to csv file"""
    
    log = log_to_dict()
    repo = generate_repo_name()
    filename = '%s/%s_git_metadata.csv' % (path,repo)
    ensure_path(filename)   #create directory if it doesn't exist
    with open(filename, mode='w') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(["date","author_email", "author_name",  "id", "message"])
        for row in log:
            writer.writerow([row["date"],row["author_email"], 
                row["author_name"], row["id"], row["message"]])
    return filename 

def generate_charts(path):
    cmd = "Rscript repoStats.R %s" % path
    call(cmd, shell=True)

def ensure_path(path):

    outdir = os.path.dirname(path)
    if not os.path.exists(outdir):
        status = os.mkdir(outdir)
        return status 

def main():
    """Runs everything, including generating charts in R"""

    try:
        root_dir = os.path.abspath(".")
        git_repo_path = sys.argv[1]
        output_file = sys.argv[2]
        os.chdir(git_repo_path)
        full_path = log_to_csv(output_file)
        os.chdir(root_dir)
        generate_charts(full_path)
    except IndexError:
        print "./giteye.py /path/to/gitrepo ~/path/to/output/to"

if __name__ == "__main__":
    main()
