.gl_vars <- c("age", "bilirubin", "bilirubin_uln", "alp", "alp_uln", "albumin", "albumin_lln",
              "platelets")
.gl_alias <- c(age_udca = "age", bili = "bilirubin", bil = "bilirubin", bili_uln = "bilirubin_uln",
               alkaline_phosphatase = "alp", alb = "albumin", alb_lln = "albumin_lln",
               plt = "platelets", platelet_count = "platelets")

#' GLOBE (ModelsCloud entry point)
#' @param model_input Named list of inputs; see [globe_score()].
#' @param ... The same fields as named arguments.
#' @return See [globe_score()].
#' @export
model_run <- function(model_input = NULL, ...) {
  args <- .gl_normalize(model_input, list(...), .gl_vars, .gl_alias)
  if (is.null(args)) stop("No input supplied.", call. = FALSE)
  do.call(globe_score, args)
}

#' Example GLOBE inputs
#' @param n Optional number of rows.
#' @param ... Ignored.
#' @export
get_sample_input <- function(n = NULL, ...) {
  rows <- list(get_default_input(),
               list(age = 62, bilirubin = 40, bilirubin_uln = 17, alp = 600, alp_uln = 130,
                    albumin = 32, albumin_lln = 35, platelets = 120))
  if (!is.null(n)) rows <- utils::head(rows, n)
  rows
}

#' Default GLOBE input: the inputs of the paper's worked example (see README)
#' @param ... Ignored.
#' @export
get_default_input <- function(...) {
  list(age = 50, bilirubin = 17, bilirubin_uln = 17, alp = 360, alp_uln = 120,
       albumin = 45, albumin_lln = 30, platelets = 250)
}
