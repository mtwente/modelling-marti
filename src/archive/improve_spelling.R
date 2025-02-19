library(tidyverse)
library(here)

# Define your common OCR errors
source(here("src", "ocr_errors_list.R"))

# Define folders
input_folder <- here("data", "raw", "txt_cleaned")
output_folder <- here("data", "clean")

# Create output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Get all txt files
txt_files <- list.files(input_folder, pattern = "\\.txt$", full.names = TRUE)

# Function to correct OCR errors
correct_ocr <- function(txt_file) {
  text_vector <- readLines(txt_file, warn = FALSE)
  
  # Apply OCR corrections
  cleaned_text <- str_replace_all(text_vector, ocr_corrections)
  
  # Remove "_cleaned" from the filename
  corrected_filename <- str_replace(basename(txt_file), "_cleaned\\.txt$", ".txt")
  corrected_filepath <- file.path(output_folder, corrected_filename)
  
  # Write corrected text to a new file
  writeLines(cleaned_text, corrected_filepath)
  
  message("Processed: ", corrected_filename)
}

# Apply correction function to all files
lapply(txt_files, correct_ocr)

message("All files corrected successfully.")