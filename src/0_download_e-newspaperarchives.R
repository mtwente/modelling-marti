library(here)
library(readr)
library(tidyverse)

input_file <- here("docs", "articles_metadata.csv")
output_folder <- here("data", "raw", "txt_nzz_neu")

# TODO
## update trim data

# scraping issues: https://bookdown.org/f_lennert/workshop-ukraine/advanced-rvest.html

source(here("src", "functions", "generate_enewspaperarchives_url.R"))
source(here("src", "functions", "download_enewspaperarchives_xml.R"))

# Read CSV and process each file ID, filtering for "NZZ"
articles <- read_csv2(input_file) %>% 
  filter(publication == "NZZ")

# Generate URLs
articles$url <- sapply(articles$archive_id, generate_veridian_url)
articles <- articles %>% filter(!is.na(url))  # Remove rows with NA URLs

# Save XML Section Text to txt files
apply(articles, 1, function(row) {
  download_veridian_text(row["url"], row["id"])
})