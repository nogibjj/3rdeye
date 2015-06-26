#Generates useful git repo stats in R
#To Run This:  Rscript repoStats.R ~/Desktop/web_git_metadata.csv
#Requires installation of plyr and ggplot2:  install.packages()


library("ggplot2")
library(plyr)

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
	#Adds Counts To Git Log
	git_log_count <- ddply(git_log,~author_email,
						summarise,count=length(time))
	git_log_full <- merge(git_log, git_log_count)
}

git_contributor_counts <- function(git_log_full){
	res <- data.frame(count=unique(git_log_full$count))
	git_log_ordered_counts <- res[with(res,order(count)),]
}

git_top_contributor <- function(git_log, top_count=10){
	git_log_full <- git_log_counts(git_log)
	git_log_ordered_counts <- git_contributor_counts(git_log_full)
	top_contributors <- tail(git_log_ordered_counts,n=top_count)
	x <- data.frame(count=c(top))
	git_log_top <- merge(x, git_log_full)
	
}

#assumes a path to a csv file with metadata is passed in
args <- commandArgs(trailingOnly=TRUE)
if(length(args) > 0) {
    path <- args[1]
   	git_log <- read_format_git_log(path)
    cat(path)
} else {
    cat("Usage: repoStats path/to/csv\n")
}

#Create Faceted Time-Series Chart of History of Repo
plot <- ggplot(git_log_full, aes(time, author_name)) + 
	geom_point(aes(color = author_name)) 


pdf(file=sprintf("%s.pdf",path), height=6, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
plot
dev.off()
