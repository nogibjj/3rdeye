#Generates useful git repo stats in R
#To Run This:  Rscript repoStats.R ~/Desktop/web_git_metadata.csv
#Requires installation of plyr, ggplot2, stringmatch
#install.packages(ggplot2), etc from R shell


library("ggplot2")
library(plyr)
library(dplyr)
library(lubridate)
library(forecast)
library(xts)
library(ggfortify)
#install.packages("devtools", repos = "http://mran.revolutionanalytics.com")
#library(devtools)
#install_github('sinhrks/ggfortify')	#probably not the best long term
#options(error=recover)

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

git_top_contributor <- function(git_log, top_count=50){
	#Get last 50 authors
	gl <- git_log
	gl <- gl[with(gl,order(count,decreasing = TRUE)),]
	gl_top <- head(gl,n=top_count)
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
	#Creates a author column, used for legacy will soon go away

	#Returns git log Data Frame
	git_log["author"] <- NA
  	git_log$author <- git_log$author_name
	git_log
}

git_log_author_commits <- function(git_log){
	#Counts all author commits (author is a GUID)
	git_log_author_counts <- ddply(git_log,~author,summarise,count=length(time))
}
 
git_percentile_ranking <- function(glauthor){
	#Generate rank from 1-100 based on commits out of total
	
	Fn <- ecdf(glauthor$count)
	glauthor$percentile <- round(Fn(glauthor$count), digits=2)*100
	glauthor
}

git_log_time_metadata <- function(git_log){
	#adds hour, week day columns to commit data
	git_log$hour <- hour(git_log$time)
	git_log$wday <- wday(git_log$time)
	git_log
}

git_groups <- function(git_log){
	commit_groups <- split(git_log$time, git_log$author)
}

groups_to_df <- function(git_log){
	groups <- git_groups(git_log)
	df <- lapply(groups, data.frame)
}

groups_counts <- function(git_log){
	groups <- git_groups(git_log)
	g <- groups[1] #get one
	names(g) #get name
	#look at tapply
}

git_group_to_xts <- function(group){
	#creates a xts time series object out of git commit group
	#or a git column from a data.frame like g$time
	tsg <- as.xts(as.numeric(rep(1, length(group))), group)
}

git_commits_day <- function(group){
	#determine git commits/day

	ts <- git_group_to_xts(group)
	pd <- apply.daily(ts, sum)
}

git_commits_weekdays <- function(group){
	#subset the time series by weekdays (M-F only)
	
	tswd <- group[!weekdays(index(group)) %in% c("Saturday", "Sunday")]
}

weekdays_range <- function(group){
	#retrieve all weekdays in groups range
	wd <- jwd[.indexwday(jwd)]
}

weekdays_theortical_seq <- function(group){
	#Generate a sequence of contiguous M-F dates from a ts object
	startd <- head(group,n=1)
	finishd <- tail(group,n=1)
	date_range <- seq(s,f, by="day")
}

weekdays_gaps <- function(group){
	
}

git_wday_commits_theoretical_count <- function(group){
	#total M-F days where commits could have occurred
	
	startd <- head(group,n=1)
	finishd <- tail(group,n=1)
	total <- sum(!weekdays(seq(index(startd), index(finishd), "days")) %in% c("Saturday", "Sunday"))
}

git_create_commit_forecast <- function(pd){
	#takes a git xts object and creates a forecast from it
	 
	d.arima <- auto.arima(pd)
	d.forecast <- forecast(d.arima, level = c(95), h = 50)
}

git_metadata <- function(path){
	#Entry point to explore git metadata as an R Dataframe
	
	git_log <- read_format_git_log(path)
	git_log_author_counts <- git_log_counts(git_log) #Add counts to git log
	git_log <- global_author_name(git_log_author_counts)
	git_log <- git_log_time_metadata(git_log) #hour/day columns
	
	#Get author and project metadata
	glauthor <- git_log_author_commits(git_log) #change counting to author
	git_log$count <- NULL #delete counts column before merge
	git_log_project_metadata <- merge(git_log, glauthor)
	git_log_author_metadata <- git_percentile_ranking(glauthor)
	metadata <- list(git_log_project_metadata,git_log_author_metadata)
   return(metadata)
}

git_repo_name <- function(filename){
	#Retrieve repo name from filename passed in

	file <- basename(filename)
	v <- strsplit(file, "_")
	repo_name <- v[[1]][1]
	repo <- sprintf("%s", repo_name)
}

git_report_dir <- function(path){
	dir <- dirname(path)
}

git_write_author_metadata_to_csv <- function(git_author_metadata, path){
	#Write metadata of git log to csv
	
	path <- git_report_dir(path)
	git_author_metadata <- git_author_metadata[with(git_author_metadata,order(count, 
					decreasing = TRUE)),]
	output <- sprintf("%s/author_metadata.csv", path)
	write.table(git_author_metadata, file=output, sep=",", row.names = F) 
}

git_write_commit_metadata_to_csv <- function(git_log, path){
	#Write metadata of git commit log to csv
	
	git_log$message <- NULL
	git_log$id <- NULL
	path <- git_report_dir(path)
	git_commit_metadata <- git_log[with(git_log,order(count, 
					decreasing = TRUE)),]
	output <- sprintf("%s/commit_metadata.csv", path)
	write.table(git_commit_metadata, file=output, sep=",", row.names = F) 
}

write_report <- function(git_author_metadata, git_log_full, path){
	#Writes out CSV Reports on Git Repo
	git_write_author_metadata_to_csv(git_author_metadata, path)
	git_write_commit_metadata_to_csv(git_log_full, path)
}

#assumes a path to a csv file with metadata is passed in
args <- commandArgs(trailingOnly=TRUE)
if(length(args) > 0) {
    path <- args[1]
    repo_name <- git_repo_name(path)
   	metadata <- git_metadata(path)
   	git_author_metadata <- metadata[[2]]
   	git_log_full <-metadata[[1]]
   	git_log_full$date <- NULL
   	pd <- git_commits_day(git_log_full$time)
   	pd_forecast <- git_create_commit_forecast(pd)
   	write_report(git_author_metadata, git_log_full, path)
    cat(path)
} else {
    cat("Usage: repoStats path/to/csv\n")
}

#Create Time Series Chart of Commits/Day
commits_day_title <- sprintf("Commit By Day: %s", repo_name)
commits_day_title <- sprintf("%s --Median/Day-- %s", commits_day_title, median(pd))
commits_day_plot <- autoplot(pd, colour="red", ts.geom = 'bar') + 
	xlab("Date") + ylab("Commits Per Day") +
	ggtitle(commits_day_title)

pdf(file=sprintf("%s-commits-per_day.pdf",path), height=9, width=9, 
	onefile=TRUE, family='Helvetica', pointsize=12)
commits_day_plot
dev.off()

# # #Create Time Series Chart of Commits/Day and forecast
# commits_day_forecast_plot <- autoplot(pd_forecast)

# pdf(file=sprintf("%s-commits-per_day_forecast.pdf",path), height=9, width=9, 
# 	onefile=TRUE, family='Helvetica', pointsize=12)
# commits_day_forecast_plot
# dev.off()

#Create Day Hour Plot
day_hour_title <- sprintf("Commit Density By Hour/Day: %s", repo_name)
day_hour_plot <- ggplot(git_log_full, aes(x=hour)) + 
	geom_density(fill="green", colour="red") + 
	facet_grid(wday ~ .) + ggtitle(day_hour_title)
pdf(file=sprintf("%s-day-hour.pdf",path), height=12, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
day_hour_plot
dev.off()


#Create Hour Histogram Chart
hour_hist_title <- sprintf("Commit Frequency By Hour: %s", repo_name)
hour_hist_plot <- ggplot(git_log_full, aes(x=hour)) + 
	geom_histogram(binwidth=1,fill="green", colour="black") +
	ggtitle(hour_hist_title)

pdf(file=sprintf("%s-commits-by-hour.pdf",path), height=12, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
hour_hist_plot
dev.off()

#Create Weekday Histogram Chart
wday_hist_title <- sprintf("Commit Frequency By Weekday: %s", repo_name)
wday_hist_plot <- ggplot(git_log_full, aes(x=wday)) + 
	geom_histogram(binwidth=1,fill="green", colour="black") +
	ggtitle(wday_hist_title)

pdf(file=sprintf("%s-commits-by-weekday.pdf",path), height=12, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
wday_hist_plot
dev.off()

#Create Author Percentile Chart
author_plot_title <- sprintf("Top Authors By Commits: %s", repo_name)
gam <- git_author_metadata
gam <- git_top_contributor(gam) #get top 50
gam$author <- factor(gam$author, levels = gam$author[order(gam$count)])
author_plot <- ggplot(gam, aes(count, author)) + 
     geom_point(aes(colour = percentile), size = 4) + scale_colour_gradientn(colours=rainbow(4)) +
     ggtitle(author_plot_title) +
     labs(x="Total Commits") +
     labs(y="Author")

pdf(file=sprintf("%s-Percentile.pdf",path), height=12, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
author_plot
dev.off()


#Create Master Project Chart
project_plot_title <- sprintf("Git Repo History: %s", repo_name)
glf <- git_log_full
glf$author <- factor(glf$author, levels = glf$author[order(glf$count, glf$time)])
p <- ggplot(glf, aes(time, author)) + 
     geom_point(aes(color = author))


project_plot <- p + theme(axis.line=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.y=element_blank(),legend.position="none",
          panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank()) + ggtitle(project_plot_title)

pdf(file=sprintf("%s-Project-History.pdf",path), height=12, width=12, 
	onefile=TRUE, family='Helvetica', pointsize=12)
project_plot
dev.off()
