
brm_reading_simple <- function(DV, formula, data, file, family = "lognormal" )
{
  
  if (family == "lognormal") {
    prior <- c(prior_string("normal(5.75, 1)", class = "Intercept"),
               prior_string("normal(0, 0.2)", class = "b"),
               prior_string("normal(0, 1)", class = "sigma"), # population sigma
               prior_string("normal(0, 1)", class = "sd") # random-effects sigma
              )

  } else {
    prior <- c(prior_string("normal(0, 3)", class = "Intercept"),
               prior_string("normal(0, 1)", class = "b"),
               prior_string("normal(0, 1)", class = "sd") # random-effects sigma
              )
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
      save_pars = save_pars(all = TRUE),
      control = list(adapt_delta = 0.95),
      file = file
  )
}


brm_reading_positive <- function(DV, formula, data, file, prior_b=NULL, family = "lognormal" )
{
  print(DV)
  data %<>% dplyr::rename_( "DV" = DV )
  
  if (family == "lognormal")
  {
    prior_slope <- "normal(0, 0.2)"
    prior_sigma <- "normal(0, 1)"
    prior <- c(prior_string("normal(5.75, 1)", nlpar = "a"),
               prior_string(prior_slope, nlpar = "b2"),
               prior_string(prior_sigma, class = "sigma"), # population sigma
               prior_string(prior_sigma, class = "sd", nlpar = "a"), # random-effects sigma
               prior_string(prior_sigma, class = "sd", nlpar = "b2")
               )

  } else {
    prior_slope <- "normal(0, 1)"
    prior_sigma <- "normal(0, 1)"
    prior <- c(prior_string("normal(0, 3)", nlpar = "a"),
               prior_string(prior_slope, nlpar = "b2"),
               prior_string(prior_sigma, class = "sd", nlpar = "a"), # random-effects sigma
               prior_string(prior_sigma, class = "sd", nlpar = "b2")
               )
  }
  
  if (prior_b == 0)
  {
      prior %<>% c( prior(constant(0), nlpar = "b1") )
  }
  else {
    prior_narrow_slope <- ifelse(family == "lognormal", sprintf("normal(0, %f)", 0.2*prior_b), sprintf("normal(0, %f)", 1*prior_b) )
    prior %<>% c( prior_string(prior_narrow_slope, nlpar = "b1", lb = 0) )
  }
  prior %<>% c( prior_string(prior_sigma, class = "sd", nlpar = "b1") )

  brm(formula,
      data = data, family = family,
      prior = prior,
      # stanvars = stanvars_lognormalParamMeanSigma,
      chains = n_chains, cores = n_cores, 
      seed = 1234, iter = n_samples+n_warmup, warmup = n_warmup,
      save_pars = save_pars(all = TRUE),
      control = list(adapt_delta = 0.95),
      file = file
  )
}

brm_reading <- function(DV, formula, data, file, prior_b=NULL, family = "lognormal")
{
  if (is.null(prior_b)) {
      brm_reading_simple(DV = DV, formula = formula, data = data, file = file, family = family )
  } else {
      brm_reading_positive(DV = DV, formula = formula, data = data, file = file, prior_b = prior_b, family = family )
  }
}


brm_models <- function(formula, prior_b=NULL, data, fname)
{
  lst <- list()

  DV = "FPRT"
  lst$fprt <- brm_reading(DV = DV, formula = formula, 
                          data = subset(data, FFP==1),
                          file = paste(fname, DV, sep = "_"),
                          prior_b = prior_b
                          )
  
  DV = "RPD"
  lst$rpd <- brm_reading(DV = DV, formula = formula, 
                         data = subset(data, FFP==1),
                         file = paste(fname, DV, sep = "_"),
                         prior_b = prior_b
                         )
  
  DV = "TFT"
  lst$tft <- brm_reading(DV = DV, formula = formula, 
                         data = subset(data, TFT!=0),
                         file = paste(fname, DV, sep = "_"),
                         prior_b = prior_b
                         )
  
  DV = "regression"
  lst$rp <- brm_reading(DV = DV, formula = formula, 
                        data = subset(data, FFP==1),
                        file = paste(fname, DV, sep = "_"),
                        family="bernoulli",
                        prior_b = prior_b
                        )
  lst
}
