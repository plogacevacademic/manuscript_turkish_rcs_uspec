source(file.path(dir_base, "scripts/misc.R"))

suppressPackageStartupMessages({
  library(plyr)
  library(dplyr)
  library(magrittr)
})

condition_info <- 
  data.frame( condition  = c('a',  'b',  'c',  'd',  'e',  'f'),
              N1_number = c('pl', 'sg', 'pl', 'pl', 'sg', 'pl'),
              N2_number = c('pl', 'pl', 'sg', 'pl', 'pl', 'sg'),
              modifier   = c('rc', 'rc', 'rc', 'adj','adj','adj') %>% factor(levels = c("rc", "adj")),
              attachment = rep(c('ambiguous', 'n2', 'n1'), 2)
            )
condition_info$nps <- with(condition_info, paste(N1_number, N2_number))

load_SPR1 <- function()
{
    # determine the file names of the data files
    data_path <- file.path(dir_base, "data/experiment_spr/Experiments/TurkishRCs/Results")
    fnames <- dir(data_path, pattern = "*.dat", full.names = TRUE)
    
    # read data
    data <- ldply(fnames, function(fname) read.table(fname, as.is=T) )
    colnames(data) <- c('subject','experiment','item','condition','pos', 'word', 'resp', 'RT')
    data = subset(data, subject != 1)
    
    # extract experimental sentences
    data_all <- data %>% subset(experiment != "practice")
    data_rc <- subset(data, experiment == "RC-attachment")
    data_fillers <- subset(data, experiment == "fillers")
    
    # split reading times and responses
    reading_rc <- subset(data_rc, pos != "?")
    questions_rc <- subset(data_rc, pos == "?")
    reading_fillers <- subset(data_fillers, pos != "?")
    questions_fillers <- subset(data_fillers, pos == "?")
    reading_rc$pos <- asic(reading_rc$pos) 

    # find the comma in each sentence
    words <- asc(unique(reading_rc$word)) %>% data.frame(word = ., stringsAsFactors = FALSE)
    words$with_comma <- sapply(words$word, function(word) "," %in% strsplit(word, "")[[1]])
    words$wlen <- stringr::str_length(words$word)
    reading_rc %<>% left_join(words, by = "word")

    # align positions by comma
    reading_rc <- ddply(reading_rc, .(subject, experiment, item, condition), function(d) {
      d$pos <- d$pos - d$pos[d$with_comma]
      d
    })
    
    reading_rc %<>% left_join(condition_info, by = "condition")
    reading_rc_rc = subset(reading_rc, modifier == "rc")
    reading_rc_adj = subset(reading_rc, modifier == "adj")

    # the RC in items 112, 205, 301, and 506 comprises 3 words: sum the RTs for the last two
    reading_rc_rc %<>% ddply(.(subject, item), function(d) {
      if(d$item[1] %in% c(112, 205, 301, 506)) {
        idx0 = which(d$pos == 2)
        d$word[idx0] = paste(d$word[idx0+c(0,1)], collapse=" ")
        d$RT[idx0] = sum(d$RT[idx0+c(0,1)])
        d = d[-(idx0+1),]
        d$pos = ifelse(d$pos > 2, d$pos-1, d$pos)
      }
      d
    })

    suppressWarnings({
      reading_rc_rc$posLabel <-
        reading_rc_rc$pos %>% dplyr::recode('1'='(reflexive)', '2'='V/Adj', '3'='N1', '4'='N2','5'='spillover','6'='spillover+1', .default = NULL)
      reading_rc_adj$posLabel <-
        reading_rc_adj$pos %>% dplyr::recode('1'='V/Adj', '2'='N1', '3'='N2','4'='spillover','5'='spillover+1')
    })
    reading_rc = rbind(reading_rc_rc, reading_rc_adj)
    
    len.n1.sg = subset(reading_rc, posLabel=="N1" & N1_number=="sg") %>% group_by(item) %>% dplyr::summarize( wlen.n1.sg = stringr::str_length(word[1]), .groups = "drop")
    reading_rc %<>% left_join(len.n1.sg, by = "item")
    len.n2.sg = subset(reading_rc, posLabel=="N2" & N2_number=="sg") %>% group_by(item) %>% dplyr::summarize( wlen.n2.sg = stringr::str_length(word[1]), .groups = "drop")
    reading_rc %<>% left_join(len.n2.sg, by = "item")
    
    critical_posLabels = c('V/Adj', 'N1', 'N2', 'spillover', 'spillover+1')
    reading_rc_critical = subset(reading_rc, posLabel %in% critical_posLabels)
    reading_rc_critical$posLabel = ordered(reading_rc_critical$posLabel, levels = critical_posLabels)
    
    list(reading_rc = reading_rc_critical, 
         questions_rc = questions_rc, 
         reading_fillers = questions_fillers, 
         questions_fillers = questions_fillers)
}

