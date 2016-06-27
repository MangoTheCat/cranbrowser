
alias_url <- "https://cran.r-project.org/src/contrib/Meta/aliases.rds"
alias_db <- Sys.getenv("DOCSDB_URL", "http://docs.r-pkg.org:5984/docs")
alias_pkgs <- c("R6", "crayon", "curl", "devtools", "digest", "git2r",
                "httr", "jsonlite", "memoise", "mime")

#' @importFrom jsonlite toJSON

update_docs_map <- function() {
  aliases <- readRDS(gzcon(url(alias_url)))[alias_pkgs]
  for (i in names(aliases)) update_docs_doc(i, aliases[[i]])
}

#' @importFrom httr GET PUT stop_for_status content

update_docs_doc <- function(name, doc) {
  url <- paste0(alias_db, "/", name)

  current <- try(stop_for_status(GET(url)), silent = TRUE)
  if (!inherits(current, "try-error")) {
    doc$`_rev` <- unbox(
      fromJSON(
        content(current, as = "text"),
        simplifyVector = FALSE)$`_rev`
    )
  }

  stop_for_status(PUT(url, body = toJSON(doc), encode = "json"))
}
