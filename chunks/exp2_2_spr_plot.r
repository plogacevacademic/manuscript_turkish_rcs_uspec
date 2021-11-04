
new_pos_labels = c('V/Adj'='pre-critical', 
                   'N1'='noun 1', 
                   'N2'='noun 2', 
                   'spillover'='spill-over')
new_attachment_labels = c("ambiguous"="ambiguous", 
                          "n1"="N1 attachment",
                          "n2"="N2 attachment")

mrt$posLabel %<>% as.character %>% dplyr::recode(!!!new_pos_labels)
mrt$posLabel %<>% ordered(levels=new_pos_labels)
#mrt$M.SE <- with(mrt, sprintf("%.0f (%.0f)", M, SE))
mrt$modifier %<>% as.character %>% dplyr::recode('rc'='rc', 'adj'='control')

mrt$attachment %<>% dplyr::recode(!!!new_attachment_labels) %>% factor(levels=new_attachment_labels)
mrt$modifier %<>% as.character %>% factor(levels = c("rc", "control"))

dodge <- position_dodge(width = .5)
p <- ggplot(mrt, aes(attachment, M, group=attachment:modifier,
                     color=attachment, linetype=modifier)) + 
  geom_point(aes(shape=modifier), position = dodge) + #geom_line() + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2, position = dodge) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  ylab("Reading Time") + xlab("") +
  facet_wrap(~posLabel, nrow = 1) + 
  theme(  strip.background =element_rect(fill="white") ) + 
  scale_x_discrete(labels = NULL, breaks = NULL) + 
  theme(legend.position='top')
p <- p + scale_color_discrete(name="") + scale_linetype_discrete(name="") + scale_shape_discrete(name="")

ggsave(p, file = fname_spr_rts, height = 3, width = 6)
