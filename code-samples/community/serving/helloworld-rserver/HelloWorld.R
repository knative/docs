#' HelloWorld function
#' @get /
#' @serializer html
function() {
  TARGET <- Sys.getenv("TARGET", "World")

  paste0("Hello ", TARGET, "!")
}
