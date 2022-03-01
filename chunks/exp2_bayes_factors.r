
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
    fname <- sprintf('../workspace/models_spr_bf/%s/%s.rds', prior, region )
    print(fname)
    readRDS(fname)
  }
  
  if (file.exists(fname_bfs)) {
    load(fname_bfs)
    
  } else {
    bf_template_lvl2 <- list(np1=NULL, np2=NULL, spillover=NULL)
    bf_spr <- list(prior_1 = bf_template_lvl2, prior_0.5 = bf_template_lvl2, prior_0.25 = bf_template_lvl2, prior_0.1 = bf_template_lvl2)
  }

  for (region in c("np2", "spillover"))
  {
    m_null <- load_model("null", region)
    for (prior in c("prior_1", "prior_0.5", "prior_0.1", "prior_0.25")) #, "prior1", "prior0.5", "prior0.25", "prior0.1")) {
    {
        if (is.null(bf_spr[[prior]][[region]])) {
          bf_spr[[prior]][[region]] <- bridgesampling::bayes_factor( m_null, load_model(prior, region) )
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
    res <- lst %>% plyr::ldply(function(lst) {
      lst$bf
    }, .id = "region")
  }, .id = "prior_width") %T>% { .$prior_width %<>% gsub("^prior_", "", .) %>% as.numeric()}

