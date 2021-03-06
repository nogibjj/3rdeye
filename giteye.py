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
import time
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
    
    repo_name = generate_repo_name()
    p = Popen('git log --date=local --format="%s"' % GIT_LOG_FORMAT, shell=True, stdout=PIPE)
    (log, _) = p.communicate()
    log = log.strip('\n\x1e').split("\x1e")
    log = [row.strip().split("\x1f") for row in log]
    log = [dict(zip(GIT_COMMIT_FIELDS, row)) for row in log]
    for dictionary in log:
        dictionary["repo"]=repo_name
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

def log_to_csv(path="", log=None, org=None):
    """Writes python dict of git log to csv file"""
    
    if not log:
        log = log_to_dict()
    if not org:
        repo = generate_repo_name()
    else:
        repo = org

    filename = '%s/%s_git_metadata.csv' % (path,repo)
    ensure_path(filename)   #create directory if it doesn't exist
    with open(filename, mode='w') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(["date","author_email", "author_name",  "id", "message", "repo"])
        #import pdb;pdb.set_trace()
        for row in log:
            try:
                writer.writerow([row["date"],row["author_email"], 
                    row["author_name"], row["id"], row["message"], row["repo"]])
            except KeyError:
                print "Skipping row: %s" % row
                pass
    return filename 

def generate_charts(path):
    cmd = "Rscript repoStats.R %s" % path
    call(cmd, shell=True)

def ensure_path(path):

    outdir = os.path.dirname(path)
    if not os.path.exists(outdir):
        status = os.mkdir(outdir)
        return status 

def meta_analysis(checkout_path):
    """Performs meta_analysis of multiple repos"""

    print "Processing Path: %s" % os.path.abspath(checkout_path)
    repo_logs = []
    dirs = os.listdir(checkout_path)
    os.chdir(checkout_path)
    for dir in dirs:
        try:
            os.chdir(dir)
            print "Creating metadata for %s" % dir
            repo_logs.extend(log_to_dict())
            os.chdir("..")
        except Exception:
            print "Skipping %s, not git repo" % dir
    return repo_logs

def create_checkout_path(org, path):
    """Create a checkout path for a metacheckout"""

    outdir = "%s/%s" % (path, org)
    mk_status = call("mkdir -p %s" % outdir, shell=True)
    return outdir

def download_all_github_org(oath_key, org, path="/tmp"):
    """Downloads all git repos in an organization, including private

    A bit hacky....
    """

    start = time.time()
    outdir = create_checkout_path(org, path)
    cmd = """curl -u %s:x-oauth-basic -s https://api.github.com/orgs/%s/repos\?per_page\=200 """ % (oath_key, org)
    cmd = cmd +  """| ruby -rubygems -e 'require "json";JSON.load(STDIN.read).each { |repo| %x[git clone #{repo["ssh_url"]} ]}'"""
    print "Downloading Entire Github Repo %s to %s" % (org, path)
    status = call(cmd, shell=True)
    end = time.time()
    timer = end - start
    p = Popen("ls -l | wc -l", shell=True, stdout=PIPE)
    (projects, _) = p.communicate()
    print "Downloaded %s repos for %s in %s seconds" % (projects.strip(), org, timer)
    return status

def help():
        print "./giteye.py <path/to/gitrepo> </path/to/output/to>"
        print "./giteye.py --meta <oath-key> <Github Organization> <path/to/checkout/org>"

def meta_main(oath, org, path="/tmp"):
    """Creates a meta analysis of github organization"""

    checkout_path = create_checkout_path(org,path)
    status = download_all_github_org(oath,org,path)
    logs = meta_analysis(path)
    filename = log_to_csv(path, logs, org)
    return filename

def main():
    """Runs everything, including generating charts in R

    A bit too wild, should convert to argparse later
    """

    if len(sys.argv) >1:
        if "--meta" == sys.argv[1]:
            if len(sys.argv) < 5:
                print "ERROR! Not enough arguments:  ./giteye.py --meta <oath-key> <Github Organization> <path/to/checkout/org>"
                print "Provided following arguments: %s" % sys.argv
                sys.exit(1)
            try:
                oath = sys.argv[2]
                org = sys.argv[3]
                path = sys.argv[4]
                filename = meta_main(oath,org,path)
                print "Meta-report created: %s" % filename
                sys.exit(0)
            except IndexError:
                help()
    try:
        root_dir = os.path.abspath(".")
        git_repo_path = sys.argv[1]
        output_file = sys.argv[2]
        os.chdir(git_repo_path)
        full_path = log_to_csv(output_file)
        os.chdir(root_dir)
        generate_charts(full_path)
    except IndexError:
        help()

if __name__ == "__main__":
    main()
