#Generates useful git repo stats in R
#To Run This:  Rscript repoStats.R ~/Desktop/web_git_metadata.csv
library("ggplot2")
library(plyr)

format_git_time <- function(git_log){
	#Format time correctly for ddply
	git_log$time <- strptime(git_log$date, 
		format = '%a %b %e %H:%M:%S %Y')
	git_log$time <- as.POSIXct(git_log$time)
	git_log	
}

#assumes a path to a csv file with metadata is passed in
args <- commandArgs(trailingOnly=TRUE)
if(length(args) > 0) {
    path <- args[1]
    git_log_raw <- read.csv(path)
    git_log <- format_git_time(git_log_raw)
    cat(path)
} else {
    cat("Usage: repoStats path/to/csv\n")
}

git_log_count <- ddply(git_log,~author_email,summarise,count=length(time))


#order by counts
#To Do: 
git_log_full <- merge(git_log, git_log_count)
res <- data.frame(count=unique(git_log_full$count))
git_log_unique_counts <- res[with(res,order(count)),]
top_ten <- head(git_log_unique_counts,n=10)


#Create Faceted Time-Series Chart of History of Repo
plot <- ggplot(git_log_full, aes(time, author_name)) + 
	geom_point(aes(color = author_name)) 


pdf(file=sprintf("%s.pdf",path), height=6, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
plot
dev.off()
