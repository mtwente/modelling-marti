library(tidyverse)
library(here)

input_folder <- here("data", "raw", "txt_nzz")
output_folder <- here("data", "clean")
metadata_file <- here("docs", "articles_metadata.csv")

# Load OCR corrections
source(here("src", "functions", "nzz_error_list.R"))

# Load processing loop
source(here("src", "functions", "create_txt_from_nzz.R"))

# Create output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Load article metadata
metadata <- read.csv(metadata_file, sep = ";", stringsAsFactors = FALSE) %>%
  mutate(
    first_row = as.numeric(na_if(trimws(first_row), "")),
    last_row = as.numeric(na_if(trimws(last_row), ""))
  )

# Process all PDFs
txt_files <- list.files(input_folder, pattern = "\\.txt$", full.names = TRUE)
lapply(txt_files, process_nzz)

message("All files processed successfully.")