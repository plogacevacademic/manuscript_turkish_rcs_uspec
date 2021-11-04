
crit_em_rc <- read.csv("../data/experiment_eye/corrected_data_em.csv")
crit_em_rc$roiLabel %<>% factor(levels = c("pre-critical", "N1", "N2", "spillover"))

crit_em_rc$subject %<>% as.factor()

crit_em_rc %<>% within({
  # compares the N2 attachment condition to the ambiguous condition
  attachment %>% recode_char2double( c('ambiguous'=-1/3, 'N2 attachment'=-1/3, 'N1 attachment'=2/3) ) -> cN1attachmentVsAmb
  # compares the N1 attachment condition to the ambiguous condition
  attachment %>% recode_char2double( c('ambiguous'=-1/3, 'N2 attachment'=2/3, 'N1 attachment'=-1/3) ) -> cN2attachmentVsAmb
  # compares the N2 attachment condition to the ambiguous and N1 conditions
  attachment %>% recode_char2double( c('ambiguous'=-.5, 'N2 attachment'=.5, 'N1 attachment'=-.5) ) -> cN2attachmentVsAmbN1
  
  clWlen <- scale(log(wlen))
  clPrevWlen <- scale(log(prev_wlen))
  clNextWlen <- scale(log(next_wlen))
  refixation = as.numeric(RRTR!=0)
  regression = as.numeric(as.logical(RBRC))
  fp_skip = as.numeric(FFP==0)
})