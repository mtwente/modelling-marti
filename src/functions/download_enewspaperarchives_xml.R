# Download and extract text from Veridian XML

library(httr)
library(xml2)
library(rvest)

download_veridian_text <- function(url, article_id) {
  response <- try(GET(url), silent = TRUE)
  
  if (inherits(response, "try-error") || status_code(response) != 200) {
    message("Failed to fetch: ", article_id)
    return(NULL)
  }
  
  xml <- content(response, as = "text", encoding = "UTF-8") %>% read_xml()
  
  # Extract HTML content inside SectionText tag
  section_text_node <- xml_find_first(xml, ".//SectionText")
  if (is.na(section_text_node)) {
    message("No <SectionText> found for: ", article_id)
    return(NULL)
  }
  
  html_text <- xml_text(section_text_node)
  
  # Clean HTML tags to extract plain text
  plain_text <- read_html(html_text) %>% html_text2()
  
  # Write to file
  if (!dir.exists(output_folder)) dir.create(output_folder)
  
  output_file <- file.path(output_folder, paste0(article_id, ".txt"))
  write_file(plain_text, output_file)
  
  message("Downloaded: ", article_id)
}