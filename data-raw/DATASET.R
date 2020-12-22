library(magrittr)

get_pdf <- function(pdf) {
  download.file(
    url = file.path(base_url, pdf),
    destfile = file.path(pdf_dir, basename(pdf)),
    mode = "wb"
  )
  Sys.sleep(1) # Pause to try not to overload the server
}

base_url <- "https://www.earhustlesq.com"
pdf_dir <- "./data-raw/PDF"

eh_listen <- xml2::read_html("https://www.earhustlesq.com/transcripts")

eh_links <- xml2::xml_find_all(eh_listen, "//a")

eh_tscripts <- eh_links %>%
  xml2::as_list() %>%
  purrr::map(attr, "href")

links_tscripts <- eh_tscripts %>%
  stringr::str_extract("s/.*") %>%
  purrr::discard(is.na) %>%
  stringr::str_remove(base_url) # One link is absolute

purrr::map(links_tscripts, get_pdf)

# Process PDF text
get_text <- function(pdf) {
  txt <- pdftools::pdf_text(pdf) %>%
    paste(collapse = " ")

  nm_pattern <- "Ep.*(?=\\r)"
  dt_pattern <- "(?<=air.*:).*(?=\\r)"

  ep_nm <- stringr::str_extract(txt, nm_pattern)
  ep_dt <- stringr::str_extract(txt, dt_pattern)

  ep_text <- txt %>%
    stringr::str_remove(ep_nm) %>%
    stringr::str_remove("First aired .*\\r") %>%
    trimws()

  time_pattern <- paste0(
    "(?<=\\[)", # Look-behind for open square bracket
    "[[0-9:.]]*", # Numbers, colon, or period
    "(?=\\])" # Look-ahead for closed square bracket
  )

  ep_text
}

tmp_cellies <- get_text("data-raw/PDF/Catch-a-Kite-5-Transcript.pdf")

stringr::str_split(tmp_cellies, "\\[.*\\]")

usethis::use_data(DATASET, overwrite = TRUE)
