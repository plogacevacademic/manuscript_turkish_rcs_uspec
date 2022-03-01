
n_cores <- 4
n_chains <- 4

formula_full <- DV ~ cN1attachmentVsAmb + cN2attachmentVsAmb + clWlen + clPrevWlen + clNextWlen +
                    (cN1attachmentVsAmb + cN2attachmentVsAmb + clWlen + clPrevWlen + clNextWlen + 1|subj) +
                    (1|stimulus)

formula_full_bf <- bf(DV ~ a + b1*cN1attachmentVsAmb + b2*cN2attachmentVsAmb, # + b3*clWlen + b4*clPrevWlen + b5*clNextWlen,
                      a ~ 1 + (1|S|subj) + (1|stimulus),
                      b1 ~ 1 + (1|S|subj), b2 ~ 1 + (1|S|subj), #b3 ~ 1 + (1|S|subj), b4 ~ 1 + (1|S|subj), b5 ~ 1 + (1|S|subj),
                      nl = T)
# formula_null_bf <- bf(DV ~ a + b2*cN2attachmentVsAmb, # + b3*clWlen + b4*clPrevWlen + b5*clNextWlen,
#                       a ~ 1 + (1|S|subj) + (1|stimulus), b2 ~ 1 + (1|S|subj), #b3 ~ 1 + (1|S|subj), b4 ~ 1 + (1|S|subj), b5 ~ 1 + (1|S|subj),
#                       nl = T)

crit_em_rc$clWlen %<>% as.vector()
crit_em_rc$clNextWlen %<>% as.vector()
crit_em_rc$clPrevWlen %<>% as.vector()

crit_em_rc_precrit <- crit_em_rc %>% subset(roiLabel == "pre-critical")
crit_em_rc_n1 <- crit_em_rc %>% subset(roiLabel == "N1")
crit_em_rc_n2 <- crit_em_rc %>% subset(roiLabel == "N2")
crit_em_rc_spillover <- crit_em_rc %>% subset(roiLabel == "spillover")


# Fit a series of models for Bayes Factor calculation
if (FALSE) # this code is meant to be run manually
{
    n_samples = 15000
    n_warmup = 2000
    # n_samples = 1000
    # n_warmup = 1000
    
    m_bf_eye <- list(prior1 = NULL, prior0.5 = NULL, prior0.25 = NULL, prior0.1 = NULL, null = NULL)
    
    path <- function(fname) sprintf('../workspace/models_eye_bf/%s', fname)
    
    m_bf_eye$prior1$np2 <- brm_models(formula = formula_full_bf, prior_b = 1, data = crit_em_rc_n2, fname = path('prior_1/np2') )
    m_bf_eye = NULL; gc();
    m_bf_eye$prior1$spillover <- brm_models(formula = formula_full_bf, prior_b = 1, data = crit_em_rc_spillover, fname = path('prior_1/spillover') )
    m_bf_eye = NULL; gc();
    
    m_bf_eye$prior0.5$np2 <- brm_models(formula = formula_full_bf, prior_b = 0.5, data = crit_em_rc_n2, fname = path('prior_0.5/np2') )
    m_bf_eye = NULL; gc();
    m_bf_eye$prior0.5$spillover <- brm_models(formula = formula_full_bf, prior_b = 0.5, data = crit_em_rc_spillover, fname = path('prior_0.5/spillover') )
    m_bf_eye = NULL; gc();
    
    m_bf_eye$prior0.25$np2 <- brm_models(formula = formula_full_bf, prior_b = 0.25, data = crit_em_rc_n2, fname = path('prior_0.25/np2') )
    m_bf_eye = NULL; gc();
    m_bf_eye$prior0.25$spillover <- brm_models(formula = formula_full_bf, prior_b = 0.25, data = crit_em_rc_spillover, fname = path('prior_0.25/spillover') )
    m_bf_eye = NULL; gc();
    
    m_bf_eye$prior0.1$np2 <- brm_models(formula = formula_full_bf, prior_b = 0.1, data = crit_em_rc_n2, fname = path('prior_0.1/np2') )
    m_bf_eye = NULL; gc();
    m_bf_eye$prior0.1$spillover <- brm_models(formula = formula_full_bf, prior_b = 0.1, data = crit_em_rc_spillover, fname = path('prior_0.1/spillover') )
    m_bf_eye = NULL; gc();
    
    m_bf_eye$null$np2 <- brm_models(formula = formula_full_bf, prior_b = 0, data = crit_em_rc_n2, fname = path('null/np2') )
    m_bf_eye = NULL; gc();
    m_bf_eye$null$spillover <- brm_models(formula = formula_full_bf, prior_b = 0, data = crit_em_rc_spillover, fname = path('null/spillover') )
    m_bf_eye = NULL; gc();
}




n_samples = 5000
n_warmup = 2000

path <- function(fname) sprintf('../workspace/models_eye/%s', fname)

m_eye <- list()
m_eye$precrit <- brm_models(formula = formula_full, data = crit_em_rc_precrit, fname = path('precrit') )
m_eye$np1 <- brm_models(formula = formula_full, data = crit_em_rc_n1, fname = path('np1') )
m_eye$np2 <- brm_models(formula = formula_full, data = crit_em_rc_n2, fname = path('np2') )
m_eye$spillover <- brm_models(formula = formula_full, data = crit_em_rc_spillover, fname = path('spillover') )

