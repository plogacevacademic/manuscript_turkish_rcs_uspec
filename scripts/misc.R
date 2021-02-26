#library(cacheSweave)
#library(utils)
#assignInNamespace("RweaveLatex", cacheSweave::cacheSweaveDriver, "utils")

library(grDevices)
options(digits=2)

asc <- function(x) as.character(x)
asic  <- function(x) as.integer(as.character(x))


se <- function(x)
{
   y <- x[!is.na(x)] # remove the missing values, if any
   sqrt(var(as.vector(y))/length(y))
}
# 
# # TODO: Figure out how to treat missing data in this function
# # TODO: Make sure this is strictly a within-participants design. Strange things happen to the means if
# #       one tries to process two experiments at once, even if the experiment is used as a grouping factor in the group argument
# se_cousineau <- function(df, n_conditions, subject, DV, group, is_proportion = NULL)
# {
#   stopifnot(!"avgDV" %in% colnames(df))
#   subject_var <- substitute(subject) %>% deparse() %>% gsub("\"", "", .)
#   DV <- substitute(DV) %>% deparse() %>% gsub("\"", "", .)
#   stopifnot( subject_var %in% colnames(df) && DV %in% colnames(df) )
# 
#   subj_means <- df %>% group_by(.dots = subject_var) %>% 
#                        dplyr::summarize(avgDV := mean(!!as.name(DV), na.rm = T), 
#                                         .groups = "drop")
#   GM <- mean(subj_means$avgDV)
#   df %<>% group_by(.dots = subject_var) %>% 
#                       dplyr::mutate(nDV = !!as.name(DV) - mean(!!as.name(DV), na.rm = T) + GM) %>%
#           ungroup()
#   
#   if (is.null(is_proportion)) {
#     dv <- df[[DV]]
#     dv_unique <- unique(dv)
#     if ( is.logical(dv) || (length(dv_unique) == 2 && all(dv_unique %in% c(0,1))) ) {
#       is_proportion <- TRUE
#     } else {
#       is_proportion <- FALSE
#     }
#   }
#   
#   var_correction_factor <- n_conditions/(n_conditions-1)
#   df %>% group_by(.dots = group) %>%
#     dplyr::summarize(M = mean(nDV, na.rm = T),
#                      Var = ifelse(is_proportion, M*(1-M), var(nDV, na.rm = T)) * var_correction_factor,
#                      N = sum(!is.na(nDV)),
#                      SE = sqrt(Var/N), 
#                      .groups = "drop" )
# }
# 
# 
# prob2odds_str <- function(p, round_from = 5) {
#   odds <- p/(1-p)
#   odds_inv <- odds <= 1
#   odds_round <- (odds >= round_from) | (odds <= 1/round_from)
#   odds <- ifelse(odds_inv, 1/odds, odds)
#   odds <- ifelse(odds_round, round(odds), odds)
#   template <- ifelse(odds_inv, 
#                      ifelse(odds_round, "1:%0.0f", "1:%0.1f"), 
#                      ifelse(odds_round, "%0.0f:1", "%0.1f:1"))
#   sapply(seq_along(template), function(i) { sprintf(template[i], odds[i]) })
# }
# 
# 
# prob_str <- function(p, gtst = 0.001) {
#   if (p < .001) {
#       str <- "< .001"
#   } else if (p > .999) {
#     str <- "> .999"
#   } else if (p > .99 | p < .01 ) {
#     str <- sprintf("  %.3f", p) %>% gsub("0\\.", ".", .)
#   } else {
#     str <- sprintf("   %.2f", p) %>% gsub("0\\.", ".", .)
#   }
#   str
# }
# 
# 
# model_summary <- function(m, include_pp_below_zero = T, transformations = NULL)
# {
#   # extract posterior samples
#   samples <- brms::posterior_samples(m)
#   
#   # perform any transformations, if applicable
#   if (!is.null(transformations)) {
#     for (i in 1:length(transformations)) {
#       samples[,names(transformations)[i]] <- with(samples, eval(parse(text = transformations[[i]] )) )
#     }
#   }
#   
#   # keep only fixed effects and transformed variables
#   cnames_keep <- rownames(fixef(m))[-1] %>% paste0("b_", .) %>% c( names(transformations) )
#   samples %<>% .[,cnames_keep]
#   
#   # convert to structure of class mcmc
#   samples_mcmc <- as.mcmc(samples)
#   
#   # create table of coefficients and credible intervals
#   tbl80 <- coda::HPDinterval(samples_mcmc, prob = .80) %>% as.data.frame() %T>% {colnames(.) %<>% paste0("80") }
#   tbl95 <- coda::HPDinterval(samples_mcmc, prob = .95) %>% as.data.frame()
#   tbl <- cbind(tbl80, tbl95)
#   tbl$Estimate <- sapply(samples, mean)
#   tbl$coef <- rownames(tbl) %>% gsub("^b_", "", .)
#   tbl %<>% dplyr::select(coef, Estimate, lower, lower80, upper80, upper)
#   
#   if (include_pp_below_zero) {
#     
#     pref_coef_stats_df <- function(df, name) {
#       df %>% as.data.frame(colnames = "x") %T>% 
#         { colnames(.) <- name } %T>%
#         { .$coef <- rownames(.) %>% gsub("^b_", "", .) }
#     }
#     
#     p_below_zero <- samples %>% sapply(function(x) mean(x < 0)) %>% 
#       pref_coef_stats_df("PBelowZero")
#     tbl %<>% left_join(p_below_zero, by = "coef")
#     
#     p_below_zero_str <- samples %>% sapply(function(x) mean(x < 0) %>% prob_str()) %>% 
#       pref_coef_stats_df("PBelowZeroStr")
#     tbl %<>% left_join(p_below_zero_str, by = "coef")
#     
#     p_above_zero <- samples %>% sapply(function(x) mean(x > 0)) %>% 
#       pref_coef_stats_df("PAboveZero")
#     tbl %<>% left_join(p_above_zero, by = "coef")
#     
#     p_above_zero_str <- samples %>% sapply(function(x) mean(x > 0) %>% prob_str()) %>% 
#       pref_coef_stats_df("PAboveZeroStr")
#     tbl %<>% left_join(p_above_zero_str, by = "coef")
#     
#   }
#   
#   tbl
# }
# 
# # TODO: In addition to label_max_width, add another argument, strip_label_max_terms,
# #       which inserts a line break on a by-term basis
# #       Alternatively, write a labeller, which finds the closest interaction symbol next to 
# #       the character maximum, and breaks there.
# create_model_coefs_plot <- function(m, 
#                                     interaction_panels = c(), 
#                                     strip_label_max_characters = NULL, 
#                                     map_names = NULL,
#                                     exclude_names = NULL,
#                                     plot_stats = FALSE, 
#                                     expand_right = 1, 
#                                     expand_top = 1,
#                                     x_stat_adjust = 0,
#                                     transformations = NULL)
# {
#   interaction_symbol <- " * "
#   use_interaction_panels <- length(interaction_panels) > 0
#   
#   if ( "brmsfit" %in% class(m) ) {
#     tbl <- model_summary( m, transformations = transformations #, include_pp_below_zero = plot_stats 
#     )
#     
#   } else if (is.list(m)) {
#     stopifnot( length(names(m)) == length(unique(names(m))) )
#     
#     tbl <- ldply(seq_along(m), function(i) { 
#       tbl <- model_summary( m[[i]], transformations = transformations #, include_pp_below_zero = plot_stats 
#       )
#       tbl$model <- names(m)[i]
#       tbl
#     })
#     tbl$model %<>% factor( levels = names(m) )
#     tbl
#     
#   } else {
#     stop("Unknown model format.")
#   }
#   tbl %<>% subset(!coef %in% exclude_names)
#   
#   # rename some rows 
#   if (length(map_names) > 0) {
#     for (i in seq_along(map_names)) {
#       idx <- which(tbl$coef == names(map_names)[i])
#       if (length(idx) > 0) {
#         if (map_names[i] == "") {
#           tbl <- tbl[-idx,]
#         } else {
#           tbl$coef[idx] <- map_names[i]
#         }
#       }
#     }
#   }
#   
#   if (use_interaction_panels) {
#     tbl$interaction <- ""
#   }
#   for (cur_interaction in interaction_panels) {
#     cur_interaction_term1 <- paste0(cur_interaction,":")
#     cur_interaction_term2 <- paste0(":",cur_interaction)
#     
#     is_target_interaction <- grepl(cur_interaction_term1, tbl$coef) | grepl(cur_interaction_term2, tbl$coef)
#     
#     tbl$coef[is_target_interaction] %<>% gsub(cur_interaction_term1, "", .) %>% 
#       gsub(cur_interaction_term2, "", .)
#     
#     tbl$interaction[is_target_interaction] <- paste0(cur_interaction, interaction_symbol, "...")
#   }
#   
#   # replace interaction symbol if necessary
#   if (interaction_symbol != ":") {
#     tbl$coef %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
#     
#     if (use_interaction_panels)
#       tbl$interaction %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
#   }
#   coefs_order <- c(rev(map_names), rev(tbl$coef)) %>% unique() # %>% rev()
#   tbl$coef %<>% factor(levels = coefs_order)
#   #tbl$coef %<>% factor(levels = tbl$coef %>% unique %>% rev())
#   
#   # plot
#   p <- ggplot(tbl, aes(Estimate, coef)) + geom_point() + 
#     geom_errorbarh(aes(xmin = lower, xmax = upper), height=0) + 
#     geom_errorbarh(aes(xmin = lower80, xmax = upper80), size = 1.5, height=0) + 
#     geom_vline(xintercept = 0, color = "grey")
#   
#   if (plot_stats)
#   {
#     tbl$xmax <- with(tbl, max(c(Estimate, lower, upper))) + x_stat_adjust
#     
#     p <- p + scale_y_discrete(expand = expand_scale(mult = c(.05, .15*expand_top), add = c(0, 0)) )
#     p <- p + scale_x_continuous(expand = expand_scale(mult = c(.05, .15*expand_right),  add = c(0, 0)) )
#     
#     p <- p + geom_text(aes(x = tbl$xmax, y = tbl$coef, label = sprintf("[%s]", tbl$PBelowZeroStr)), 
#                        family = "mono", hjust = "left")
#     
#     suppressWarnings({
#       p <-  p + geom_text(x = tbl$xmax[1], y = max(as.integer(tbl$coef))+1, 
#                           # label = "P( < 0)", 
#                           label = parse(text = "paste('P(', theta, ' < 0)')"),
#                           family = "mono", hjust = "left")#, fontface = "bold")
#     })
#   }
#   
#   if (use_interaction_panels) {
#     p <- p + facet_wrap(~ interaction, strip.position = "left", ncol = 1, scales = "free_y")
#     if (!is.null(strip_label_max_characters))
#       p <- p + label_wrap_gen(width = strip_label_max_characters)
#   }
#   
#   if ( !is.null(tbl$model) ) {
#     p <- p + facet_wrap(~model)
#   }
#   
#   p <- p + theme_bw() + 
#     theme(panel.border = element_blank(), 
#           axis.ticks.y = element_blank(),
#           #strip.text.x = element_blank(),
#           panel.grid.major = element_blank(),
#           panel.grid.minor = element_blank(),
#           strip.placement = "outside") +
#     ylab("")
#   
#   attr(p, "model_summary") <- tbl
#   
#   return (p)
# }


library(dplyr)
library(magrittr)
library(brms)
library(ggplot2)

# TODO: Figure out how to treat missing data in this function
# TODO: Make sure this is strictly a within-participants design. Strange things happen to the means if
#       one tries to process two experiments at once, even if the experiment is used as a grouping factor in the group argument

# TODO: Figure out how to treat missing data in this function
# TODO: Make sure this is strictly a within-participants design. Strange things happen to the means if
#       one tries to process two experiments at once, even if the experiment is used as a grouping factor in the group argument
se_cousineau <- function(df, n_conditions, subject, DV, group, is_proportion = NULL)
{
  stopifnot(!"avgDV" %in% colnames(df))
  subject_var <- substitute(subject) %>% deparse() %>% gsub("\"", "", .)
  DV <- substitute(DV) %>% deparse() %>% gsub("\"", "", .)
  stopifnot( subject_var %in% colnames(df) && DV %in% colnames(df) )
  
  subj_means <- df %>% group_by(.dots = subject_var) %>% 
    dplyr::summarize(avgDV := mean(!!as.name(DV), na.rm = T), 
                     .groups = "drop")
  GM <- mean(subj_means$avgDV)
  df %<>% group_by(.dots = subject_var) %>% 
    dplyr::mutate(nDV = !!as.name(DV) - mean(!!as.name(DV), na.rm = T) + GM) %>%
    ungroup()
  
  if (is.null(is_proportion)) {
    dv <- df[[DV]]
    dv_unique <- unique(dv)
    if ( is.logical(dv) || (length(dv_unique) == 2 && all(dv_unique %in% c(0,1))) ) {
      is_proportion <- TRUE
    } else {
      is_proportion <- FALSE
    }
  }
  
  var_correction_factor <- n_conditions/(n_conditions-1)
  df %>% group_by(.dots = group) %>%
    dplyr::summarize(M = mean(nDV, na.rm = T),
                     Var = ifelse(is_proportion, M*(1-M), var(nDV, na.rm = T)) * var_correction_factor,
                     N = sum(!is.na(nDV)),
                     SE = sqrt(Var/N), 
                     .groups = "drop" )
}



nunique <- function(x) length(unique(x))


read_file <- function(fname) { readChar(fname, file.info(fname)$size) }




lognormalParamMeanSigma <- custom_family(
  "lognormalParamMeanSigma", dpars = c("mu", "sigma"),
  links = c("identity", "log"), lb = c(0, 0),
  type = "real"
)

stan_funs_lognormalParamMeanSigma <- "
real lognormalmean2mu(real mean, real sigma) {
  real mu;
  if (mean < 25) {
    mu = log( mean + (exp(mean)-mean)/(exp(2*mean) + 1) ) - sigma^2/2;
  } else {
    mu = log( mean ) - sigma^2/2;
  }
  return mu;
}
real lognormalParamMeanSigma_lpdf(real y, real mean, real sigma) {
  return lognormal_lpdf(y | lognormalmean2mu(mean, sigma), sigma);
}
real lognormalParamMeanSigma_rng(real mean, real sigma) {
  return lognormal_rng(lognormalmean2mu(mean, sigma), sigma);
}
"
stanvars_lognormalParamMeanSigma <- stanvar(scode = stan_funs_lognormalParamMeanSigma,
                                            block = "functions")




prob2odds_str <- function(p, round_from = 5) {
  odds <- p/(1-p)
  odds_inv <- odds <= 1
  odds_round <- (odds >= round_from) | (odds <= 1/round_from)
  odds <- ifelse(odds_inv, 1/odds, odds)
  odds <- ifelse(odds_round, round(odds), odds)
  template <- ifelse(odds_inv,
                     ifelse(odds_round, "1:%0.0f", "1:%0.1f"),
                     ifelse(odds_round, "%0.0f:1", "%0.1f:1"))
  sapply(seq_along(template), function(i) { sprintf(template[i], odds[i]) })
}


prob_str <- function(p, gtst = 0.001) {
  if (p < .001) {
    str <- "< .001"
  } else if (p > .999) {
    str <- "> .999"
  } else if (p > .99 | p < .01 ) {
    str <- sprintf("  %.3f", p) %>% gsub("0\\.", ".", .)
  } else {
    str <- sprintf("   %.2f", p) %>% gsub("0\\.", ".", .)
  }
  str
}



model_summary <- function(m, include_pp_below_zero = T, transformations = NULL, use_hpdi = FALSE)
{
  # extract posterior samples
  samples <- brms::posterior_samples(m)
  
  # perform any transformations, if applicable
  if (!is.null(transformations)) {
    for (i in 1:length(transformations)) {
      samples[,names(transformations)[i]] <- with(samples, eval(parse(text = transformations[[i]] )) )
    }
  }
  
  # keep only fixed effects and transformed variables
  cnames_keep <- rownames(fixef(m))[-1] %>% paste0("b_", .) %>% c( names(transformations) )
  samples %<>% .[,cnames_keep]
  
  # create table of coefficients and credible intervals
  if (use_hpdi)
  {
    # convert to structure of class mcmc
    samples_mcmc <- as.mcmc(samples)
    tbl80 <- coda::HPDinterval(samples_mcmc, prob = .80) %>% as.data.frame() %T>% {colnames(.) %<>% paste0("80") }
    tbl90 <- coda::HPDinterval(samples_mcmc, prob = .90) %>% as.data.frame() %T>% {colnames(.) %<>% paste0("90") }
    tbl95 <- coda::HPDinterval(samples_mcmc, prob = .95) %>% as.data.frame() %T>% {colnames(.) %<>% paste0("95") }
  } 
  else {
    tbl80 <- apply(samples, MARGIN = 2, FUN = function(x) quantile(x, c(.1, .9))) %>% t() %T>% {colnames(.) <- c("lower80", "upper80") }
    tbl90 <- apply(samples, MARGIN = 2, FUN = function(x) quantile(x, c(.05, .95))) %>% t() %T>% {colnames(.) <- c("lower90", "upper90") }
    tbl95 <- apply(samples, MARGIN = 2, FUN = function(x) quantile(x, c(.025, .975))) %>% t() %T>% {colnames(.) <- c("lower95", "upper95") }
  }
  tbl <- cbind(tbl80, tbl90, tbl95) %>% as.data.frame()
  tbl$Estimate <- sapply(samples, mean)
  tbl$coef <- rownames(tbl) %>% gsub("^b_", "", .)
  tbl %<>% dplyr::select(coef, Estimate, lower95, lower90, lower80, upper80, upper90, upper95)
  
  if (include_pp_below_zero) {
    
    pref_coef_stats_df <- function(df, name) {
      df %>% as.data.frame(colnames = "x") %T>% 
        { colnames(.) <- name } %T>%
        { .$coef <- rownames(.) %>% gsub("^b_", "", .) }
    }
    
    p_below_zero <- samples %>% sapply(function(x) mean(x < 0)) %>% 
      pref_coef_stats_df("PBelowZero")
    tbl %<>% left_join(p_below_zero, by = "coef")
    
    p_below_zero_str <- samples %>% sapply(function(x) mean(x < 0) %>% prob_str()) %>% 
      pref_coef_stats_df("PBelowZeroStr")
    tbl %<>% left_join(p_below_zero_str, by = "coef")
    
    p_above_zero <- samples %>% sapply(function(x) mean(x > 0)) %>% 
      pref_coef_stats_df("PAboveZero")
    tbl %<>% left_join(p_above_zero, by = "coef")
    
    p_above_zero_str <- samples %>% sapply(function(x) mean(x > 0) %>% prob_str()) %>% 
      pref_coef_stats_df("PAboveZeroStr")
    tbl %<>% left_join(p_above_zero_str, by = "coef")
  }
  tbl
}

# TODO: In addition to label_max_width, add another argument, strip_label_max_terms,
#       which inserts a line break on a by-term basis
#       Alternatively, write a labeller, which finds the closest interaction symbol next to 
#       the character maximum, and breaks there.
create_model_coefs_plot <- function(m, 
                                    interaction_panels = c(), 
                                    strip_label_max_characters = NULL, 
                                    map_names = NULL,
                                    exclude_names = NULL,
                                    plot_stats = FALSE, 
                                    expand_right = 1, 
                                    expand_top = 1,
                                    x_stat_adjust = 0,
                                    transformations = NULL,
                                    horizontal_line_at = 0)
{
  interaction_symbol <- " * "
  use_interaction_panels <- length(interaction_panels) > 0
  
  if ( "brmsfit" %in% class(m) ) {
    tbl <- model_summary( m, transformations = transformations #, include_pp_below_zero = plot_stats 
    )
    
  } else if (is.list(m)) {
    stopifnot( length(names(m)) == length(unique(names(m))) )
    
    tbl <- ldply(seq_along(m), function(i) { 
      tbl <- model_summary( m[[i]], transformations = transformations #, include_pp_below_zero = plot_stats 
      )
      tbl$model <- names(m)[i]
      tbl
    })
    tbl$model %<>% factor( levels = names(m) )
    tbl
    
  } else {
    stop("Unknown model format.")
  }
  tbl %<>% subset(!coef %in% exclude_names)
  
  # rename some rows 
  if (length(map_names) > 0) {
    for (i in seq_along(map_names)) {
      idx <- which(tbl$coef == names(map_names)[i])
      if (length(idx) > 0) {
        if (map_names[i] == "") {
          tbl <- tbl[-idx,]
        } else {
          tbl$coef[idx] <- map_names[i]
        }
      }
    }
  }
  
  if (use_interaction_panels) {
    tbl$interaction <- ""
  }
  for (cur_interaction in interaction_panels) {
    cur_interaction_term1 <- paste0(cur_interaction,":")
    cur_interaction_term2 <- paste0(":",cur_interaction)
    
    is_target_interaction <- grepl(cur_interaction_term1, tbl$coef) | grepl(cur_interaction_term2, tbl$coef)
    
    tbl$coef[is_target_interaction] %<>% gsub(cur_interaction_term1, "", .) %>% 
      gsub(cur_interaction_term2, "", .)
    
    tbl$interaction[is_target_interaction] <- paste0(cur_interaction, interaction_symbol, "...")
  }
  
  # replace interaction symbol if necessary
  if (interaction_symbol != ":") {
    tbl$coef %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
    
    if (use_interaction_panels)
      tbl$interaction %<>% gsub("([^ ]):([^ ])", paste0("\\1", interaction_symbol, "\\2"), .)
  }
  coefs_order <- c(rev(map_names), rev(tbl$coef)) %>% unique() # %>% rev()
  tbl$coef %<>% factor(levels = coefs_order)
  #tbl$coef %<>% factor(levels = tbl$coef %>% unique %>% rev())
  
  # plot
  p <- ggplot(tbl, aes(Estimate, coef))
  if (!is.null(horizontal_line_at)) {
    p <- p + geom_vline(xintercept = 0, color = "grey")
  }
  p <- p + geom_point() + 
    geom_errorbarh(aes(xmin = lower90, xmax = upper90), height=0) + 
    geom_errorbarh(aes(xmin = lower80, xmax = upper80), size = 1.5, height=0)
  
  if (plot_stats)
  {
    tbl$xmax <- with(tbl, max(c(Estimate, lower90, upper90))) + x_stat_adjust
    
    p <- p + scale_y_discrete(expand = expansion(mult = c(.05, .15*expand_top), add = c(0, 0)) )
    p <- p + scale_x_continuous(expand = expansion(mult = c(.05, .15*expand_right),  add = c(0, 0)) )
    
    p <- p + geom_text(aes(x = tbl$xmax, y = tbl$coef, label = sprintf("[%s]", tbl$PBelowZeroStr)), 
                       family = "mono", hjust = "left")
    
    suppressWarnings({
      p <-  p + geom_text(x = tbl$xmax[1], y = max(as.integer(tbl$coef))+1, 
                          # label = "P( < 0)", 
                          label = parse(text = "paste('P(', theta, ' < 0)')"),
                          family = "mono", hjust = "left")#, fontface = "bold")
    })
  }
  
  if (use_interaction_panels) {
    p <- p + facet_wrap(~ interaction, strip.position = "left", ncol = 1, scales = "free_y")
    if (!is.null(strip_label_max_characters))
      p <- p + label_wrap_gen(width = strip_label_max_characters)
  }
  
  if ( !is.null(tbl$model) ) {
    p <- p + facet_wrap(~model)
  }
  
  p <- p + theme_bw() + 
    theme(panel.border = element_blank(), 
          axis.ticks.y = element_blank(),
          #strip.text.x = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          strip.placement = "outside") +
    ylab("")
  
  attr(p, "model_summary") <- tbl
  
  return (p)
}
