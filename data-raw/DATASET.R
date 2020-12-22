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
pdftools::pdf_text("data-raw/PDF/Cellies-transcript.pdf")

usethis::use_data(DATASET, overwrite = TRUE)
