

n_cores <- 4
n_chains <- 4

exp2_contrasts <-
  data.frame( condition          = c('a', 'b', 'c',  'd', 'e', 'f'),
              cN1attachmentVsAmb = c(-1,  -1,   2,   -1,   -1,   2) / 3,
              cN2attachmentVsAmb = c(-1,   2,  -1,   -1,    2,  -1) / 3,
              cExperimental = rep(c(1, -1), each = 3) / 2,
              stringsAsFactors = F)


# # identify trials with potential outliers
# rt_lower = 150; rt_upper = 3000
# data_too_fast <- subset(reading_rc, posLabel %in% c("N1", "N2", "spillover") & RT < rt_lower ) %>% arrange(subject)
# data_too_slow <- subset(reading_rc, posLabel %in% c("N1", "N2", "spillover") & RT > rt_upper ) %>% arrange(subject)
# 
# # too fast: 4 out of 5 extremely fast reading times are due to participant 10031, of those 2 are due to one trial 
# # data.rt.critical %>% subset(subject == 10031) %>% ggplot(aes(pos, RT)) + geom_point() + facet_wrap(~item) # nothing out of the ordinary
# with(data_too_fast, xtabs(~modifier+attachment))
# 
# # too slow: a large proportion of extremely slow reading times are due to participant 10003
# # data.rt.critical %>% subset(subject == 10003) %>% ggplot(aes(pos, RT)) + geom_point() + facet_wrap(~item, scales = "free_y") # nothing out of the ordinary
# # with(data_too_slow, xtabs(~RC+attachment)) # all super-slow reading times are for the controls of unambiguous conditions; 

# # exclude trials with too fast RTs
# data_problematic <- data_too_fast #rbind(data_too_fast, data_too_slow)
# d_to_be_excluded <- data_problematic %>% dplyr::select(subject, experiment, item, condition) %>% unique %T>% {.$exclude <- T}
# reading_rc %<>% left_join(d_to_be_excluded, by = c("subject", "experiment", "item", "condition"))
reading_rc$exclude <- NA

# pre-code interactions
exp2_contrasts %<>% mutate(
  cExperimental_cN1attachmentVsAmb = cExperimental*cN1attachmentVsAmb,
  cExperimental_cN2attachmentVsAmb = cExperimental*cN2attachmentVsAmb
)

# merge in the contrasts and slice the data by position for analysis
reading_rc %<>% left_join(exp2_contrasts, by = "condition")
reading_rc_np1 = subset(reading_rc, posLabel =='N1' & is.na(exclude) )
reading_rc_np2 = subset(reading_rc, posLabel =='N2' & is.na(exclude) )
reading_rc_spillover = subset(reading_rc, posLabel == 'spillover' & is.na(exclude) )

# fname_models_spr_np1 <- '../workspace/models_spr_np1'
# fname_models_spr_np2 <- '../workspace/models_spr_np2'
# fname_models_spr_spillover <- '../workspace/models_spr_spillover'




brm_reading_simple <- function(formula, data, fname)
{
  prior_spr <- c(prior_string("normal(6, 1)", class = "Intercept"),
                 prior_string("normal(0, 0.2)", class = "b"),
                 prior_string("normal(0, 1)", class = "sigma"), # population sigma
                 prior_string("normal(0, 1)", class = "sd") # random-effects sigma
                )

  m_spr <- brm(formula, family = brms::lognormal(), 
               prior = prior_spr,
               chains = n_chains, cores = n_cores, 
               seed = 1234, iter = n_samples+n_warmup, warmup = n_warmup,
               data = data, 
               save_pars = save_pars(all = TRUE),
               control = list(adapt_delta = 0.95),
               file = fname)
  m_spr
}



brm_reading_positive <- function(formula, data, file, prior_b=NULL)
{
    prior_slope <- "normal(0, 0.2)"
    prior_sigma <- "normal(0, 1)"
    prior <- c(prior_string("normal(6, 1)", nlpar = "a"),
               prior_string(prior_slope, nlpar = "b2"),
               prior_string(prior_sigma, class = "sigma"), # population sigma
               prior_string(prior_sigma, class = "sd", nlpar = "a"), # random-effects sigma
               prior_string(prior_sigma, class = "sd", nlpar = "b2")
               )

  if (prior_b == 0)
  {
    prior %<>% c( prior(constant(0), nlpar = "b1") )
  } 
  else {
    prior_narrow_slope <- sprintf("normal(0, %f)", 0.2*prior_b)
    prior %<>% c( prior_string(prior_narrow_slope, nlpar = "b1", lb = 0) )
  }
  prior %<>% c( prior_string(prior_sigma, class = "sd", nlpar = "b1") )
    
  #  print(head(data))
  
  brm(formula,
      data = data, family = brms::lognormal(), 
      prior = prior,
      # stanvars = stanvars_lognormalParamMeanSigma,
      chains = n_chains, cores = n_cores, 
      seed = 1234, iter = n_samples+n_warmup, warmup = n_warmup,
      save_pars = save_pars(all = TRUE),
      control = list(adapt_delta = 0.95),
      file = file
  )
}

brm_reading <- function(formula, data, fname, prior_b=NULL)
{
  if (is.null(prior_b)) {
      brm_reading_simple(formula = formula, data = data, fname = fname )
  } else {
    brm_reading_positive(formula = formula, data = data, file = fname, prior_b = prior_b )
  }
}





formula_full <- RT ~ cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|subject) + 
                    (cExperimental * (cN1attachmentVsAmb + cN2attachmentVsAmb) + 1|item)


# to-do: Add item RE correlations to everything except the null model
formula_full_bf <- brms::bf(RT ~ a + b1*cExperimental_cN1attachmentVsAmb + b2*cExperimental_cN2attachmentVsAmb + b3*cExperimental + b4*cN1attachmentVsAmb + b5*cN2attachmentVsAmb,
                      a ~  1 + (1|S|subject) + (1|I|item),
                      b1 ~ 1 + (1|S|subject) + (1|I|item),
                      b2 ~ 1 + (1|S|subject) + (1|I|item), 
                      b3 ~ 1 + (1|S|subject) + (1|I|item),
                      b4 ~ 1 + (1|S|subject) + (1|I|item), 
                      b5 ~ 1 + (1|S|subject) + (1|I|item),
                      nl = T)


########################################
# Models for Bayes Factor calculations #
########################################

# to be run manually
if (FALSE)
{
    n_samples = 15000
    n_warmup = 2000
    
    m_spr_bf = list();
    path <- function(fname) sprintf('../workspace/models_spr_bf/%s', fname)

    m_spr_bf$np2$prior1 <- brm_reading(formula_full_bf, prior_b = 1, data = reading_rc_np2, fname = path('prior_1/np2') )
    m_spr_bf = list(); gc();
    m_spr_bf$spillover$prior1 <- brm_reading(formula_full_bf, prior_b = 1, data = reading_rc_spillover, fname = path('prior_1/spillover') )
    m_spr_bf = list(); gc();
    
    m_spr_bf$np2$prior0.5 <- brm_reading(formula_full_bf, prior_b = 0.5, data = reading_rc_np2, fname = path('prior_0.5/np2') )
    m_spr_bf = list(); gc();
    m_spr_bf$spillover$prior0.5 <- brm_reading(formula_full_bf, prior_b = 0.5, data = reading_rc_spillover, fname = path('prior_0.5/spillover') )
    m_spr_bf = list(); gc();
    
    m_spr_bf$np2$prior0.25 <- brm_reading(formula_full_bf, prior_b = 0.25, data = reading_rc_np2, fname = path('prior_0.25/np2') )
    m_spr_bf = list(); gc();
    m_spr_bf$spillover$prior0.25 <- brm_reading(formula_full_bf, prior_b = 0.25, data = reading_rc_spillover, fname = path('prior_0.25/spillover') )
    m_spr_bf = list(); gc();
    
    m_spr_bf$np2$prior0.1 <- brm_reading(formula_full_bf, prior_b = 0.1, data = reading_rc_np2, fname = path('prior_0.1/np2') )
    m_spr_bf = list(); gc();
    m_spr_bf$spillover$prior0.1 <- brm_reading(formula_full_bf, prior_b = 0.1, data = reading_rc_spillover, fname = path('prior_0.1/spillover') )
    m_spr_bf = list(); gc();
    
    m_spr_bf$np2$null <- brm_reading(formula_full_bf, prior_b = 0, data = reading_rc_np2, fname = path('null/np2') )
    m_spr_bf = list(); gc();
    m_spr_bf$spillover$null <- brm_reading(formula_full_bf, prior_b = 0, data = reading_rc_spillover, fname = path('null/spillover') )
    m_spr_bf = list(); gc();
}


#################
# SIMPLE MODELS #
#################

n_samples = 5000
n_warmup = 2000

path <- function(fname) sprintf('../workspace/models_spr/%s', fname)
m_spr = list();
m_spr$np1 <- brm_reading(formula_full, data = reading_rc_np1, fname = path('np1') )
m_spr$np2 <- brm_reading(formula_full, data = reading_rc_np2, fname = path('np2') )
m_spr$spillover <- brm_reading(formula_full, data = reading_rc_spillover, fname = path('spillover') )

