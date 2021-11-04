
brm_reading_simple <- function(DV, formula, data, file, family = "lognormal", prior_b = 1, prior_b_center = 0 )
{
  
  if (family == "lognormal") {
        prior <- c(prior_string("normal(5.75, 1)", class = "Intercept"),
                   prior_string("normal(0, 0.2)", class = "b"),
                   prior_string("normal(0, 1)", class = "sigma"), # population sigma
                   prior_string("normal(0, 1)", class = "sd") # random-effects sigma
                  )
    
        prior_narrow_slope <- sprintf("normal(%f, %f)", prior_b_center, 0.2*prior_b)
        prior %<>% c( prior_string(prior_narrow_slope, coef = "cN1attachmentVsAmb") )

  } else {
        prior <- c(prior_string("normal(0, 3)", class = "Intercept"),
                   prior_string("normal(0, 1)", class = "b"),
                   prior_string("normal(0, 1)", class = "sd") # random-effects sigma
                  )
        
        prior_narrow_slope <- sprintf("normal(%f, %f)", prior_b_center, 1*prior_b)
        prior %<>% c( prior_string(prior_narrow_slope, coef = "cN1attachmentVsAmb") )
  }
  
  if (family == "lognormal") {
    family = brms::lognormal()
  } else {
    family = brms::bernoulli()
  }

  print(DV)
  data %<>% dplyr::rename_( "DV" = DV )
  brm(formula,
      data = data, family = family,
      prior = prior, 
      #stanvars = stanvars_lognormalParamMeanSigma,
      chains = n_chains, cores = n_cores, 
      seed = 1234, iter = n_samples+n_warmup, warmup = n_warmup, 
      threads = n_threads, backend = "cmdstanr",
      save_pars = save_pars(all = TRUE),
      sample_prior = "yes",
      control = list(adapt_delta = 0.95),
      file = file
  )
}


brm_reading <- function(DV, formula, data, file, prior_b=1, prior_b_center=0, family = "lognormal")
{
  brm_reading_simple(DV = DV, formula = formula, data = data, file = file, family = family, prior_b = prior_b, prior_b_center = prior_b_center )
}


brm_models <- function(formula, prior_b=1, data, fname, prior_b_center=0)
{
  lst <- list()

  DV = "FPRT"
  lst$fprt <- brm_reading(DV = DV, formula = formula, 
                          data = subset(data, FFP==1),
                          file = paste(fname, DV, sep = "_"),
                          prior_b = prior_b, prior_b_center = prior_b_center
                          )
  
  DV = "RPD"
  lst$rpd <- brm_reading(DV = DV, formula = formula, 
                         data = subset(data, FFP==1),
                         file = paste(fname, DV, sep = "_"),
                         prior_b = prior_b, prior_b_center = prior_b_center
                         )
  
  DV = "TFT"
  lst$tft <- brm_reading(DV = DV, formula = formula, 
                         data = subset(data, TFT!=0),
                         file = paste(fname, DV, sep = "_"),
                         prior_b = prior_b, prior_b_center = prior_b_center
                         )
  
  DV = "regression"
  lst$rp <- brm_reading(DV = DV, formula = formula, 
                        data = subset(data, FFP==1),
                        file = paste(fname, DV, sep = "_"),
                        family="bernoulli",
                        prior_b = prior_b, prior_b_center = prior_b_center
                        )
  lst
}
