
n_cores <- 4
n_chains <- 4
n_threads <- NULL

formula_full <- DV ~ cN1attachmentVsAmb + cN2attachmentVsAmb + clWlen + clPrevWlen + clNextWlen +
                    (cN1attachmentVsAmb + cN2attachmentVsAmb + clWlen + clPrevWlen + clNextWlen + 1|subj) +
                    (1|stimulus)

crit_em_rc$clWlen %<>% as.vector()
crit_em_rc$clNextWlen %<>% as.vector()
crit_em_rc$clPrevWlen %<>% as.vector()

crit_em_rc_precrit <- crit_em_rc %>% subset(roiLabel == "pre-critical")
crit_em_rc_n1 <- crit_em_rc %>% subset(roiLabel == "N1")
crit_em_rc_n2 <- crit_em_rc %>% subset(roiLabel == "N2")
crit_em_rc_spillover <- crit_em_rc %>% subset(roiLabel == "spillover")



n_samples = 5000
n_warmup = 2000

path <- function(fname) sprintf('../workspace/models_eye/prior_1/%s', fname)
m_eye <- list()
m_eye$precrit <- brm_models(formula = formula_full, data = crit_em_rc_precrit, fname = path('precrit') )
m_eye$np1 <- brm_models(formula = formula_full, data = crit_em_rc_n1, fname = path('np1') )
m_eye$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2') )
m_eye$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover') )

if (FALSE) {
rm(m_eye); gc();

path <- function(fname) sprintf('../workspace/models_eye/prior_0.5/%s', fname)
m_eyex <- list()
m_eyex$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2'), prior_b = 0.5 )
m_eyex$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover'), prior_b = 0.5 )

path <- function(fname) sprintf('../workspace/models_eye/prior_0.4/%s', fname)
m_eyex <- list()
m_eyex$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2'), prior_b = 0.4 )
m_eyex$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover'), prior_b = 0.4 )

path <- function(fname) sprintf('../workspace/models_eye/prior_0.3/%s', fname)
m_eyex <- list()
m_eyex$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2'), prior_b = 0.3 )
m_eyex$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover'), prior_b = 0.3 )

path <- function(fname) sprintf('../workspace/models_eye/prior_0.2/%s', fname)
m_eyex <- list()
m_eyex$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2'), prior_b = 0.2 )
m_eyex$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover'), prior_b = 0.2 )

path <- function(fname) sprintf('../workspace/models_eye/prior_0.1/%s', fname)
m_eyex <- list()
m_eyex$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2'), prior_b = 0.1 )
m_eyex$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover'), prior_b = 0.1 )

}

