
source("../scripts/load_spr.R")

spr1_res <- load_SPR()
reading_rc <- spr1_res$reading_rc %<>% subset(posLabel %in% c('V/Adj','N1','N2','spillover'))

length(unique(spr1_res$reading_rc$subject))-36

# represent as factors
reading_rc %<>% mutate(subject = subject %>% as.factor(),
                       item = item %>% as.factor(),
                       nps = nps %>% ordered(levels = c('sg pl','pl pl','pl sg'))
)

reading_rc %<>% within({
  clWlen <- scale(log(wlen))[,1]
  clWlen.n1.sg <- scale(log(wlen.n1.sg))[,1]
  clWlen.n2.sg <- scale(log(wlen.n2.sg))[,1]
})

length(unique(reading_rc$subject))

# check the distribution of experimental lists
reading_rc %>% subset(posLabel == "N1" & item == 101) %>% with(., table(collection_method, condition))

# detect trials with outliers
reading_rc %<>% group_by(subject, item) %>% 
  dplyr::mutate(any_too_short = any(RT < 150),
                any_too_long = any(RT > 3000),
                any_outlier = any_too_short | any_too_long
  )
with(reading_rc, mean(any_too_long))
with(reading_rc, mean(any_too_short))
with(reading_rc, mean(any_outlier))
with(reading_rc, sum(any_outlier))/4
nrow(reading_rc)/4

reading_rc %>% group_by(subject) %>%
  dplyr::summarise( avg_outlier_trials = mean( any_outlier ), avg_too_short = mean(any_too_short), avg_too_long = mean(any_too_long)  ) %>%
  arrange( desc(avg_outlier_trials) )
# excluding "S_ibex[1]" because their reading times are mostly ~40-50ms

tail(spr1_res$questions_rc)

suppressWarnings(
spr1_res$questions_rc %>% group_by(subject) %>% summarize(M1 = mean(!Field.value), M2 = mean(resp) ) %>% mutate(M = ifelse(is.na(M1), M2, M1)) %>% arrange(M)
)
# exclude S_ibex[1], S_ibex[38], and S_ibex[55] because their accuracy (on very simple questions) is <75% 


# exclude participants with accuracy below 75%
excluded_participants <- c("S_ibex[1]", "S_ibex[123]", "S_ibex[114]", "S_ibex[38]", "S_ibex[97]", "S_ibex[142]", "S_ibex[55]")
reading_rc %<>% subset( !subject %in% excluded_participants )

# exclude trials with outliers
reading_rc %<>% subset( !any_outlier )

# calculate average RTs
mrt <- plyr::ddply(reading_rc, .(posLabel), function(d) {
  d$log_RT <- log(d$RT)
  se_cousineau(d, n_conditions=6, subject, log_RT, group = c("modifier", "attachment"), is_proportion = FALSE) %T>% 
    {.$upper <- exp(.$M + 1.96*.$SE); .$lower <- exp(.$M - 1.96*.$SE); .$M <- exp(.$M); .$SE <- NULL} %>%
    dplyr::select(-Var)
})
