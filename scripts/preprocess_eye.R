
library(plyr)
library(dplyr)
library(magrittr)
library(ggplot2)
library(tidyverse)
library(magrittr)

options(warn=1)
source("../scripts/misc.R")
source("../scripts/preprocess_eye_coordinate_correction.R")


x <- read.csv("../data/experiment_eye/FixationDuration-RC-SPSS.txt", sep="\t")

labels <- c("Subject",
            "Trial", "Stimulus", "Fixation_start_.ms.", "Fixation_duration_.ms.",
            "Fixation_end_.ms.", "Fixation_Position_XY_X", "Fixation_Position_XY_Y",
            "X_word", "Reading_AOI_number", "Reading_direction", "Eye")

res <- ldply(0:813, function(idx) {
  cur_labels <- labels
  if (idx != 0) {
    cur_labels[-1] %<>% paste(., '_', idx, sep='')
  }
  cur_df <- x[,cur_labels]
  colnames(cur_df) <- labels
  cbind(idx=idx, cur_df)
})

colnames(res) %<>% dplyr::recode( !!!c("Fixation_start_.ms."="start", "Fixation_duration_.ms."="dur",
                                       "Fixation_end_.ms."="end", "Fixation_Position_XY_X"="pos.x", "Fixation_Position_XY_Y"="pos.y",
                                       "X_word"="word", "Reading_AOI_number"="rid", "Reading_direction"="direction", "Eye"="eye") )
res %<>% arrange(Subject, idx, Trial)
res %<>% subset(!is.na(Trial) & Trial != "")

approximate_aois <- res %>% subset(!is.na(rid)) %>%
  group_by(Stimulus, rid, word) %>% 
  dplyr::summarize( min_x = min(pos.x), max_x = max(pos.x),
                    min_y = min(pos.y), max_y = max(pos.y)) %>%
  subset( max_y < 600 ) %>%
  ungroup() %>% mutate( min_y = min(min_y), max_y = min(max_y) )

# # widen AOIs
# approximate_aois$min_y <- 416 - 2*30 # 385
# approximate_aois$max_y <- 449 + 2*30 # 480


pick_nth_element <- function(x, n) x %>% as.character %>% stringr::str_split("-") %>% sapply(function(x) x[n])
approximate_aois$experiment = pick_nth_element(approximate_aois$Stimulus, n = 1)
approximate_aois$attachment = pick_nth_element(approximate_aois$Stimulus, n = 2) %>%
                              dplyr::recode("n1forced"="N1 attachment",
                                            "n2forced"="N2 attachment",
                                            "nonforced"="ambiguous")
approximate_aois$animacy = pick_nth_element(approximate_aois$Stimulus, n = 3)
approximate_aois$wlen = sapply(strsplit(as.character(approximate_aois$word), ""), function(x) {length(x)} )

# extract stimuli from the data in the eye movement record
stimuli = unique( approximate_aois[,c('Stimulus','rid','word','attachment','animacy','wlen')] )
stimuli %<>% arrange(Stimulus, rid)

# determine the length of the preceding word
stimuli %<>% group_by(attachment, Stimulus) %>%
              mutate(prev_wlen = lag(wlen, n=1),
                     next_wlen = c(wlen[-1], NA)
                    ) %>%
              ungroup()


all_fixations_path <- dir("../data/experiment_eye/RC-eventdata-export/", full.names = T)
ids <- basename(all_fixations_path) %>% gsub("^RC[_-]Attachment-Exp_", "", .) %>% gsub("Events.txt$", "", .)
all_fixations_fnames <- data.frame(path = all_fixations_path, id = ids) %>% 
                          subset(!grepl("(.txt|.rtf)$", id)) %>%
                          subset(!grepl("^RC_Attachment", id)) %>%
                          subset(!id %in% c("OA_canan_019_Trial003", "OA_Ozgur Aydin_018_Trial003") )
x <- stringr::str_split_fixed(all_fixations_fnames$id, pattern = "_", n = 3)
all_fixations_fnames$Subject <- x[,1] %>% stringr::str_trim()
all_fixations_fnames$XX <- x[,2] %>% stringr::str_trim()
all_fixations_fnames$Trial <- x[,3] %>% stringr::str_trim()

# # to-do:
# nrow(all_fix_fnames)
# nrow(select(all_fix_fnames, Subject, Trial))

colnames <- c("Eye", "Trial", "Number", "Start", "End", "Duration", "Location_X", "Location_Y", "Dispersion_X", "Dispersion_Y", "Plane", "Avg_Pupil_Size_X", "Avg_Pupil_Size_Y")
# to-do: Why do I need XX in grouping? -- Why are there repetitions of trial within subject?? 
fixations_raw <-
  plyr::ddply(all_fixations_fnames, .(Subject, XX, Trial), function(df) {
    x <- readLines(df$path) %>% .[grepl("^Fixation", .)] %>% gsub("^Fixation ", "", .) %>% paste(collapse = "\n")
    res <- x %>% read.delim(text = ., header = F, col.names = colnames)
    res$Trial <- NULL
    res
  }, .progress = "text")

fixations_raw %<>% dplyr::select(-Number, -Plane, -Avg_Pupil_Size_X, -Avg_Pupil_Size_Y, -Dispersion_X, -Dispersion_Y) %>% dplyr::mutate(Duration = Duration/1000, Start=Start/1000, End=End/1000 )
simulus_mapping <- res %>% dplyr::select(Subject, Trial, Stimulus) %>% unique()
fixations_raw %<>% left_join( simulus_mapping )
fixations_raw %<>% subset(!is.na(Stimulus))

fixations_raw_L <- subset(fixations_raw, Eye == "L") 
fixations_raw_R <- subset(fixations_raw, Eye == "R") 


### settings for coordinate correction ###

max_y <- max(approximate_aois$max_y)
min_y <- min(approximate_aois$min_y)
y_screen_center <- (max_y + min_y)/2
width_line_y <- max_y - min_y
x_screen_max <- max(fixations_raw$Location_X, na.rm = T)
y_screen_max <- max(fixations_raw$Location_Y, na.rm = T)


corrected_fixations <-
  ddply(fixations_raw_L, .(Subject, Trial), function(cur_fixations) {
    corrected_fixations_on_line(cur_fixations, y_screen_center, y_screen_min=0, y_screen_max)
  }, .progress = "text")

head(corrected_fixations)

mapped_fixations <-
  ddply(corrected_fixations, .(Subject, Trial), function(cur_fixations)
  {
      #cat(cur_fixations$Subject[1], " ", cur_fixations$Trial[1], "\n")

      cur_aois <- approximate_aois %>% subset(Stimulus == cur_fixations$Stimulus[1])
      # cur_fixations %<>% subset(Location_Y < cur_aois$max_y[1] & Location_Y > cur_aois$min_y[1])
      
      if (nrow(cur_fixations) == 0 ) {
          NULL
      } else {
          cur_fixations$rid <- sapply(1:nrow(cur_fixations), function(i) { x <- which( with(cur_fixations[i,], with(cur_aois, Location_X < max_x & Location_X > min_x ))); ifelse(is.null(x), NA, x) } )
          cur_fixations
      }
  }, .progress = "text")

mapped_fixations %<>% left_join( approximate_aois %>% dplyr::select(Stimulus, rid, word) )


library(em2)

d <- mapped_fixations %>% subset(!is.na(rid)) %>% dplyr::rename(subject=Subject, trial=Trial, stimulus=Stimulus)

# generate standard measures
dm <- with(d, em2(rid = rid, fixationdur = Duration, 
                  #trialId=list(subj, Trial),
                  trialinfo = d[,c("subject","trial","stimulus")]
))

head(dm)

dm %<>% left_join( approximate_aois %>% dplyr::select(stimulus=Stimulus, experiment, roi=rid, word,attachment, animacy,word) %>% unique() )
dm %<>% left_join( stimuli %>% dplyr::select(stimulus=Stimulus, roi=rid, wlen, prev_wlen, next_wlen) %>% unique() )

# to-do: find out why there are instances of word being NA
dm %<>% subset(!is.na(word))
dm %<>% dplyr::rename(rid = roi)
crit_em_rc <- dm

roiLabels = c('2'='pre-critical','3'='N1','4'='N2','5'='spillover') #'1'='first',
crit_em_rc$rid %>% dplyr::recode(!!!roiLabels) -> crit_em_rc$roiLabel
crit_em_rc$roiLabel %<>% ordered(levels=roiLabels) %>% droplevels()
crit_em_rc$subj %<>% as.factor()

# drop all irrelevant regions
crit_em_rc %<>% subset( experiment == "rc" )

# drop all irrelevant regions
crit_em_rc %<>% subset( !is.na(roiLabel) )

write.csv(crit_em_rc, file = "../data/Experiment_Eye/corrected_data_em.csv", row.names = F)
