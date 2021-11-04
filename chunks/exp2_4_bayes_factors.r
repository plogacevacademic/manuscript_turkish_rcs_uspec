
library(tidyverse)
library(brms)
library(bridgesampling)
library(dplyr)
library(magrittr)

fname_bfs <- '../workspace/models_spr_bfs.rda'

# loads pairs of models and computes the Bayes factor for them
if (FALSE) # this code is meant to be run manually
{

  load_model <- function(prior, region) {
    fname <- sprintf('../workspace/models_spr/%s/%s.rds', prior, region )
    print(fname)
    readRDS(fname)
  }
  
  if (file.exists(fname_bfs)) {
    load(fname_bfs)
    
  } else {
    bf_template_lvl2 <- list(np1=NULL, np2=NULL, spillover=NULL)
    bf_spr <- list(prior_1 = bf_template_lvl2, prior_0.5 = bf_template_lvl2, prior_0.25 = bf_template_lvl2, prior_0.1 = bf_template_lvl2)
  }

  priors <- paste("prior", c("1","0.5","0.4","0.3","0.2","0.1"), sep = "_") #
  for (region in c("np2", "spillover")) {
    for (prior in priors) {
        if (is.null(bf_spr[[prior]][[region]])) {
            h <- hypothesis( load_model(prior, region), hypothesis = "cExperimental:cN1attachmentVsAmb = 0")
            bf_spr[[prior]][[region]] <- h$hypothesis$Evid.Ratio
            
            save(bf_spr, file = fname_bfs)
            cat(".")
            gc()
        }
    }
  }
  
}

(load(fname_bfs))

df_bf_spr <-
  bf_spr %>% plyr::ldply(function(lst) {
    res <- lst %>% plyr::ldply(function(evid_rat) {
      evid_rat
    }, .id = "region")
  }, .id = "prior_width") %T>% { .$prior_width %<>% gsub("^prior_", "", .) %>% as.numeric()}

