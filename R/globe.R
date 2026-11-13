#' GLOBE score for primary biliary cholangitis (Lammers 2015)
#'
#' Transplant-free survival of patients with primary biliary cholangitis (PBC)
#' treated with ursodeoxycholic acid (UDCA), from the original continuous
#' GLOBE model. The outcome is liver transplantation or death from any cause.
#' Survival is counted from the start of UDCA therapy, the paper's time
#' origin; the laboratory values are those after one year of UDCA.
#'
#' GLOBE score = 0.044378 x age + 0.93982 x ln(bilirubin / ULN)
#'   + 0.335648 x ln(ALP / ULN) - 2.266708 x (albumin / LLN)
#'   - 0.002581 x platelets + 1.216865;
#' S(t) = S0(t)^exp(score), with S0 = 0.9652, 0.9385, 0.8429 and 0.7361 at 3,
#' 5, 10 and 15 years.
#'
#' Each laboratory value and its reference limit must be in the same units
#' (for bilirubin, umol/L or mg/dL). To enter multiples of the limit
#' directly, set the limit to 1. Platelets are in 10^9/L and are not divided
#' by a reference limit.
#'
#' @param age Age in years at the start of UDCA therapy.
#' @param bilirubin,bilirubin_uln Total bilirubin after one year of UDCA, and
#'   the upper limit of normal.
#' @param alp,alp_uln Alkaline phosphatase after one year of UDCA, and the
#'   upper limit of normal.
#' @param albumin,albumin_lln Albumin after one year of UDCA, and the lower
#'   limit of normal.
#' @param platelets Platelet count after one year of UDCA, 10^9/L.
#' @return A list: `globe_score`; `transplant_free_survival` and
#'   `risk_transplant_or_death` at 3, 5, 10 and 15 years (probabilities,
#'   unrounded); `calculator` (score to 2 decimals and survival in percent to 1
#'   decimal, as globalpbc.com shows them); and `ratios` (the values used).
#' @export
globe_score <- function(age, bilirubin, bilirubin_uln, alp, alp_uln, albumin, albumin_lln,
                        platelets) {
  age <- .gl_num(age, "age", 18, 100)
  bil <- .gl_num(bilirubin, "bilirubin", 0, Inf, open_low = TRUE) /
    .gl_num(bilirubin_uln, "bilirubin_uln", 0, Inf, open_low = TRUE)
  alp <- .gl_num(alp, "alp", 0, Inf, open_low = TRUE) /
    .gl_num(alp_uln, "alp_uln", 0, Inf, open_low = TRUE)
  alb <- .gl_num(albumin, "albumin", 0, Inf, open_low = TRUE) /
    .gl_num(albumin_lln, "albumin_lln", 0, Inf, open_low = TRUE)
  plt <- .gl_num(platelets, "platelets", 0, 2000, open_low = TRUE)

  score <- 0.044378 * age + 0.93982 * log(bil) + 0.335648 * log(alp) -
    2.266708 * alb - 0.002581 * plt + 1.216865
  s0 <- c(year_3 = 0.9652, year_5 = 0.9385, year_10 = 0.8429, year_15 = 0.7361)
  surv <- s0^exp(score)
  list(globe_score = score,
       transplant_free_survival = as.list(surv),
       risk_transplant_or_death = as.list(1 - surv),
       calculator = list(globe_score = round(score, 2),
                         survival_percent = as.list(round(100 * surv, 1))),
       ratios = list(bilirubin_x_uln = bil, alp_x_uln = alp, albumin_x_lln = alb,
                     platelets = plt))
}

.gl_num <- function(x, field, lo, hi, open_low = FALSE) {
  if (is.character(x)) x <- suppressWarnings(as.numeric(gsub(",", ".", x, fixed = TRUE)))
  bad <- !is.numeric(x) || length(x) != 1L || is.na(x) || x > hi ||
    (if (open_low) x <= lo else x < lo)
  if (bad) {
    stop("`", field, "` must be a number ", if (open_low) "above " else "from ", lo,
         if (is.finite(hi)) paste0(if (open_low) " and up to " else " to ", hi) else "",
         ".", call. = FALSE)
  }
  as.numeric(x)
}
