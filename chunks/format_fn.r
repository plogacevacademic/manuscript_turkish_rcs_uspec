
plot_coefs <- function(ms, transformations = NULL) {
  create_model_coefs_plot( ms, 
                           plot_stats = F,
                           transformations = transformations,
                           map_names = c("clWlen"="word length",
                                         "delta_n1attachment_m_amb_ms"="N1 attachment - ambiguous",
                                         "delta_n2attachment_m_amb_ms"="N2 attachment - ambiguous"
                           ),
                           exclude_names = c("cN1attachmentVsAmb", "cN2attachmentVsAmb",
                                             "clWlen", "clPrevWlen", "clNextWlen",
                                             "mean_amb_ms", "mean_n1_ms", "mean_n2_ms")#,
                           #expand_right = 5#, 
                           #x_stat_adjust = 0 
  ) + theme(  strip.background =element_rect(fill="white") )
}

add_title <- function(p, title, hjust) { 
  p + ggtitle(title) + theme(plot.title = element_text(hjust=hjust))
}

extract_effect <- function(coefs_tbl, coef, model = NULL)
{
  cur_model = model
  cur_coef = coef
  
  if (is.null(model))
    df <- subset(coefs_tbl, coef == cur_coef)
  else
    df <- subset(coefs_tbl, model == cur_model & coef == cur_coef)
  stopifnot(nrow(df) == 1)
  df
}

row_summary_string90 <- function(row, fmt, lower = T)#
{
  if (lower) {
    fmt <- paste0("CrI [", fmt, "; ", fmt, "], P($\\beta$ < 0) = %s")
    post_prob_name <- "PBelowZeroStr"
  } else {
    fmt <- paste0("CrI [", fmt, "; ", fmt, "], P($\\beta$ > 0) = %s")
    post_prob_name <- "PAboveZeroStr"
  }
  res <- sprintf(fmt, row$lower90, row$upper90, row[[post_prob_name]] )
  res %<>% gsub("= <", "<", .) %>% gsub("= >", ">", .)
  res
}

row_summary_string95 <- function(row, fmt, lower = T)#
{
  if (lower) {
    fmt <- paste0("CrI [", fmt, "; ", fmt, "], P($\\beta$ < 0) = %s")
    post_prob_name <- "PBelowZeroStr"
  } else {
    fmt <- paste0("CrI [", fmt, "; ", fmt, "], P($\\beta$ > 0) = %s")
    post_prob_name <- "PAboveZeroStr"
  }
  res <- sprintf(fmt, row$lower95, row$upper95, row[[post_prob_name]] )
  res %<>% gsub("= <", "<", .) %>% gsub("= >", ">", .)
  res
}

row_summary_ci95 <- function(row, fmt)#
{
  fmt <- paste0("[", fmt, "; ", fmt, "]")
  res <- sprintf(fmt, row$lower95, row$upper95 )
  res
}

row_summary_ci90 <- function(row, fmt)#
{
  fmt <- paste0("[", fmt, "; ", fmt, "]")
  res <- sprintf(fmt, row$lower95, row$upper95 )
  res
}

effect_summary_string <- function(coefs_tbl, coef, fmt, model = NULL, lower = T) {
  extract_effect(coefs_tbl=coefs_tbl, model=model, coef=coef) %>%
    row_summary_string95(fmt = fmt, lower = lower)
}

effect_ci95 <- function(coefs_tbl, coef, fmt, model = NULL) {
  extract_effect(coefs_tbl=coefs_tbl, model=model, coef=coef) %>%
    row_summary_ci95(fmt = fmt)
}

effect_ci90 <- function(coefs_tbl, coef, fmt, model = NULL) {
  extract_effect(coefs_tbl=coefs_tbl, model=model, coef=coef) %>%
    row_summary_ci90(fmt = fmt)
}
