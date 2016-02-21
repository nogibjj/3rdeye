
format_coder <- function(git_log_full, email){
	coder <- git_log_full[git_log_full$author_email == email,]
	repos_count <- length(as.integer((unique(coder$repo))))
	total_commmits <- median(coder$count)
	last <- head(coder[ order(coder$time , decreasing = TRUE ),],n=1)
	first <- head(coder[ order(coder$time , decreasing = FALSE ),],n=1)
	days_active <- round(difftime(last$time , first$time, units = c("days")))
	coder_activity <- table(factor(format(coder$time,"%D")))
	median_per_day <- median(coder_activity)
	days_active_worked <- dim(coder_activity)
	probability <- days_active_worked/as.integer((days_active))
	percentage_of_all <- unique(coder$count/length(git_log_full$time))
	stats <- data.frame(Name=as.character((unique(coder$author_name))),
                 FirstCommit=first$time,
                 LastCommit=last$time,
                 DaysActive=days_active,
                 DaysActiveCommitted=days_active_worked,
                 MedianCommitsActiveDay=median_per_day,
                 ProbabilityCommitAnyDay=probability,
                 TotalCommits=total_commmits,
                 TotalReposWorkedOn=repos_count,
                 PercentageAllCommits=percentage_of_all)
	stats
}

# Before loop:

# d = NULL

# And in the loop:

# d = rbind(d, data.frame(x, y, z))

#Loop Through Everyone
mylist <- list()
for (i in authors){
	#print(i)

    res <- format_coder(git_log_full,i)
    mylist[[i]] <- res
    # d[i, ] <-  c(res$Name, res$FirstCommit, res$LastCommit, 
    # 	res$DaysActive, res$DaysActiveCommitted, res$MedianCommitsActiveDay, 
    # 	res$ProbabilityCommitAnyDay, res$TotalCommits, res$TotalReposWorkedOn, res$PercentageAllCommits)
    print(res, col.names = FALSE)
}