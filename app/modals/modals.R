box::use(
  shiny[...],
)

#' @export
errorModal <- function(message) {
  modalDialog(
    title = "Application Error",
    "There has been an error. Please call or text Joseph Richey at 801-644-6893. Please include a screenshot or the error message below.",
    message
  )
}