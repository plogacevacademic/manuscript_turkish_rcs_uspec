
{
df_bf_eye %<>% subset(measure != "regression")
df_bf_eye$measure_label <- df_bf_eye$measure %>% dplyr::recode("FPRT"="First Pass Reading Time", "RPD"="Regression Path Duration", "TFT"="Total Fixation Time", "regression"="First-pass\nRegressions")
df_bf_eye$region %<>% dplyr::recode("np2"="noun 2", "spillover"="spill-over")

p <- df_bf_eye  %>% ggplot(aes( prior_width, V1, color = measure_label)) 

p <- p + scale_x_continuous(breaks = c(.1, .2, .3, .4, .5, 1), labels = c(".02", ".04", ".06", ".08", ".1", ".2")) #limits = c(0.0, 1.1), # c("1/10", "1/4", "1/2", "1")
p <- p + geom_point() + geom_line() + facet_wrap(~region)
p <- p + xlab("Prior Width (σ)") + ylab("Bayes Factor in favor of H₀") + geom_hline(yintercept = 1, color = "red", linetype = "dashed") #

p <- p + theme_bw() + theme(legend.position='top') + 
  theme( strip.background = element_rect(fill="white") ) +
  guides( colour = guide_legend(title = NULL, nrow=1, byrow=TRUE) )

steps <- c(3, 10) #5, 20, 
p <- p + scale_y_log10( breaks = c(1/steps, 1, steps), labels = c(sprintf("1/%d", steps), 1, steps) ) #limits = c(1/5, 5),

dotted_line_color <- "grey"
p <-
p + geom_hline(yintercept = 3, color = dotted_line_color, linetype = "dotted") +
    geom_hline(yintercept = 1/3, color = dotted_line_color, linetype = "dotted") +
    geom_hline(yintercept = 10, color = dotted_line_color, linetype = "dotted") +
    geom_hline(yintercept = 1/10, color = dotted_line_color, linetype = "dotted") +
    theme( panel.grid.minor = element_blank(), panel.grid.major.y = element_blank(), panel.grid.major.x = element_blank()) +
    coord_cartesian(xlim = c(0, 1), ylim = c(1/20, 20), clip = "off")

px <- ggpubr::ggarrange(p)

annotation_size <- 2.8
x_coord <- 1.0675
annotation_color <- "grey15"
ycoord <- function(idx, min = 0.165, max = .74) (idx - 1)/5*(max-min) + min

px <- 
px + annotate('label', x = x_coord, y = ycoord(6), label = 'Strong\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) + 
     annotate('label', x = x_coord, y = ycoord(5), label = 'Moderate\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) + 
     annotate('label', x = x_coord, y = ycoord(4), label = 'Anecdotal\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) +
     annotate('label', x = x_coord, y = ycoord(3), label = 'Anecdotal\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45) + 
     annotate('label', x = x_coord, y = ycoord(2), label = 'Moderate\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45) + 
     annotate('label', x = x_coord, y = ycoord(1), label = 'Strong\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45)

ggsave(px + theme(plot.margin=grid::unit(c(0,2.3,0,0), "cm")) , file = fname_bfs_plot, height = 4, device = cairo_pdf)
}
