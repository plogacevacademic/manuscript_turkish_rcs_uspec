
df_bf_eye$measure %<>% dplyr::recode("FPRT"="First Pass Reading\nTime", "RPD"="Regression Path\nDuration", "TFT"="Total Fixation\nTime", "regression"="First-pass\nRegressions")

p <- df_bf_eye  %>% ggplot(aes( prior_width, V1, color = measure)) + geom_point() + geom_line() + facet_wrap(~region)
p <- p + scale_x_continuous(limits = c(0.0, 1.1), breaks = c(.1, .25, .5, .75, 1), labels = c("1/10", "1/4", "1/2", "3/4", "1"))

p <- p + xlab("prior width") + ylab("BF₀₁") + geom_hline(yintercept = 1, color = "red", linetype = "dotted")

p <- p + theme_bw() + theme(legend.position='top') + 
  theme( strip.background = element_rect(fill="white") ) +
  guides( colour = guide_legend(title = NULL, nrow=1, byrow=TRUE) )

steps <- c(2, 4) #5, 20, 
p <- p + scale_y_log10(limits = c(1/4, 4), breaks = c(1/steps, 1, steps), labels = c(paste0("1/", steps), 1, steps) )

ggsave(p, file = fname_bfs, height = 4.0, device = cairo_pdf)
