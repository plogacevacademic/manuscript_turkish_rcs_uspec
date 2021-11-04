

spr_emmeans$modifier %<>% dplyr::recode("rc"="rc", "adj"="control")
spr_emmeans$attachment %<>% dplyr::recode("ambiguous"="ambiguous", "n1"="N1 attachment", "n2"="N2 attachment")
spr_emmeans$roiLabel %<>% dplyr::recode("np1"="noun 1", "np2"="noun 2", "precrit"="pre-critical", "spillover"="spill-over")
spr_emmeans %<>% dplyr::mutate(M=exp(emmean), lower=exp(lower.HPD), upper=exp(upper.HPD)) 

spr_emmeans$attachment %<>% as.factor()
spr_emmeans$modifier %<>% as.factor()

dodge <- position_dodge(width = .5)
p <- ggplot(spr_emmeans, aes(attachment, M, group=attachment:modifier,
                     color=attachment, linetype=modifier)) + 
  geom_point(aes(shape=modifier), position = dodge) + #geom_line() + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2, position = dodge) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  ylab("Reading Time") + xlab("") +
  facet_wrap(~roiLabel, nrow = 1) + 
  theme(  strip.background =element_rect(fill="white") ) + 
  scale_x_discrete(labels = NULL, breaks = NULL) + 
  theme(legend.position='top')

p <- p + scale_color_discrete(name="") + scale_linetype_discrete(name="") + scale_shape_discrete(name="")

p <- p +
  theme(legend.position="top", legend.box="horizontal", legend.margin=margin()) 
  # + 
  # guides(colour = guide_legend(order = 2), shape = guide_legend(title = NULL, order = 1))

ggsave(p, file = fname_spr_emms, height = 3, width = 6)
