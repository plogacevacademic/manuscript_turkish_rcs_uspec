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

load_SPR_Linger <- function()
{
    # determine the file names of the data files
    data_path <- file.path(dir_base, "data/experiment_spr/Experiments/TurkishRCs/Results")
    fnames <- dir(data_path, pattern = "*.dat", full.names = TRUE)
    
    # read data
    data <- ldply(fnames, function(fname) read.table(fname, as.is=T) )
    colnames(data) <- c('subject','experiment','item','condition','pos', 'word', 'resp', 'RT')
    data = subset(data, subject != 1)
    data$subject <- data$subject %>% as.factor %>% as.integer %>% sprintf("S_lab[%d]", .)
    
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

    
load_SPR_PCIbex <- function()
{
  # determine the file names of the data files
  fnames <- dir( file.path(dir_base, "data/experiment_spr_online/results"), full.names = T )

  # read data
  col.names <- c("ReceptionTime", "MD5", "Controller", "Item", "Element", "Label", "Group", "Field name", "Field value", "X", "X2")
  df <- ldply(fnames, function(fname) read.csv(fname, col.names = col.names, header = F, comment = "#", encoding = "UTF-8") )

  # create subject column
  #df$age_field_index <- cumsum(df$Group == "age"), age_field_index
  df$subject <- with(df, paste(ReceptionTime, MD5)) %>% as.factor %>% as.integer %>% sprintf("S_ibex[%d]", .)
  df %<>% dplyr::select(-ReceptionTime, -MD5) # , -age_field_index

  # clean up the data
  df %<>% subset( !Element %in% c("intro", "practice"))
  
  # rename columns
  df %<>% dplyr::rename(exp = Element)
  df %<>% dplyr::rename(item = Label)
  df %<>% dplyr::rename(pos = Group)
  df %<>% dplyr::rename(word = Field.name)
  df %<>% dplyr::rename(sentence = X2)
  df %<>% mutate( item = as.integer(item) )
  
  # split ids into experiment and condition
  exp_condition <- df$exp %>% stringr::str_split_fixed(pattern = "_", n = 2)
  df$exp <- exp_condition[,1]
  df$condition <- exp_condition[,2]
  
  # split reading times and responses
  question <- subset(df, sentence == "") %>% dplyr::rename(RT = X)
  spr <- subset(df, sentence != "") %>% dplyr::rename(RT = Field.value)
  question %<>% mutate( RT = as.integer(RT) )
  spr %<>% mutate( RT = as.integer(RT) )
  
  # extract experimental sentences
  reading_fillers <- spr %>% subset(exp == "fillers")
  reading_rc <- spr %>% subset(exp == "rc")
  questions_fillers <- question %>% subset(exp == "fillers")
  questions_rc <- question %>% subset(exp == "rc")
  
  # find the comma in each sentence
  words <- asc(unique(reading_rc$word)) %>% data.frame(word = ., stringsAsFactors = FALSE)
  words$with_comma <- sapply(words$word, function(word) grepl("%2C", word))
  words$wlen <- stringr::str_length(words$word)
  reading_rc %<>% left_join(words, by = "word")
  
  # align positions by comma
  reading_rc$pos %<>% as.integer()
  reading_rc %<>% group_by(subject, exp, item, condition) %>% dplyr::mutate( pos = pos - pos[with_comma] )

  reading_rc %<>% left_join(condition_info, by = "condition")
  reading_rc_rc = subset(reading_rc, modifier == "rc")
  reading_rc_adj = subset(reading_rc, modifier == "adj")
  
  # the RC in items 112, 205, 301, and 506 comprises 3 words: sum the RTs for the last two
  reading_rc_rc %<>% plyr::ddply(c("subject", "item"), function(d) {
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


load_SPR <- function()
{
  lst_linger <- load_SPR_Linger()
  lst_ibex <- load_SPR_PCIbex()

  lst_linger %<>% plyr::llply(function(df) { df$collection_method = "lab" ; df })
  lst_ibex %<>% plyr::llply(function(df) { df$collection_method = "online" ; df })
  
  list(reading_rc = bind_rows(lst_linger$reading_rc, lst_ibex$reading_rc), 
       questions_rc = bind_rows(lst_linger$questions_rc, lst_ibex$questions_rc), 
       reading_fillers = bind_rows(lst_linger$reading_fillers, lst_ibex$reading_fillers), 
       questions_fillers = bind_rows(lst_linger$questions_fillers, lst_ibex$questions_fillers) 
       )
}
    
    