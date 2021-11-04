
library(plyr)
library(dplyr) 
library(tidyverse)
library(magrittr)
library(ggplot2)
theme_set(theme_bw())

library(car, warn.conflicts = FALSE)
library(MASS)
library(brms)
library(xtable)
library(ggpubr)
library(knitcitations)

library(emmeans)


source("../scripts/misc.R")
source("../chunks/format_fn.r")

options(dplyr.summarise.inform = FALSE)


### SPR.LoadData
dir_base <- ".."
source("../chunks/exp2_1_load_data.r")

### sprAverageRTs
fname_spr_rts = "../text/figure/sprAverageRTs.pdf"
source("../chunks/exp2_2_spr_plot.r")

### SPR.LMER
source("../chunks/exp2_3_fit_models.r")

### plot estimated marginal effects
df_emmeans_contr <- reading_rc %>% ungroup %>% dplyr::select(modifier, attachment, cExperimental, cN1attachmentVsAmb, cN2attachmentVsAmb) %>% unique()

spr_emmeans <-
  m_spr %>% plyr::ldply(function(m) {
      mx <- m #remove_intercept_variance(m)
      df_emmeans <- emmeans::emmeans(mx, specs = ~ 1 + cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb))
      cat(".")
      df_emmeans_contr %>% dplyr::left_join( df_emmeans %>% as.data.frame, by = c("cExperimental", "cN1attachmentVsAmb", "cN2attachmentVsAmb") )
  }, .id = "roiLabel")
spr_emmeans %<>% dplyr::select(-cExperimental, -cN1attachmentVsAmb, -cN2attachmentVsAmb)

fname_spr_emms = "../text/figure/sprEMMs.pdf"
source("../chunks/exp2_5_emm_plot.r")


### spr.brms.prepare.bfs
source("../chunks/exp2_4_bayes_factors.r")

### spr.brms.plot.bfs
fname_bfs2_plot <- "../text/figure/exp2_BFs.pdf"

{
df_bf_spr$region %<>% dplyr::recode("np2"="noun 2", "spillover"="spill-over")

# x <- data.frame(prior_width = c(.1,.2,.3,.4,.5, 1),
#                 prior_prob = c(.93, .77, .69, .65, .62, .56)
#                 )
# x$prior_ratio <- x$prior_prob/(1-x$prior_prob)
# df_bf_spr %<>% left_join(x)

p <- df_bf_spr %>% ggplot(aes( prior_width, V1 )) + geom_point() + geom_line() + facet_wrap(~region)
p <- p + scale_x_continuous(breaks = c(.1,.2,.3,.4,.5, 1), labels = c(".02",".04",".06",".08",".1", ".2")) # scale_x_continuous(limits = c(0.0, 1.1), breaks = c(0, .1, .25, .5, .75, 1), labels = c("0", ".01", ".25", ".5", ".75", "1"))
p <- p + xlab("Prior Width (σ)") + ylab("Bayes Factor in favor of H₀") + geom_hline(yintercept = 1, color = "red", linetype = "dashed")
p <- p + theme_bw() + theme(legend.position='top') + 
          theme( strip.background = element_rect(fill="white") ) +
          guides( colour = guide_legend(title = NULL, nrow=1, byrow=TRUE) )

steps <- c(3, 10)
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

annotation_size <- 3
x_coord <- 1.07
annotation_color <- "grey15"
ycoord <- function(idx, min = 0.175, max = .87) (idx - 1)/5*(max-min) + min

px <- 
  px + 
  annotate('label', x = x_coord, y = ycoord(6), label = 'Strong\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) + 
  annotate('label', x = x_coord, y = ycoord(5), label = 'Moderate\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) + 
  annotate('label', x = x_coord, y = ycoord(4), label = 'Anecdotal\nevidence for H₀', color = annotation_color, size = annotation_size, angle = 45) +
  annotate('label', x = x_coord, y = ycoord(3), label = 'Anecdotal\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45) + 
  annotate('label', x = x_coord, y = ycoord(2), label = 'Moderate\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45) + 
  annotate('label', x = x_coord, y = ycoord(1), label = 'Strong\nevidence for H₁', color = annotation_color, size = annotation_size, angle = 45)

ggsave(px + theme(plot.margin=grid::unit(c(0,2.35,0,0), "cm")) , file = fname_bfs2_plot, height = 4, device = cairo_pdf)
}



### sprModelPlot

map_names <- c( "clWlen.n1.sg"="word length",
                "clWlen.n2.sg"="word length",
                "clWlen"="word length",
                "cN1attachmentVsAmb"="N1 singular",
                "cN2attachmentVsAmb"="N2 singular",
                "cExperimental"="RC attachment - control",
                "cExperimental:cN1attachmentVsAmb"="N1 attachment - ambiguous",
                "cExperimental:cN2attachmentVsAmb"="N2 attachment - ambiguous"
)

names(m_spr) %<>% dplyr::recode("np1"="noun 1", "np2"="noun 2", "spillover"="spillover")

p_exp2_coef_appendix <-
  create_model_coefs_plot( m_spr, plot_stats = F, map_names = map_names
                           #expand_right = 2.5, x_stat_adjust = -20 
  ) + xlab("Estimate") +
  theme(  strip.background = element_rect(fill="white") )


# note: + sigma^2/2 is to get the mean instead of the median
# note 2: not using + sigma^2/2 for the sake of consistency -- the plots show an estimate of exp(log-mean), not of the mean 
transformations_rts <- c(mean_amb_ctrl_ms = "exp(b_Intercept - 0.5*b_cExperimental - 1/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb + 
                                                (-0.5*-1/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                (-0.5*-1/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         mean_n1_ctrl_ms  = "exp(b_Intercept - 0.5*b_cExperimental + 2/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb +
                                                 (-0.5*2/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                 (-0.5*-1/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         mean_n2_ctrl_ms  = "exp(b_Intercept - 0.5*b_cExperimental - 1/3*b_cN1attachmentVsAmb + 2/3*b_cN2attachmentVsAmb +
                                                 (-0.5*-1/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                 (-0.5*2/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         
                         mean_amb_rc_ms = "exp(b_Intercept + 0.5*b_cExperimental - 1/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb  +
                                                  (0.5*-1/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                  (0.5*-1/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         mean_n1_rc_ms  = "exp(b_Intercept + 0.5*b_cExperimental + 2/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb  +
                                                  (0.5*2/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                  (0.5*-1/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         mean_n2_rc_ms  = "exp(b_Intercept + 0.5*b_cExperimental - 1/3*b_cN1attachmentVsAmb + 2/3*b_cN2attachmentVsAmb  +
                                                  (0.5*-1/3)*`b_cExperimental:cN1attachmentVsAmb` +
                                                  (0.5*2/3)*`b_cExperimental:cN2attachmentVsAmb`)",
                         
                         delta_amb_attachment_ms = "mean_amb_rc_ms - mean_amb_ctrl_ms",
                         delta_n1_attachment_ms  = "mean_n1_rc_ms - mean_n1_ctrl_ms",
                         delta_n2_attachment_ms  = "mean_n2_rc_ms - mean_n2_ctrl_ms",

                         delta_n1_singular = "(mean_n1_ctrl_ms + mean_n1_rc_ms)/2 - (mean_amb_rc_ms + mean_amb_ctrl_ms)/2",
                         delta_n2_singular = "(mean_n2_ctrl_ms + mean_n2_rc_ms)/2 - (mean_amb_rc_ms + mean_amb_ctrl_ms)/2",
                         delta_rc_m_control_ms = "(mean_amb_rc_ms+mean_n1_rc_ms+mean_n2_rc_ms)/3-(mean_amb_ctrl_ms+mean_n1_ctrl_ms+mean_n2_ctrl_ms)/3 ",
                         delta_n1attachment_m_amb_ms = "delta_n1_attachment_ms - delta_amb_attachment_ms",
                         delta_n2attachment_m_amb_ms = "delta_n2_attachment_ms - delta_amb_attachment_ms")

plot_labels <- c("delta_n1_singular"="N1 singular - N1/N2 plural",
                 "delta_n2_singular"="N2 singular - N1/N2 plural",
                 "delta_rc_m_control_ms"="RC attachment - control",
                 "delta_n1attachment_m_amb_ms"="N1 attachment - ambiguous\n[(N1 singular - N1/N2 plural) * (RC attachment - control)]", 
                 "delta_n2attachment_m_amb_ms"="N2 attachment - ambiguous\n[(N2 singular - N1/N2 plural) * (RC attachment - control)]")

p <-   create_model_coefs_plot( m_spr[-1], plot_stats = F,
                                map_names = plot_labels,
                                transformations = transformations_rts,
                                exclude_names = c("mean_amb_ctrl_ms", "mean_n1_ctrl_ms", "mean_n2_ctrl_ms", "mean_amb_rc_ms", "mean_n1_rc_ms",
                                                  "mean_n2_rc_ms", "delta_amb_attachment_ms", 
                                                  "delta_n1_attachment_ms", "delta_n2_attachment_ms",
                                                  "clWlen.n1.sg", "clWlen.n2.sg", "clWlen", "cN1attachmentVsAmb", "cN2attachmentVsAmb", "cExperimental",
                                                  "cExperimental:cN1attachmentVsAmb", "cExperimental:cN2attachmentVsAmb")
) + xlab("Estimate (ms)") + 
  theme(  strip.background = element_rect(fill="white") )

ggsave(p, file = "../text/figure/sprModelPlot.pdf", height = 2.5, width = 8)


### sprEffectSize

# for the posterior prob of an ambiguity advantage larger than a specific effect
samples_spr_np2 <- brms::posterior_samples(m_spr$`noun 2`)
samples_spr_spillover <- brms::posterior_samples(m_spr$spillover)

for (i in seq_along(transformations_rts)) {
  transformations_code <- paste(names(transformations_rts)[i], transformations_rts[i], sep = "=" ) %>% parse(text = .)
  samples_spr_np2 %<>% within(eval(transformations_code) )
  samples_spr_spillover %<>% within(eval(transformations_code) )
}


drop_re <- function(samples) { 
  cnames <- colnames(samples) %>% .[!grepl("^z_", .)] %>% .[!grepl("^r_", .)] %>% 
    .[!grepl("^Cor_", .)] %>% .[!grepl("^L_", .)] %>% 
    .[!grepl("^sd_", .)] %>% .[!grepl("^cor_", .)]
  samples[,cnames]
}


stats_spr <- list()
stats_spr$df_bf_spr <- df_bf_spr

inv_plot_labels <- names(plot_labels) %T>% {names(.) <- plot_labels}
stats_spr$coefs_tbl <- p$data
stats_spr$coefs_tbl$coef %<>% dplyr::recode(!!!inv_plot_labels)

stats_spr$samples_spr_np2 <- samples_spr_np2 %>% drop_re
stats_spr$samples_spr_spillover <- samples_spr_spillover %>% drop_re

save(stats_spr, file = "../workspace/stats_spr.rda")
