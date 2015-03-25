#Generates useful git repo stats in R
#To Run This:  Rscript repoStats.R ~/Desktop/web_git_metadata.csv
library("ggplot2")

#assumes a path to a csv file with metadata is passed in
args <- commandArgs(trailingOnly=TRUE)
if(length(args) > 0) {
    path <- args[1]
    git_log <- read.csv(path)
    cat(path)
} else {
    cat("Usage: repoStats path/to/csv\n")
}

git_log$time <- strptime(git_log$date, 
	format = '%a %b %e %H:%M:%S %Y')

#Create Faceted Time-Series Chart of History of Repo
plot <- ggplot(git_log, aes(time, author_name)) + 
	geom_point(aes(color = author_name))

pdf(file=sprintf("%s.pdf",path), height=6, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
plot
dev.off()


