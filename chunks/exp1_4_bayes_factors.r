library(tidyverse)
library(brms)
library(bridgesampling)
library(dplyr)
library(magrittr)

fname_bfs <- '../workspace/models_eye_bfs.rda'

# loads pairs of models and computes the Bayes factor for them
if (FALSE) # this code is meant to be run manually
{
  
  load_model <- function(prior, region, dv) {
    fname <- sprintf('../workspace/models_eye/%s/%s_%s.rds', prior, region, dv )
    print(fname)
    readRDS(fname)
  }
  
  if (file.exists(fname_bfs)) {
    load(fname_bfs)
    
  } else {
    bf_template_lvl1 <- list(FPRT=NULL, RPD=NULL, TFT=NULL, regression=NULL)
    bf_template_lvl2 <- list(np1=bf_template_lvl1, np2=bf_template_lvl1, spillover=bf_template_lvl1)
    bf_eye <- list(prior_1 = bf_template_lvl2, prior_0.5 = bf_template_lvl2, prior_0.25 = bf_template_lvl2, prior_0.1 = bf_template_lvl2)
  }
  
  for (region in c("np2", "spillover")) {
    for (dv in c("FPRT", "RPD", "TFT", "regression")) {
      #null_model <- load_model("null", region, dv)
      for (prior in c("prior_1", "prior_0.5", "prior_0.4", "prior_0.3", "prior_0.2", "prior_0.1"))
      {
          if (is.null(bf_eye[[prior]][[region]][[dv]])) {
            #bf_eye[[prior]][[region]][[dv]] <- bridgesampling::bayes_factor(null_model, load_model(prior, region, dv) )
            h <- hypothesis( load_model(prior, region, dv), hypothesis = "cN1attachmentVsAmb = 0")
            bf_eye[[prior]][[region]][[dv]] <- h$hypothesis$Evid.Ratio
            save(bf_eye, file = fname_bfs)
            cat(".")
            gc()
          }
      }
    }
  }
  
}

(load(fname_bfs))

df_bf_eye <-
  bf_eye %>% plyr::ldply(function(lst) {
    res <- lst %>% plyr::ldply(function(lst) {
      res <- lst %>% plyr::ldply(function(evid_rat) { 
        #lst$bf
        evid_rat
        }, .id = "measure")
    }, .id = "region")
  }, .id = "prior_width") %T>% { .$prior_width %<>% gsub("^prior_", "", .) %>% as.numeric()}

