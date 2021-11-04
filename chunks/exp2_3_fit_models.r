

n_cores <- 4
n_chains <- 4
n_threads <- NULL

exp2_contrasts <-
  data.frame( condition          = c('a', 'b', 'c',  'd', 'e', 'f'),
              cN1attachmentVsAmb = c(-1,  -1,   2,   -1,   -1,   2) / 3,
              cN2attachmentVsAmb = c(-1,   2,  -1,   -1,    2,  -1) / 3,
              cExperimental = rep(c(1, -1), each = 3) / 2,
              stringsAsFactors = F)

# pre-code interactions
exp2_contrasts %<>% mutate(
  cExperimental_cN1attachmentVsAmb = cExperimental*cN1attachmentVsAmb,
  cExperimental_cN2attachmentVsAmb = cExperimental*cN2attachmentVsAmb
)

# merge in the contrasts and slice the data by position for analysis
reading_rc %<>% left_join(exp2_contrasts, by = "condition")
reading_rc_precrit = subset(reading_rc, posLabel =='V/Adj' )
reading_rc_np1 = subset(reading_rc, posLabel =='N1' )
reading_rc_np2 = subset(reading_rc, posLabel =='N2' )
reading_rc_spillover = subset(reading_rc, posLabel == 'spillover' )


brm_reading_simple <- function(formula, data, fname, prior_b = 1, prior_b_center = 0)
{
  prior_spr <- c(prior_string("normal(6, 1)", class = "Intercept"),
                 prior_string("normal(0, 0.2)", class = "b"),
                 prior_string("normal(0, 1)", class = "sigma"), # population sigma
                 prior_string("normal(0, 1)", class = "sd") # random-effects sigma
                )

  stopifnot(prior_b > 0)
  prior_narrow_slope <- sprintf("normal(%f, %f)", prior_b_center, 0.2*prior_b)
  prior_spr %<>% c( prior_string(prior_narrow_slope, coef = "cExperimental:cN1attachmentVsAmb") )

  m_spr <- brm(formula, family = brms::lognormal(), 
               prior = prior_spr,
               chains = n_chains, cores = n_cores, 
               seed = 1234, iter = n_samples+n_warmup, warmup = n_warmup, 
               threads = n_threads, backend = "cmdstanr",
               data = data, 
               save_pars = save_pars(all = TRUE),
               sample_prior = "yes",
               #control = list(adapt_delta = 0.95),
               file = fname)
  m_spr
}


brm_reading <- function(formula, data, fname, prior_b=1, prior_b_center = 0)
{
  brm_reading_simple(formula = formula, data = data, fname = fname, prior_b = prior_b, prior_b_center = prior_b_center )
}

formula_full <- RT ~ cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|subject) + 
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|item)
formula_full_n1 <- RT ~ cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + clWlen.n1.sg +
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + clWlen.n1.sg + 1|subject) +
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|item)
formula_full_n2 <- RT ~ cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + clWlen.n1.sg + clWlen.n2.sg +
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + clWlen.n1.sg + clWlen.n2.sg + 1|subject) +
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|item)

#################
# SIMPLE MODELS #
#################

n_samples = 5000
n_warmup = 2000

path <- function(fname) sprintf('../workspace/models_spr/prior_1/%s', fname)
m_spr = list();
m_spr$precrit <- brm_reading(formula_full, data = reading_rc_precrit, fname = path('precrit'), prior_b=1 )
m_spr$np1 <- brm_reading(formula_full_n1, data = reading_rc_np1, fname = path('np1'), prior_b=1 )
m_spr$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=1 )
m_spr$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=1 )

if (FALSE) {
  path <- function(fname) sprintf('../workspace/models_spr/prior_0.5/%s', fname)
  prior_b = 0.5
  m_sprx = list();
  m_sprx$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=prior_b )
  m_sprx$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=prior_b )

  path <- function(fname) sprintf('../workspace/models_spr/prior_0.4/%s', fname)
  prior_b = 0.4
  m_sprx = list();
  m_sprx$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=prior_b )
  m_sprx$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=prior_b )
  
  path <- function(fname) sprintf('../workspace/models_spr/prior_0.3/%s', fname)
  prior_b = 0.3
  m_sprx = list();
  m_sprx$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=prior_b )
  m_sprx$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=prior_b )
  
  path <- function(fname) sprintf('../workspace/models_spr/prior_0.2/%s', fname)
  prior_b = 0.2
  m_sprx = list();
  m_sprx$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=prior_b )
  m_sprx$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=prior_b )
  
  path <- function(fname) sprintf('../workspace/models_spr/prior_0.1/%s', fname)
  prior_b = 0.1
  m_sprx = list();
  m_sprx$np2 <- brm_reading(formula_full_n2, data = reading_rc_np2, fname = path('np2'), prior_b=prior_b )
  m_sprx$spillover <- brm_reading(formula_full_n2, data = reading_rc_spillover, fname = path('spillover'), prior_b=prior_b )
}

# if (FALSE) {
#   path <- function(fname) sprintf('../workspace/models_spr/prior_aa_0.05/%s', fname)
#   m_sprAA = list();
#   m_sprAA$np2 <- brm_reading(formula_full, data = reading_rc_np2, fname = path('np2'), prior_b=0.25, prior_b_center = 0.8 )
#   m_sprAA$spillover <- brm_reading(formula_full, data = reading_rc_spillover, fname = path('spillover'), prior_b=0.25, prior_b_center = 0.08 )
# }
