#library(cacheSweave)
#library(utils)
#assignInNamespace("RweaveLatex", cacheSweave::cacheSweaveDriver, "utils")

library(grDevices)
options(digits=2)

# asc <- function(x) as.character(x)
# asi <- function(x) as.integer(x)
# asd <- function(x) as.double(x)
# asic  <- function(x) as.integer(as.character(x))
# asdc  <- function(x) as.double(as.character(x))
# round.mean <- function(x) round(mean(x))


se <- function(x)
{
   y <- x[!is.na(x)] # remove the missing values, if any
   sqrt(var(as.vector(y))/length(y))
}

# ci.width <- function (scores){
# 	stderr <- se(scores)
# 	len <- length(scores)
# 	return( qt(.975, df=len-1) * stderr )
# }
# 
# ci <- function (scores){
# 	m <- mean(scores)
# 	w <- ci.width(scores)
# 	upper <- m + w
# 	lower <- m - w
# 	return(data.frame(lower=lower,upper=upper))
# }
# 
# 
# 
# strlen <- function(str) {
# 	length(strsplit(as.character(str), split="")[[1]]) 
# }
# 
# cbind.asym <- function(x, y) {
#   x.len <- length(x)
#   y.len <- length(y)
#   if(x.len < y.len) {
#     y <- c(y, rep(NA, y.len-x.len))
#   } else {
#     x <- c(y, rep(NA, x.len-y.len))
#   }
#   result <- cbind(x,y)
#   return(result)
# }
# 
# constructRoiInfo <- function(strings, wordinfo)
# {
# 	cnts  <- c()
# 	means <- c()
# 	lens  <- c()
# 	for(string in strings) 
# 	{
# 		len <- strlen(string)
# 		words <- strsplit(string, split=" ")[[1]]
# 		wordCnt <- length(words)
# 		usedWords <- subset(wordinfo, word %in% words)
# 		if(length(usedWords[,1]) != wordCnt) {
# 			freqSum <- NA
# 		} else {
# 			freqSum <- sum(usedWords$freq.lemma)
# 		}
# 		meanFreq <- freqSum/wordCnt
# 		cnts <- append(cnts, wordCnt)
# 		means <- append(means, meanFreq)
# 		lens <- append(lens, len)
# 	}
# 	return(data.frame(wordCnt=cnts, meanFreq=means, lenChr=lens))
# }
# 
# 
# cmap <- function(d, from, to) {
# 	colnames(d) <- map(colnames(d), from, to)
# 	return(d)
# }
# 
# fmap <- function(d, to, convert=NULL) {
#    condVec <- as.character(d$condition)
#    conds <- sort(unique(condVec))
#    if(is.null(convert)) {
# 	convert = factor
#    }	
#    return(convert(map(condVec, conds, to)))
# }
# 
# map <- function(vec, from, to, verbose=F) {
# 	newVec <- vec
# 	for( i in 1:length(from) ) {
#                 if(verbose){
#                   print(from[i])
#                 }
# 		newVec[vec == from[i]] <- to[i]
# 	}
# 	return(newVec)
# }
# 
# individual.rep <- function(vec, n) {
#   ret <- c()
#   if(length(n) == 1){
# 	n <- rep(n, length(vec))
#   } 
#   for( i in 1:length(vec)) {
#     ret <- append(ret, rep(vec[i], n[i]))
#   }
#   return(ret)
# }
# 
# in.range <- function(x,rng) {
#   stopifnot(is.integer(x)|is.double(x))
#   return(x>=rng[1] & x<=rng[2])
# }



# plotQQNorm <- function(measure, index, transform) {
# 	columnsCnt <- 2
# 	plotsCnt   <- length(unique(index))
# 
# 	plotsModCols <- plotsCnt %% columnsCnt
# 	rowsCnt      <- (plotsModCols!=0)*1 + (plotsCnt-plotsModCols)/columnsCnt
# 
# 	multiplot(rowsCnt, columnsCnt)
# 	for(ind in levels(index)) {
# 		cur.measure <- measure[ index == ind ]
# 
# 		# kick out NAs
# 		cur.measure <- cur.measure[ !is.na(cur.measure) ]
# 		caption.main <- paste("condition", as.character(ind))
# 		
# 		qqnorm(transform(cur.measure), main=caption.main)
# 	}
# }

# roiTable <- function(fixationsSequence)
# {
# 	byIndex <- paste(fixationsSequence$item, fixationsSequence$condition, sep="-")
# 	maxROI  <- max( as.integer(fixationsSequence$roi), na.rm=T)
# 	items <- by(fixationsSequence, byIndex, function(data)
# 	{
# 		roiWords <- c()
# 		for( curROI in 1:maxROI )
# 		{
# 			d <- subset(data, roi == curROI)
# 			if( length(d$roi) > 0 )
# 			{
# 				wordspos <- unique(d[,c('fixatedword','fixatedposition')])
# 				
# 				# if different words are encountered in the same position the next instruction should fail
# 				if( length(wordspos$fixatedposition) != length(unique(wordspos$fixatedposition)) ) {
# 					warning("different words are assigned the same position")
# 					print(wordspos)
# 				}
# 				
# 				#print( paste("item", unique(data$item), "condition", unique(data$condition) ) )
# 				#print( paste("roi",wordspos) )
# 				#print( unique(d[,c('fixatedword','fixatedposition','version','item','condition')]) )
# 				rownames(wordspos) <- wordspos$fixatedposition
# 				
# 				wordorder <- as.character(sort(as.integer(rownames(wordspos))))
# 				curWord <- paste(wordspos[wordorder, 'fixatedword'], collapse=" ")
# 			} else {
# 				curWord <- ""
# 			}
# 			roiWords <- append(roiWords, curWord)
# 		}
# 		matrix(roiWords, nrow=1)
# 	})
# 	itemsMatrix <- c()
# 	itemsNames <- sort(names(items))
# 	for(name in itemsNames) {
# 		itemsMatrix <- rbind(itemsMatrix, items[[name]])
# 	}
# 	rownames(itemsMatrix) <- itemsNames
# 	colnames(itemsMatrix) <- 1:length(itemsMatrix[1,])
# 
# 	return( itemsMatrix )
# }


# plotMeasure <- function(tmeans, relevantPart, mainTitle, ROIlabels, GraphLegend, 
# 			col=c('red', 'red', 'blue','blue'), lty=c(1, 2, 1, 2),
# 			pch=c(21,25,21,25), legendX=1, cex=1 )
# {
# 	tmeans <- tmeans[,relevantPart]
# 
# 	yaxismag <- 1.8
# 	xaxismag <- 1
# 	labelmag <- 1
# 	legendmag <- 1.3
# 	
# 	maxY <- max(tmeans, na.rm=T)
# 	minY <- min(tmeans, na.rm=T)
# 	
# 	matplot(relevantPart,
# 	        t(tmeans),
# 	        cex.lab=cex, cex.main=cex, #magnification of x y labels
# 	        xlab = "Position", ylab = "Mean Reading Time (ms)",
# 	        cex.axis=cex, cex.lab=cex,
# 	        cex.axis = cex,  #sets y axis annotation mag; for xaxis, see axis
# 	        ylim = range(minY,maxY),
# 	        type="n", # don't put any plots
# 		xaxt="n", # don't put any plots
# 	        main = mainTitle,
# 	       )
# 
# 	styles.col <- c( a=col[1], b=col[2], c=col[3], d=col[4] )
# 	styles.lty <- c( a=lty[1], b=lty[2], c=lty[3], d=lty[4] )
# 	styles.pch <- c( a=pch[1], b=pch[2], c=pch[3], d=pch[4] )
# 	
# 	for(cond in names(styles.col)) {
# 		points(tmeans[cond,], bg = c(styles.col[[cond]]),   pch = styles.pch[[cond]])
# 		lines(tmeans[cond,],
# 		type="l",
# 		      col=c(styles.col[[cond]]),
# 		      lty=styles.lty[[cond]],
# 		      lwd=1) 
# 	}
# 	
# 	legend(list(x=legendX,y=maxY),
# 	        legend = GraphLegend, 
# 	        col=styles.col,
# 	        pch=styles.pch,
# 	        pt.bg=styles.col,
# 	        lty=styles.lty,
# 	        cex=cex,     #magnification of legend
# 	        lwd=2,
# 	        xjust=1,
# 	        yjust=1,
# 	        merge=TRUE)#, trace=TRUE)
# 	
# 	axis(1,          #draw below the x-axis line
# 	     at = relevantPart,
# 	     cex.axis=cex, 
# 	     lab = ROIlabels[relevantPart],
# 	     col.axis = "black")
# }	


# plotMeasureCIs <- function(measure, condition, roi, relevantPart, mainTitle, 
# 			ROIlabels, GraphLegend, ylab="Mean Reading Time (ms)",
# 			xlab='Position',
# 			col=c('red', 'red', 'blue','blue'), lty=c(1, 2, 1, 2),
# 			pch=c(21,25,21,25), legendX=1, cex=1, drawCIs=TRUE, 
# 			na.rm=T, ylim=NA, fun=mean)
# {
# 	noNAs <- !is.na(measure)
# 	measure <- measure[noNAs]; 
# 	condition <- condition[noNAs]; 
# 	roi <- roi[noNAs]; 
# 
# 	tmeans <- tapply(measure, list(condition, roi), fun, na.rm=na.rm)
# 	tse    <- tapply(measure, list(condition, roi), se )
# 	tlen   <- tapply(measure, IND = list(condition, roi), function(x){length(x[!is.na(x)])})
# 	# compute CIs
# 	tup  <- tmeans + qt(.975, df=tlen-1) * tse    # upper bound of 95% confidence int.
# 	tlow <- tmeans + qt(.025, df=tlen-1) * tse    # lower bound
# 
#         
# 	ROIlabels <- ROIlabels[relevantPart]
# 	tmeans <- tmeans[,relevantPart]
# 	tup <- tup[,relevantPart]
# 	tlow <- tlow[,relevantPart]
# 
# 	yaxismag <- 1.8
# 	xaxismag <- 1
# 	labelmag <- 1
# 	legendmag <- 1.3
# 	
# 	maxY <- max(tmeans, na.rm=T)
# 	minY <- min(tmeans, na.rm=T)
# 	if( length(ylim) == 1 ) {
# 		if( is.na(ylim) ) {
# 		ylim <- c(minY, maxY)
# 		}
# 	}
# 
# 	if(length(rownames(tmeans)) == 0) {
# 		# only one condition is to be diplayed
# 		tmeans <- t(as.matrix(tmeans))
# 		rownames(tmeans) <- condition[1]
# 	}
#         
# 	matplot(relevantPart,
# 	        t(tmeans),
# 	        cex.lab=cex, cex.main=cex, #magnification of x y labels
# 	        xlab = xlab, ylab = ylab,
# 	        cex.axis=cex, cex.lab=cex,
# 	        cex.axis = cex,  #sets y axis annotation mag; for xaxis, see axis
# 	        ylim = ylim,
# 	        type="n", # don't put any plots
# 		xaxt="n", # don't put any plots
# 	        main = mainTitle,
# 	       )
# 	styles.col <- c( a=col[1], b=col[2], c=col[3], d=col[4] )
# 	styles.lty <- c( a=lty[1], b=lty[2], c=lty[3], d=lty[4] )
# 	styles.pch <- c( a=pch[1], b=pch[2], c=pch[3], d=pch[4] )
# 	
# 	conditions <- sort(unique(condition))
# 	for(cond in conditions)
# 	{
# 		x <- as.integer(colnames(tmeans))
# 		y <- tmeans[cond,]
# 
# 		points(x, y, bg = c(styles.col[[cond]]),   pch = styles.pch[[cond]])
# 		lines(x, y, type="l",
# 		      col=c(styles.col[[cond]]),
# 		      lty=styles.lty[[cond]],
# 		      lwd=1) 
# 	}
# 	legend(list(x=legendX,y=maxY),
# 	        legend = GraphLegend, 
# 	        col=styles.col,
# 	        pch=styles.pch,
# 	        pt.bg=styles.col,
# 	        lty=styles.lty,
# 	        cex=cex,     #magnification of legend
# 	        lwd=2,
# 	        xjust=1,
# 	        yjust=1,
# 	        merge=TRUE)#, trace=TRUE)
# 	
# 	axis(1,          #draw below the x-axis line
# 	     at = relevantPart,
# 	     cex.axis=cex, 
# 	     lab = ROIlabels,
# 	     col.axis = "black")
# 
# 	if(drawCIs) {
# 		for( condition in rownames(tup)) {
# 			for(roi in colnames(tup)) {
# 				print( paste(condition, roi) )
# 				drawCI(tup[condition,roi], tlow[condition,roi], 
# 					as.integer(roi), color=styles.col[condition], 
# 					pch=styles.pch[condition])
# 			}
# 		}
# 	}
# }	


# drawCI <- function(high, low, xVal, color="black", pch=21) 
# {
# 	   arrows(x0=xVal,   # lower and upper coordinates of "arrows"
# 	       y0=low, 
# 	       x1=xVal,
# 	       y1=high,
# 	       angle = 90, # "arrow"-ends at 90 degree angle to line 
# 	       code=3,     # "arrow" drawn at both ends
# 	       col=color, # maybe use a new color?
# 	       lwd=1,
# 		pch=pch,
# 	       length = .05)
# }



# plotDensities <- function(measure, condition, roi, relevantPart, mainTitle, 
# 			GraphLegend, ylab="Mean Reading Time (ms)",
# 			col=c('red', 'red', 'blue','blue'), lty=c(1, 2, 1, 2),
# 			pch=c(21,25,21,25), legendX=1, cex=1, na.rm=T, ylim=NA, xlim=NA)
# {
# 	yaxismag <- 1.8
# 	xaxismag <- 1
# 	labelmag <- 1
# 	legendmag <- 1.3
# 
# 	d <- data.frame(measure, condition, roi)
# 	d <- subset(d, !is.na(measure) & roi%in% relevantPart)
# 	
# 	maxY <- 1; minY <- 0;
# 	if( length(ylim) == 1 ) { if( is.na(ylim) ) {
# 		ylim <- c(0, 1)
# 	} } else {
# 		maxY <- ylim[2]; minY <- ylim[1]
# 	}
# 	if( length(xlim) == 1 ) { if( is.na(xlim) ) {
# 		xlim <- range(measure)
# 	}}
# 
# 	styles.col <- c( a=col[1], b=col[2], c=col[3], d=col[4] )
# 	styles.lty <- c( a=lty[1], b=lty[2], c=lty[3], d=lty[4] )
# 	styles.pch <- c( a=pch[1], b=pch[2], c=pch[3], d=pch[4] )
# 
# 	for( cond in sort(unique(as.character(condition)))) {
# 		plot(density(subset(d, condition==cond)$measure), xlim=xlim, ylim=ylim,
# 		      col=c(styles.col[[cond]]),
# 		      lty=styles.lty[[cond]],
# 		      main=mainTitle
# 		); 
# 		par(new=T)
# 	}
# 	par(new=F)
# 	
# 	legend(list(x=legendX,y=maxY),
# 	        legend = GraphLegend, 
# 	        col=styles.col,
# #	        pch=styles.pch,
# #	        pt.bg=styles.col,
# 	        lty=styles.lty,
# 	        cex=cex,     #magnification of legend
# 	        lwd=2,
# 	        xjust=1,
# 	        yjust=1,
# 	        merge=TRUE)#, trace=TRUE)
# }	



# drawComparison <- function( conditions1, name1, conditions2, name2, position, mainTitle,
# 		  	    tmeans, tse, tlen, tup, tlow)
# {
# 	Means1 <- mean(tmeans[conditions1, position])
# 	Means2 <- mean(tmeans[conditions2, position])
# 
# 	CI1low  <- mean(tlow[conditions1, position])
# 	CI1high <- mean(tup[conditions1,  position])
# 	CI2low  <- mean(tlow[conditions2, position])
# 	CI2high <- mean(tup[conditions2,  position])
# 
# 	maxY <- max(tup[, position], na.rm=T)
# 
# 	barplot(c(Means1, Means2),  
#         	  ylim=range(0,maxY),
# 	          beside=TRUE,names.arg=c(name1, name2),
#         	  ylab=c("Mean Reading Time (msec)"),
# 	          main=mainTitle)
# 
# 	drawCI( CI1high, CI1low, 0.7)
# 	drawCI( CI2high, CI2low, 1.9)
# }


# drawComparison4 <- function( conditions1, name1, conditions2, name2, conditions3, name3, conditions4, name4,
# 			     position, mainTitle, tmeans, tse, tlen, tup, tlow)
# {
# 	Means1 <- mean(tmeans[conditions1, position])
# 	Means2 <- mean(tmeans[conditions2, position])
# 	Means3 <- mean(tmeans[conditions3, position])
# 	Means4 <- mean(tmeans[conditions4, position])
# 
# 	CI1low  <- mean(tlow[conditions1, position])
# 	CI1high <- mean(tup[conditions1,  position])
# 	CI2low  <- mean(tlow[conditions2, position])
# 	CI2high <- mean(tup[conditions2,  position])
# 	CI3low  <- mean(tlow[conditions3, position])
# 	CI3high <- mean(tup[conditions3,  position])
# 	CI4low  <- mean(tlow[conditions4, position])
# 	CI4high <- mean(tup[conditions4,  position])
# 
# 	maxY <- max(tup[, position], na.rm=T)
# 
# 	barplot(c(Means1, Means2, Means3, Means4),  
#         	  ylim=range(0,maxY),
# 	          beside=TRUE,names.arg=c(name1, name2, name3, name4),
#         	  ylab=c("Mean Reading Time (msec)"),
# 	          main=mainTitle)
# 
# 	drawCI( CI1high, CI1low, 0.7)
# 	drawCI( CI2high, CI2low, 0.7+1.2*1)
# 	drawCI( CI3high, CI3low, 0.7+1.2*2)
# 	drawCI( CI4high, CI4low, 0.7+1.2*3)
# }


#progressiveTrials <- function(d, rois) {
#  nonprogressive <- subset(d, roi%in%rois & (FFP==0 | is.na(FFP)))
#  nonprogressive.ids <- with(nonprogressive, unique(paste(subject, trial, sep='-')))
#  all.ids <- with(d, unique(paste(subject, trial, sep='-')))
#  progressive <- subset(d, !(paste(subject, trial, sep='-')%in%nonprogressive.ids))
#  print(paste("excluded", length(nonprogressive.ids), "out of", length(all.ids),"trials"))
#  return(progressive)
#}

# a probably more efficient version
#progressiveTrial <- function(data, rois) {
#	trials <- uniqe(data[data%in%rois & FFP==1,c('subject', 'trial')])
#	return(subset(data, subject==trials$subject & trial==trials$trial))
#}

#nonprogressiveTrials <- function(d, rois) {
#  nonprogressive <- subset(d, roi%in%rois & (FFP==0 | is.na(FFP)))
#  nonprogressive.ids <- with(nonprogressive, unique(paste(subject, trial, sep='-')))
#  nonprogressive <- subset(d, (paste(subject, trial, sep='-')%in%nonprogressive.ids))
#  print(paste("kept", length(nonprogressive.ids), "trials"))
#  return(nonprogressive)
#}

#no.na <- function(x){x[is.na(x)] <- 0; return(x);}
#no.zero <- function(x){x[x==0] <- NA; return(x);}

#dapply <- function(VAL, IDX, fun) {
#  stopifnot(!is.null(names(VAL)))
#  stopifnot(!is.null(names(IDX)))
#  ret <- data.frame()
#  for(i in 1:length(VAL)) {
#    cur.ret <- melt(tapply(VAL[[i]], IDX, fun))
#    cur.ret$variable <-  names(VAL)[i]
#    ret <- rbind(ret, subset(cur.ret, !is.na(value)))
#  }
#  return(ret)
#}


## melt, cast, and melt again
#rerecast <- function(data, id.var, measure.var, variable_name, formula, fun.aggregate) {
#  data <- melt.data.frame(data, id.var=id.var, measure.var=measure.var, variable_name=variable_name)
#  data <- cast(data=data, formula=deparse(formula), fun.aggregate=fun.aggregate)
#  data <- melt.data.frame(data, id.var=id.var, measure.var=measure.var, variable_name=variable_name)  
#  return(data)
#}

#grade <- function(x) {floor((6*(1-pmin(x,1))+1)*3)/3}
#
#
#mean.se <- function(x) paste(round(mean(x)), ' (', round(se(x)), ')', sep="")
#mean.2se <- function(x) paste(round(mean(x)), ' (', round(2*se(x)), ')', sep="")
#
#mean.2se.n <- function(x) paste(round(mean(x)), ' (', round(2*se(x)),', n=', length(x), ')', sep="")


#TOST <- function(mean1, mean2, theta, n1, n2, sigma) {
#  d <- (mean2 - mean1) 
#  t1 <- (d - theta)/(sigma * (sqrt((1/n1) + (1/n2))))
#  t2 <- (d + theta)/(sigma * (sqrt((1/n1) + (1/n2))))
#  tcrit <- qt(0.95, (n1 + n2 - 2))
#  if ((t1 < -tcrit) && (t2 > tcrit)) {
#    print(t1) 
#    print(t2) 
#    print(tcrit) 
#    print(c("Equivalent"))
#   } else{ 
#    print(c("Failed to show equivalence"))
#   }
#}



#mean.se.simple <- function(RT, subject, condition) {
#
# aggregate(list(RT=RT), list(condition=condition), function(x) c(M=mean(x), SE=se(x), N=length(x)))
#  M <- tapply(RT, condition, mean)
#  SE <- tapply(RT, condition, se)
#  N <- tapply(RT, condition, length)
#}


#mean.se.cousineau <- function(RT, subject, condition, conditions.cnt=0) {
#  # library(plyr, warn.conflicts=TRUE)
#  # library(reshape, warn.conflicts=TRUE)
#  if(conditions.cnt == 0) 
#  	conditions.cnt = length(unique(condition))
#  correction <- conditions.cnt/(conditions.cnt-1)
#
#  d <- data.frame(RT, subject, condition)
#  d$GM <- mean(tapply(RT, asc(subject), mean))
#  
#  d <- plyr::ddply(d, .(asc(subject)), transform, RT.w = RT - mean(RT) + GM)
#  temp <- reshape::melt.data.frame(d, id.var=c("subject","condition"), measure.var="RT.w")
#  (M.id.w <- reshape::cast(temp, condition  ~ .,
#          function(x) { cur.var <- var(x)*correction;
#                            c(M=mean(x), SE=sqrt(cur.var/length(x)), N=length(x) )
#                }))
#}

#mean.se.cousineau.proportion.buggy <- function (DV, subject, condition, conditions.cnt=0) {
#    library(plyr)
#    library(reshape)
#    if(conditions.cnt == 0) 
#  	conditions.cnt = length(unique(condition))
#    correction <- conditions.cnt/(conditions.cnt-1)
#
#    d <- data.frame(DV, subject, condition)
#    d$GM <- mean(tapply(DV, asc(subject), mean))
#    
#    d$subject <- as.character(d$subject)
#    d <- plyr::ddply(d, c("subject"), transform, DV.w = DV - mean(DV) + GM)
#    temp <- reshape::melt(d, id.var = c("subject", "condition"), measure.var = "DV.w")
#    (M.id.w <- reshape::cast(temp, condition ~ ., function(x) {
#        cur.var <- mean(x)*(1-mean(x))*correction
#        c(M = mean(x), SE = sqrt(cur.var/length(x)), N = length(x))
#    }))
#}


#mean.se.cousineau.proportion <- function (DV, subject, condition, conditions.cnt=0) {
#  library(plyr)
#  library(reshape)
#  library(dplyr)
#  library(magrittr)
#
#  if(conditions.cnt == 0) 
#    conditions.cnt = length(unique(condition))
#  correction <- conditions.cnt/(conditions.cnt-1)
#  
#  d <- data.frame(DV, subject, condition)
#  d$GM <- mean(tapply(DV, asc(subject), mean))
#  
#  d$subject <- as.character(d$subject)
#  d %<>% dplyr::group_by_("subject") %>% mutate(DV.w = DV - mean(DV) + GM)
#  d %>% group_by(condition) %>% 
#        dplyr::summarize(M = mean(DV.w), 
#                        cur_var = M*(1-M)*correction,
#                        N = length(DV.w),
#                        SE = sqrt(cur_var/N)) %>%
#        dplyr::select(-cur_var) %>%
#        as.data.frame
#  
##  temp <- reshape::melt(d, id.var = c("subject", "condition"), measure.var = "DV.w")
##  (M.id.w <- reshape::cast(temp, condition ~ ., function(x) {
##    cur.var <- mean(x)*(1-mean(x))*correction
##    c(M = mean(x), SE = sqrt(cur.var/length(x)), N = length(x))
##  }))
#}


# mean.se.cousineau.proportion <- function (d, conditions_cnt=0, DV, subject, ...) {
#   library(dplyr)
#   library(magrittr)
#   #if(conditions.cnt == 0) # TODO
#   #  conditions.cnt = length(unique(condition))
#   correction <- conditions_cnt/(conditions_cnt-1)
# 
#   # remove between-subject variance
#   d$GM <- mean(tapply(d[[DV]], asc(d[[subject]]), mean, na.rm = T))
#   d %>% dplyr::group_by(subject) %>% mutate(DV_w = response_correct - mean(response_correct) + GM)
#   dplyr::group_by(d, subject) %>% mutate_( sprintf("DV_w = %s - mean(%s) + GM", DV, DV))
#   %>% as.data.frame
#   
#   x <- d %>% dplyr::group_by(subject) %>% mutate_( sprintf("DV_w = %s - mean(%s) + GM", DV, DV)) %>% as.data.frame
#   
#   d %>% dplyr::group_by_(...) %>% 
#         summarize(cur_var = mean(x)*(1-mean(x))*correction,
#                   M = mean(DV.w),
#                   N = sum(!is.na(DV.w)),
#                   SE = sqrt(cur.var/DV.w) 
#                   )
# }


#optim.to.precision <- function(start, optim.digits, control, ...)
#{
#  method = "Nelder-Mead"
#  if("method" %in% names(control))
#    method = control['method']
#  run.optim <- function(start) optim(par=start, method=method, control=control, ...)
#  res <- run.optim(start)
#  if(method == "SANN")
#    return(res)
#  old.cnt <- NULL
#  while(TRUE) {
#    old.value <- res$value
#    old.cnt <- paste(old.cnt, res$counts[['function']], sep=' ')
#    res <- run.optim(res$par)
#    if(is.na(optim.digits))
#      return(res)
#    if(round(old.value, optim.digits) == round(res$value, optim.digits)) {
#      res$counts[['function']]  <- paste(old.cnt, res$counts[['function']], sep=' ')
#      return(res)
#    }
#  }
#}


# TODO: Figure out how to treat missing data in this function
# TODO: Make sure this is strictly a within-participants design. Strange things happen to the means if
#       one tries to process two experiments at once, even if the experiment is used as a grouping factor in the group argument
se_cousineau <- function(df, n_conditions, subject, DV, group, is_proportion = NULL)
{
  stopifnot(!"avgDV" %in% colnames(df))
  subject_var <- substitute(subject) %>% deparse()
  DV <- substitute(DV) %>% deparse()
  
  subj_means <- df %>% group_by(.dots = subject_var) %>% dplyr::summarize(avgDV := mean(!!as.name(DV), na.rm = T))
  GM <- mean(subj_means$avgDV)
  df %<>% group_by(.dots = subject_var) %>% dplyr::mutate(nDV = !!as.name(DV) - mean(!!as.name(DV), na.rm = T) + GM )
  
  if (is.null(is_proportion)) {
    dv <- df[[DV]]
    dv_unique <- unique(dv)
    if ( is.logical(dv) || (length(dv_unique) == 2 && all(dv_unique %in% c(0,1))) ) {
      is_proportion <- TRUE
    } else {
      is_proportion <- FALSE
    }
  }
  
  var_correction_factor <- n_conditions/(n_conditions-1)
  df %>% group_by(.dots = group) %>%
    dplyr::summarize(M = mean(nDV, na.rm = T),
                     Var = ifelse(is_proportion, M*(1-M), var(nDV, na.rm = T)) * var_correction_factor,
                     #Var = var(nDV, na.rm = T) * var_correction_factor,
                     N = sum(!is.na(nDV)),
                     SE = sqrt(Var/N) )
}



# nunique <- function(x) length(unique(x))


# read_file <- function(fname) { readChar(fname, file.info(fname)$size) }


prob2odds_str <- function(p, round_from = 5) {
  odds <- p/(1-p)
  odds_inv <- odds <= 1
  odds_round <- (odds >= round_from) | (odds <= 1/round_from)
  odds <- ifelse(odds_inv, 1/odds, odds)
  odds <- ifelse(odds_round, round(odds), odds)
  template <- ifelse(odds_inv, 
                     ifelse(odds_round, "1:%0.0f", "1:%0.1f"), 
                     ifelse(odds_round, "%0.0f:1", "%0.1f:1"))
  sapply(seq_along(template), function(i) { sprintf(template[i], odds[i]) })
}


prob_str <- function(p, gtst = 0.001) {
  if (p < .001) {
      str <- "< .001"
  } else if (p > .999) {
    str <- "> .999"
  } else if (p > .99 | p < .01 ) {
    str <- sprintf("  %.3f", p) %>% gsub("0\\.", ".", .)
  } else {
    str <- sprintf("   %.2f", p) %>% gsub("0\\.", ".", .)
  }
  str
}


model_summary <- function(m, include_pp_below_zero = T, transformations = NULL)
{
  # extract posterior samples
  samples <- brms::posterior_samples(m)
  
  # perform any transformations, if applicable
  if (!is.null(transformations)) {
    for (i in 1:length(transformations)) {
      samples[,names(transformations)[i]] <- with(samples, eval(parse(text = transformations[[i]] )) )
    }
  }
  
  # keep only fixed effects and transformed variables
  cnames_keep <- rownames(fixef(m))[-1] %>% paste0("b_", .) %>% c( names(transformations) )
  samples %<>% .[,cnames_keep]
  
  # convert to structure of class mcmc
  samples_mcmc <- as.mcmc(samples)
  
  # create table of coefficients and credible intervals
  tbl80 <- coda::HPDinterval(samples_mcmc, prob = .80) %>% as.data.frame() %T>% {colnames(.) %<>% paste0("80") }
  tbl95 <- coda::HPDinterval(samples_mcmc, prob = .95) %>% as.data.frame()
  tbl <- cbind(tbl80, tbl95)
  tbl$Estimate <- sapply(samples, mean)
  tbl$coef <- rownames(tbl) %>% gsub("^b_", "", .)
  tbl %<>% dplyr::select(coef, Estimate, lower, lower80, upper80, upper)
  
  if (include_pp_below_zero) {
    
    pref_coef_stats_df <- function(df, name) {
      df %>% as.data.frame(colnames = "x") %T>% 
        { colnames(.) <- name } %T>%
        { .$coef <- rownames(.) %>% gsub("^b_", "", .) }
    }
    
    p_below_zero <- samples %>% sapply(function(x) mean(x < 0)) %>% 
      pref_coef_stats_df("PBelowZero")
    tbl %<>% left_join(p_below_zero, by = "coef")
    
    p_below_zero_str <- samples %>% sapply(function(x) mean(x < 0) %>% prob_str()) %>% 
      pref_coef_stats_df("PBelowZeroStr")
    tbl %<>% left_join(p_below_zero_str, by = "coef")
    
    p_above_zero <- samples %>% sapply(function(x) mean(x > 0)) %>% 
      pref_coef_stats_df("PAboveZero")
    tbl %<>% left_join(p_above_zero, by = "coef")
    
    p_above_zero_str <- samples %>% sapply(function(x) mean(x > 0) %>% prob_str()) %>% 
      pref_coef_stats_df("PAboveZeroStr")
    tbl %<>% left_join(p_above_zero_str, by = "coef")
    
  }
  
  tbl
}

# TODO: In addition to label_max_width, add another argument, strip_label_max_terms,
#       which inserts a line break on a by-term basis
#       Alternatively, write a labeller, which finds the closest interaction symbol next to 
#       the character maximum, and breaks there.
create_model_coefs_plot <- function(m, 
                                    interaction_panels = c(), 
                                    strip_label_max_characters = NULL, 
                                    map_names = NULL,
                                    exclude_names = NULL,
                                    plot_stats = FALSE, 
                                    expand_right = 1, 
                                    expand_top = 1,
                                    x_stat_adjust = 0,
                                    transformations = NULL)
{
  interaction_symbol <- " * "
  use_interaction_panels <- length(interaction_panels) > 0
  
  if ( "brmsfit" %in% class(m) ) {
    tbl <- model_summary( m, transformations = transformations #, include_pp_below_zero = plot_stats 
    )
    
  } else if (is.list(m)) {
    stopifnot( length(names(m)) == length(unique(names(m))) )
    
    tbl <- ldply(seq_along(m), function(i) { 
      tbl <- model_summary( m[[i]], transformations = transformations #, include_pp_below_zero = plot_stats 
      )
      tbl$model <- names(m)[i]
      tbl
    })
    tbl$model %<>% factor( levels = names(m) )
    tbl
    
  } else {
    stop("Unknown model format.")
  }
  tbl %<>% subset(!coef %in% exclude_names)
  
  # rename some rows 
  if (length(map_names) > 0) {
    for (i in seq_along(map_names)) {
      idx <- which(tbl$coef == names(map_names)[i])
      if (length(idx) > 0) {
        if (map_names[i] == "") {
          tbl <- tbl[-idx,]
        } else {
          tbl$coef[idx] <- map_names[i]
        }
      }
    }
  }
  
  if (use_interaction_panels) {
    tbl$interaction <- ""
  }
  for (cur_interaction in interaction_panels) {
    cur_interaction_term1 <- paste0(cur_interaction,":")
    cur_interaction_term2 <- paste0(":",cur_interaction)
    
    is_target_interaction <- grepl(cur_interaction_term1, tbl$coef) | grepl(cur_interaction_term2, tbl$coef)
    
    tbl$coef[is_target_interaction] %<>% gsub(cur_interaction_term1, "", .) %>% 
      gsub(cur_interaction_term2, "", .)
    
    tbl$interaction[is_target_interaction] <- paste0(cur_interaction, interaction_symbol, "...")
  }
  
  # replace interaction symbol if necessary
  if (interaction_symbol != ":") {
    tbl$coef %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
    
    if (use_interaction_panels)
      tbl$interaction %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
  }
  coefs_order <- c(rev(map_names), rev(tbl$coef)) %>% unique() # %>% rev()
  tbl$coef %<>% factor(levels = coefs_order)
  #tbl$coef %<>% factor(levels = tbl$coef %>% unique %>% rev())
  
  # plot
  p <- ggplot(tbl, aes(Estimate, coef)) + geom_point() + 
    geom_errorbarh(aes(xmin = lower, xmax = upper), height=0) + 
    geom_errorbarh(aes(xmin = lower80, xmax = upper80), size = 1.5, height=0) + 
    geom_vline(xintercept = 0, color = "grey")
  
  if (plot_stats)
  {
    tbl$xmax <- with(tbl, max(c(Estimate, lower, upper))) + x_stat_adjust
    
    p <- p + scale_y_discrete(expand = expand_scale(mult = c(.05, .15*expand_top), add = c(0, 0)) )
    p <- p + scale_x_continuous(expand = expand_scale(mult = c(.05, .15*expand_right),  add = c(0, 0)) )
    
    p <- p + geom_text(aes(x = tbl$xmax, y = tbl$coef, label = sprintf("[%s]", tbl$PBelowZeroStr)), 
                       family = "mono", hjust = "left")
    
    suppressWarnings({
      p <-  p + geom_text(x = tbl$xmax[1], y = max(as.integer(tbl$coef))+1, 
                          # label = "P( < 0)", 
                          label = parse(text = "paste('P(', theta, ' < 0)')"),
                          family = "mono", hjust = "left")#, fontface = "bold")
    })
  }
  
  if (use_interaction_panels) {
    p <- p + facet_wrap(~ interaction, strip.position = "left", ncol = 1, scales = "free_y")
    if (!is.null(strip_label_max_characters))
      p <- p + label_wrap_gen(width = strip_label_max_characters)
  }
  
  if ( !is.null(tbl$model) ) {
    p <- p + facet_wrap(~model)
  }
  
  p <- p + theme_bw() + 
    theme(panel.border = element_blank(), 
          axis.ticks.y = element_blank(),
          #strip.text.x = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          strip.placement = "outside") +
    ylab("")
  
  attr(p, "model_summary") <- tbl
  
  return (p)
}