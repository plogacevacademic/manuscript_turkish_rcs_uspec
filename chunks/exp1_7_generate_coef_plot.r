
# note: + sigma^2/2 is to get the mean instead of the median
# note 2: not using + sigma^2/2 for the sake of consistency -- the plots show an estimate of exp(log_mean), not of the mean 
transformations_emrts_means <- c(mean_amb_ms = "exp(b_Intercept - 1/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb)", # 
                                 mean_n1_ms  = "exp(b_Intercept + 2/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb)", #
                                 mean_n2_ms  = "exp(b_Intercept - 1/3*b_cN1attachmentVsAmb + 2/3*b_cN2attachmentVsAmb)" #
)
transformations_emrts <- c(transformations_emrts_means,
                           delta_n1attachment_m_amb_ms = "mean_n1_ms - mean_amb_ms",
                           delta_n2attachment_m_amb_ms = "mean_n2_ms - mean_amb_ms"
)

m_eye_fprt <- list("noun 1" = m_eye$np1$fprt, "noun 2" = m_eye$np2$fprt, "spill-over" = m_eye$spillover$fprt)
p_fprt <- m_eye_fprt %>% { plot_coefs(., transformations = transformations_emrts)  + xlab("Estimate (ms)")  }

m_eye_rpd <- list("noun 1" = m_eye$np1$rpd, "noun 2" = m_eye$np2$rpd, "spill-over" = m_eye$spillover$rpd)
p_rpd <- m_eye_rpd %>% { plot_coefs(., transformations = transformations_emrts)  + xlab("Estimate (ms)")  }

m_eye_tft <- list("noun 1" = m_eye$np1$tft, "noun 2" = m_eye$np2$tft, "spill-over" = m_eye$spillover$tft)
p_tft <- m_eye_tft %>% { plot_coefs(., transformations = transformations_emrts)  + xlab("Estimate (ms)")  }


transformations_emprop_means <- c(mean_amb_ms = "plogis(b_Intercept - 1/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb)", 
                                  mean_n1_ms  = "plogis(b_Intercept + 2/3*b_cN1attachmentVsAmb - 1/3*b_cN2attachmentVsAmb)",
                                  mean_n2_ms  = "plogis(b_Intercept - 1/3*b_cN1attachmentVsAmb + 2/3*b_cN2attachmentVsAmb)"
)
transformations_emprop <- c(delta_n1attachment_m_amb_ms = "b_cN1attachmentVsAmb",
                            delta_n2attachment_m_amb_ms = "b_cN2attachmentVsAmb"
)

m_eye_rp <- list("noun 1" = m_eye$np1$rp, "noun 2" = m_eye$np2$rp, "spill-over" = m_eye$spillover$rp)
p_rp <- m_eye_rp %>% { plot_coefs(., transformations = transformations_emprop)  + xlab("Estimate (log-odds)")  }

# m_eye_rfp <- list("noun 1" = eye_np1$rfp, "noun 2" = eye_np2$rfp, "spill-over" = eye_spillover$rfp)
# p_rfp <- m_eye_rfp %>% { plot_coefs(., transformations = transformations_emprop)  + xlab("Estimate (log-odds)") }

p <-
  ggarrange(add_title(p_fprt, "First-pass reading time", hjust=-.6), 
            add_title(p_rpd, "Regression-path duration", hjust=-.635), 
            add_title(p_tft, "Total fixation time", hjust=-.52),
            add_title(p_rp, "% Regressions", hjust=-.50),
            # add_title(p_rfp, "% Refixations", hjust=-.5),
            labels = NULL,
            ncol = 1, nrow = 4, vjust = -.2, hjust = 0)

ggsave(p, file = fname_exp1_coef_plot, height = 5.5)