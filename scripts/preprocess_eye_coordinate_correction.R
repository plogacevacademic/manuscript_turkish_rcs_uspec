
objective_fixation_location_transform_par <- function(p, y_screen_max)
{
  p[["width_line"]] <- exp(p[["width_line"]])
  p[["y_bottom_line"]] <- exp(p[["y_bottom_line"]])
  p[["width_bottom_line"]] <- exp(p[["width_bottom_line"]])
  p[["lo_on_main_line"]] <- plogis(p[["lo_on_main_line"]])
  p[["lo_on_bottom_line"]] <- plogis(p[["lo_on_bottom_line"]])
  
  ll_prior <- dbeta( p[["lo_on_main_line"]], shape1 = 10, shape2 = 3, log = T) +
              dunif( p[["y_bottom_line"]], min = 600, max = y_screen_max, log = T) +
              dnorm( p[["y_a"]], mean=0, sd = 20, log = T) +
              dnorm( p[["width_line"]], mean=0, sd = 100, log = T) +
              dnorm( p[["width_bottom_line"]], mean=0, sd = 100, log = T)
  attr(p, "ll_prior") <- ll_prior

  p
}

objective_fixation_location_transform_coords <- function(fixations, p) {
  x <- fixations$Location_X 
  y <- fixations$Location_Y
  fixations$Location_X <- x
  fixations$Location_Y <- y + p[["y_a"]]
  fixations
}

objective_fixation_location_lls <- function(p, fixations, y_screen_center, y_screen_min, y_screen_max)
{
  p <- objective_fixation_location_transform_par(p, y_screen_max = y_screen_max)
  fixations <- objective_fixation_location_transform_coords(fixations = fixations, p = p)
  
  ll_fix_on_main_line <- dnorm(fixations$Location_Y, mean = y_screen_center, sd = p[["width_line"]]/4, log = T )
  ll_fix_on_bottom_line <- dnorm(fixations$Location_Y, mean = p[["y_bottom_line"]], sd = p[["width_bottom_line"]]/4, log = T )
  ll_fix_off_line <- dunif(fixations$Location_Y, min = y_screen_min, max = y_screen_max, log = T)
  
  ll_main_line <- log( p[["lo_on_main_line"]] )
  ll_bottom_line <- log( (1-p[["lo_on_main_line"]]) * p[["lo_on_bottom_line"]] )
  ll_off_line <- log( (1-p[["lo_on_main_line"]]) * (1-p[["lo_on_bottom_line"]]) )

  lls <-
  cbind(ll_main_line = ll_main_line + ll_fix_on_main_line, 
        ll_bottom_line = ll_bottom_line + ll_fix_on_bottom_line,
        ll_off_line = ll_off_line + ll_fix_off_line
        )
  
  attr(lls, "ll_prior") <- attr(p, "ll_prior")
  lls
}

objective_fixation_location <- function(p, fixations, y_screen_center, y_screen_min, y_screen_max)
{
  ll_fix <- objective_fixation_location_lls(p, fixations, y_screen_center, y_screen_min, y_screen_max)
  lls <- apply(ll_fix, MARGIN = 1, matrixStats::logSumExp)
  ll <- sum(lls) + attr(ll_fix, "ll_prior")
  # cat(ll, "\n")
  ll
}

corrected_fixations_on_line <- function(fixations, y_screen_center, y_screen_min, y_screen_max)
{
  start_par <- c(y_a = 0, width_line = log(width_line_y),
                 y_bottom_line = log(y_screen_max*0.9), width_bottom_line = log(width_line_y), 
                 lo_on_main_line = qlogis(.8), lo_on_bottom_line = qlogis(.8))
  
  res <- optim(par = start_par, fn = objective_fixation_location, 
               fixations = fixations,
               y_screen_center = y_screen_center, y_screen_min=y_screen_min, y_screen_max=y_screen_max,
               control = list(fnscale = -1, maxit = 5*10^3))
  
  ll_fix <- objective_fixation_location_lls(res$par, fixations, y_screen_center, y_screen_min=0, y_screen_max)
  classification <- apply(ll_fix, MARGIN = 1, which.max)
  
  corrected_fixations <- objective_fixation_location_transform_coords(fixations, res$par)
  corrected_fixations[(classification==1), ]
}
