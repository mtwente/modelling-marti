library(here)
library(readr)
library(tidyverse)
library(qpdf)

input_file <- here("docs", "articles_metadata.csv")
output_folder <- here("data", "raw", "pdf")

source(here("src", "functions", "generate_eperiodica_url.R"))
source(here("src", "functions", "download_eperiodica_pdf.R"))

# Read CSV and process each file ID, filtering out "NZZ" and French publications
articles <- read_csv2(input_file) %>% 
  filter(publication != "NZZ") %>%
  filter(lang != "fr")

# Generate URLs
articles$url <- sapply(articles$id, generate_url)
articles <- articles %>% filter(!is.na(url))  # Remove rows with NA URLs

# Download PDFs
apply(articles, 1, function(row) {
  download_pdf(row["url"], row["id"])
})

# Rotate faulty page in one specific file
pdf_to_rotate <- file.path(output_folder, "sbz-002_1949_67__519_d.pdf")
# Define a temporary output file
temp_output <- file.path(output_folder, "sbz-002_1949_67__519_d_temp.pdf")

if (file.exists(pdf_to_rotate)) {
  pdf_rotate_pages(
    input = pdf_to_rotate,
    pages = 9,
    angle = -180,
    relative = TRUE,
    output = temp_output
  )

  # Overwrite original file
  file.rename(temp_output, pdf_to_rotate)

  message("Rotated page 9 in ", basename(pdf_to_rotate))
}