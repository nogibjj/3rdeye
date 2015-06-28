#Generates useful git repo stats in R
#To Run This:  Rscript repoStats.R ~/Desktop/web_git_metadata.csv
#Requires installation of plyr, ggplot2, stringmatch
#install.packages(ggplot2), etc from R shell


library("ggplot2")
library(plyr)
library(dplyr)

read_git_log <- function(path){
	git_log <- read.csv(path)
}

format_git_time <- function(git_log){
	git_log$time <- strptime(git_log$date, 
		format = '%a %b %e %H:%M:%S %Y')
	git_log$time <- as.POSIXct(git_log$time)
	git_log	
}

read_format_git_log <-function(path){
	# Format time correctly for ddply.
	# 
	# Returns:
	#	Time striptime formatted log file data
	git_log_raw <- read.csv(path)
    git_log <- format_git_time(git_log_raw)
}

git_log_counts <- function(git_log){
	#Adds Counts To Git Log For Each author/email combination
	git_log_count <- ddply(git_log,.(author_email, author_name),
						summarise,count=length(time))
	git_log_full <- merge(git_log, git_log_count)
}

git_contributor_counts <- function(git_log_full){
	res <- data.frame(count=unique(git_log_full$count))
	git_log_ordered_counts <- res[with(res,order(count)),]
}

git_top_contributor <- function(git_log, top_count=10){
	git_log_ordered_counts <- git_contributor_counts(git_log)
	top <- tail(git_log_ordered_counts,n=top_count)
	x <- data.frame(count=c(top))
	git_log_top <- merge(x, git_log)
	
}

git_unique_authors <- function(git_log){
	# Finds all unique author names
	uan <- data.frame(author_names=unique(git_log$author_name))
}

git_unique_emails <- function(git_log) {
	# Finds all unique emails
	uen <- data.frame(author_email=unique(git_log$author_name))
}

git_distinct_email_name <- function(git_log){
	#Finds all distinct email name combinations
	git_distinct_list <- distinct(git_log[c("author_name","author_email", "count")])
}

git_log_sample <- function(git_log, n=500){
	#Samples git log, especially useful for testing
	small_git_log <- sample_n(git_log, n)
}

global_author_picker <- function(outer_commit_count, 
				inner_commit_count, outer_author_name, inner_author_name){
	#Uses greater frequency of commits to select global author
	#Returns global author
	if (outer_commit_count > inner_commit_count)
		global_author <- outer_author_name
	else
		global_author <-  inner_author_name

	global_author

}

global_author_name <- function(git_log){
	#Finds a global name based on email and name as primary key
	#TO DO:  Optimize, very slow, most likely by removing loops
	#Returns git log Data Frame

	dr <- git_distinct_email_name(git_log)
	git_log["author"] <- NA
	res <- numeric(nrow(git_log))
	t1 <- Sys.time();

  for(i in 1:nrow(git_log)){
    #initialize global author
    global_author <- NA

		#Prints output of metadata processing routine
		loop_counter <- sprintf("Processing Commit %s of %s", i, length(git_log$author_email))
		print(loop_counter)
		outer_author_email <- git_log[i,]$author_email
		outer_author_name <- git_log[i,]$author_name
		outer_commit_count <- git_log[i,]$count

		#Compare against distinct email/name records
		for(j in 1:nrow(dr)){
			inner_author_email <- dr[j,]$author_email
			inner_author_name <- dr[j,]$author_name
			inner_commit_count <- dr[j,]$count

			if (identical(outer_author_email, inner_author_email))
				#emails are the same, so use email/author highest count combo GUID
				global_author <- global_author_picker(outer_commit_count, 
					inner_commit_count, outer_author_name, inner_author_name)
		}
		#Write Global Author Results to Data Frame
		if (global_author)
			res[i] <- sprintf("%s", global_author)
		else
			res[i]$author <- sprintf("%s", outer_author_name)
	}
	t2 <- Sys.time();
	print(difftime(t2,t1))
  git_log$author <- res
	git_log
}

git_metadata <- function(path){
	#Entry point to explore git metadata as an R Dataframe
	
	git_log <- read_format_git_log(path)
	git_log <- git_log_counts(git_log) #Add counts to git log
	git_log <- global_author_name(git_log)
}

#assumes a path to a csv file with metadata is passed in
args <- commandArgs(trailingOnly=TRUE)
if(length(args) > 0) {
    path <- args[1]
   	git_log_full <- git_metadata(path)
   	git_log <- git_top_contributor(git_log_full)
    cat(path)
} else {
    cat("Usage: repoStats path/to/csv\n")
}

#Create Master Project Chart
p <- ggplot(git_log_full, aes(time, author)) + 
     geom_point(aes(color = author))

project_plot <- p + theme(axis.line=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.y=element_blank(),legend.position="none",
          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank())

pdf(file=sprintf("%s-Full.pdf",path), height=6, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
project_plot
dev.off()

#Create Faceted Time-Series Chart of History of Repo
plot <- ggplot(git_log, aes(time, author)) + 
	geom_point(aes(color = author)) 


pdf(file=sprintf("%s-top-contributors.pdf",path), height=6, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
plot
dev.off()
