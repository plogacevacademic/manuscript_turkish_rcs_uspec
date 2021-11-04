
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


### Load data
source("../chunks/exp1_1_load_data.r")

### Eye.brms.functions
source("../chunks/exp1_2_brms_wrappers.r")

### Eye.brms
source("../chunks/exp1_3_fit_models.r")

### Eye.brms.compute.bfs
source("../chunks/exp1_4_bayes_factors.r")

### Eye.brms.prepare.bfs
fname_bfs_plot <- "../text/figure/exp1_BFs.pdf"
source("../chunks/exp1_5_bayes_factors_plot.r")

### EyeRTsPlot
fname_eye_rts <- "../text/figure/eyeEMM.pdf"

df_emmeans_contr <- crit_em_rc %>% dplyr::select(attachment, cN1attachmentVsAmb, cN2attachmentVsAmb) %>% unique()

eye_emmeans <-
  m_eye %>% plyr::ldply(function(lst) {
    res <- lst %>% plyr::ldply(function(m) {
      mx <- m #remove_intercept_variance(m)
      df_emmeans <- emmeans::emmeans(mx, specs = ~ 1 + cN1attachmentVsAmb + cN2attachmentVsAmb)
      cat(".")
      df_emmeans_contr %>% dplyr::left_join( df_emmeans %>% as.data.frame, by = c("cN1attachmentVsAmb", "cN2attachmentVsAmb") )
    }, .id = "measure")
  }, .id = "roiLabel")
eye_emmeans %<>% dplyr::select(-cN1attachmentVsAmb, -cN2attachmentVsAmb)

source("../chunks/exp1_6_dvs_plot.r")


### emStandardMeasuresModelCoefPlot
fname_exp1_coef_plot = "../text/figure/emStandardMeasuresModelCoefPlot.pdf"
source("../chunks/exp1_7_generate_coef_plot.r")


drop_re <- function(samples) { 
  cnames <- colnames(samples) %>% .[!grepl("^z_", .)] %>% .[!grepl("^r_", .)] %>% 
    .[!grepl("^Cor_", .)] %>% .[!grepl("^L_", .)] %>% 
    .[!grepl("^sd_", .)] %>% .[!grepl("^cor_", .)]
  samples[,cnames]
}

# for the posterior prob of an ambiguity advantage larger than a specific effect
samples_eye_np2_rpd <- m_eye$np2$rpd %>% brms::posterior_samples()
samples_eye_spillover_rpd <- m_eye$spillover$rpd %>% brms::posterior_samples()

for (i in seq_along(transformations_emrts)) {
  transformations_code <- paste(names(transformations_emrts)[i], transformations_emrts[i], sep = "=" ) %>% 
    parse(text = .)
  samples_eye_np2_rpd %<>% within(eval(transformations_code) )
  samples_eye_spillover_rpd %<>% within(eval(transformations_code) )
}


stats_eye <- list()
stats_eye$df_bf_eye <- df_bf_eye
stats_eye$coefs_tbl_fprt <- p_fprt$data
stats_eye$coefs_tbl_rpd <- p_rpd$data
stats_eye$coefs_tbl_tft <- p_tft$data
stats_eye$coefs_tbl_rp <- p_rp$data

stats_eye$samples_eye_np2_rpd <- samples_eye_np2_rpd %>% drop_re
stats_eye$samples_eye_spillover_rpd <- samples_eye_spillover_rpd %>% drop_re

save(stats_eye, file = "../workspace/stats_eye.rda")
