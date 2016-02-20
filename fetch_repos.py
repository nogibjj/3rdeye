"""
To use this, create a settings.py file and make these variables:

TOKEN=<oath token for github>
ORG=<your org in github>
DEST=<Path to download to>
"""

from github import Github
from subprocess import call
import os
from settings import TOKEN, ORG, DEST

def download():
	"""Quick and Dirty Download all repos function"""

	os.chdir(DEST)
	print "Downloading to destination: ", os.getcwd()
	g = Github(TOKEN)
	repos = []
	for repo in g.get_organization(ORG).get_repos():
		print "Fetching Repo Name: %s" % repo.name
		repos.append("git@github.com:%s/%s.git" % (ORG, repo.name))
	
	total = len(repos)
	print "Found %s repos" % total
	
	count = 0
	for repo in repos: 
		count +=1
 		print "Cloning Repo [%s]/[%s]: %s" % (count, total, repo)
 		call([u'git', u'clone', repo])

download()