library(httr)
library(readr)
library(dplyr)
library(here)
library(qpdf)

input_file <- here("docs", "articles_metadata.csv")
output_folder <- here("data", "raw", "pdf")

# Define the function to generate the URL from the file ID
generate_url <- function(file_id) {
  base_url <- "https://www.e-periodica.ch/cntmng?type=pdf&pid="
  
  # Extract relevant parts from file_id (assuming consistent pattern)
  parts <- unlist(strsplit(file_id, "_"))
  if (length(parts) < 4) return(NA)  # Ensure correct format
  
  journal_code <- parts[1]
  year <- parts[2]
  volume <- parts[3]
  article_number <- parts[5]
  
  # Extract numerical part of article_number
  article_number <- gsub("[^0-9]", "", article_number)
  
  paste0(base_url, journal_code, ":", year, ":", volume, "::", article_number)
}

# Function to download PDF
download_pdf <- function(url, file_id, output_dir = output_folder) {
  if (!dir.exists(output_dir)) dir.create(output_dir)
  
  pdf_path <- file.path(output_dir, paste0(file_id, ".pdf"))
  
  response <- GET(url, write_disk(pdf_path, overwrite = TRUE))
  
  #if (http_status(response)$category == "Success") {
  #  message("Downloaded: ", pdf_path)
  #} else {
  #  message("Failed to download: ", file_id)
  #}
  
  message("Downloaded: ", file_id)
}

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