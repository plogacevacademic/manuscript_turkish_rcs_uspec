
crit_em_rc %<>% mutate(log_FPRT = log(FPRT), log_RPD = log(RPD), log_TFT = log(TFT) )

fprt <- subset(crit_em_rc, FPRT!=0) %>% 
        se_cousineau_bygroup( bygroup = "roiLabel", n_conditions=3, subject = subj, 
                              DV = log_FPRT, group = "attachment", is_proportion = F)
rpd <- subset(crit_em_rc, RPD!=0) %>% 
       se_cousineau_bygroup( bygroup = "roiLabel", n_conditions=3, subject = subj, 
                              DV = log_RPD, "attachment", is_proportion = F)
tft <- subset(crit_em_rc, TFT!=0) %>% 
       se_cousineau_bygroup( bygroup = "roiLabel", n_conditions=3, subject = subj, 
                             DV = log_TFT, "attachment", is_proportion = F)

crit_em_rc %<>% mutate( RBR = as.logical(RBRC) )
rp <- subset(crit_em_rc, FFP==1) %>% 
      se_cousineau_bygroup( bygroup = "roiLabel", n_conditions=3, subject = subj, 
                            DV = regression, "attachment", is_proportion = T)

RTs = rbind(cbind(fprt, measure="fprt"), 
            cbind(rpd, measure="rpd"), 
            cbind(tft, measure="tft"))

###


RTs %<>% dplyr::mutate(lower = exp(M-1.96*SE), upper = exp(M+1.96*SE), M = exp(M)) %>%
          dplyr::select(measure, roiLabel, attachment, M) #, lower, upper)

rp %<>% dplyr::mutate(lower = M-1.96*SE, upper = M+1.96*SE) %>%
        dplyr::select(roiLabel, attachment, M) #, lower, upper)

eye_emmeans$roiLabel %<>% dplyr::recode("np1"="N1", "np2"="N2", "precrit"="pre-critical")

emm_rts <- eye_emmeans %>% 
                 subset(measure != "rp") %>% 
                 dplyr::mutate(M=exp(emmean), lower=exp(lower.HPD), upper=exp(upper.HPD)) %>%
                 dplyr::select(-emmean, -lower.HPD, -upper.HPD)

emm_rp <- eye_emmeans %>%
                subset(measure == "rp") %>% 
                dplyr::mutate(M=plogis(emmean), lower=plogis(lower.HPD), upper=plogis(upper.HPD)) %>%
                dplyr::select(-emmean, -lower.HPD, -upper.HPD)


RTs$variable <- "average"
rp$variable <- "average"
emm_rts$variable <- "estimated marginal mean"
emm_rp$variable <- "estimated marginal mean"

RTs %<>% dplyr::bind_rows( emm_rts )
rp %<>% dplyr::bind_rows( emm_rp  %>% dplyr::select(-measure) )


RTs$measure %<>% dplyr::recode("fprt"="First Pass\nReading Time", "rpd"="Regression\nPath Duration", "tft"="Total Fixation\nTime")

# pos_dodge = position_dodge(width = .5)
RTs$attachment %<>% as.factor
RTs$variable %<>% as.factor
p_avg_rt_exp1 <- RTs  %>% subset(variable != "average") %>% ggplot(aes(attachment, M, group = paste(attachment, variable), color = attachment)) + #, shape = variable 
  #geom_point(data = RTs  %>% subset(variable == "average"), color = "black") + 
  geom_point() + 
  geom_errorbar(aes(ymin=lower, ymax=upper), width = 0.2) + 
  ylab("Reading Time") + xlab("") +
  facet_grid(measure ~ roiLabel, scales = "free_y") + 
  scale_y_continuous(breaks = seq(200, 500, by=25)) +
  scale_x_discrete(labels = NULL, breaks = NULL) +
  #scale_x_discrete(guide = guide_axis(angle = 45)) + 
  theme(legend.position='top') + 
  theme(  strip.background = element_rect(fill="white") )


probs = cbind(rp, measure="First-pass\nRegressions")

probs$attachment %<>% as.factor 
probs$variable %<>% as.factor
p_avg_prob_exp1 <- probs %>% subset(variable != "average") %>% ggplot(aes(attachment, M, group = paste(attachment, variable), color = attachment)) + #, shape = variable 
  #geom_point(data = probs  %>% subset(variable == "average"), color = "black") + 
  geom_point() + 
  geom_errorbar(aes(ymin=lower, ymax=upper), width = 0.2) + 
  scale_y_continuous(labels = function(...) scales::percent(accuracy=1, ...) ) +
  ylab("% Regressions") + xlab("") +
  facet_grid(measure ~ roiLabel, scales = "free_y") + 
  scale_x_discrete(labels = NULL, breaks = NULL) +
  #scale_x_discrete(guide = guide_axis(angle = 45)) + 
  theme(legend.position='none') + 
  theme(  strip.background = element_rect(fill="white") )


p_avg_rt_exp1 <- p_avg_rt_exp1 + 
  theme(legend.position="top", legend.box="vertical", legend.margin=margin()) + 
  guides(colour = guide_legend(order = 2), shape = guide_legend(title = NULL, order = 1))

# print(p_avg_prob_exp2)
p_avgs <- ggarrange(p_avg_rt_exp1, p_avg_prob_exp1, ncol = 1, heights = c(2.5,1))

ggsave(p_avgs, file = fname_eye_rts, height = 7.0)
