library(tidyverse)
library(here)

# Define folders
input_folder <- here("data", "raw", "txt")  # Folder with original txt files
output_folder <- here("data", "raw", "txt_trimmed")  # Folder to save cleaned txt files
metadata_file <- here("docs", "overview.csv")  # CSV file with row numbers

# Create output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Read metadata CSV (ensure proper column types)
metadata <- read.csv(metadata_file, sep = ";", stringsAsFactors = FALSE) %>%
  mutate(
    first_row = as.numeric(na_if(trimws(first_row), "")),  # Convert empty strings to NA, then to numeric
    last_row = as.numeric(na_if(trimws(last_row), ""))
  )

# Get all txt files in input folder
txt_files <- list.files(input_folder, pattern = "\\.txt$", full.names = TRUE)

# Function to clean a single file based on metadata
clean_file <- function(txt_file) {
  # Extract filename without extension
  file_id <- str_replace(basename(txt_file), "\\.txt$", "")
  
  # Find matching row in metadata
  meta_row <- metadata %>% filter(id == file_id)
  
  # Skip file if no matching metadata found
  if (nrow(meta_row) == 0) {
    message("Skipping: ", file_id, " (No metadata found)")
    return(NULL)
  }
  
  # Get first and last row values
  first_row <- meta_row$first_row
  last_row <- meta_row$last_row
  
  # Skip file if first_row or last_row is NA (including empty values)
  if (is.na(first_row) | is.na(last_row)) {
    message("Skipping: ", file_id, " (Missing first_row or last_row)")
    return(NULL)
  }
  
  # Read text file
  text_vector <- readLines(txt_file, warn = FALSE)
  
  # Ensure valid range
  if (first_row > length(text_vector) || last_row < 1) {
    message("Skipping: ", file_id, " (Invalid row range)")
    return(NULL)
  }
  
  # Keep only the specified lines
  cleaned_text <- text_vector[first_row:last_row]
  
  # Define output filename
  cleaned_txt_file <- file.path(output_folder, paste0(file_id, "_trimmed.txt"))
  
  # Write cleaned text to a new file
  writeLines(cleaned_text, cleaned_txt_file)
  
  message("Processed: ", file_id)
}

# Loop over all txt files and clean them
lapply(txt_files, clean_file)

message("All files processed successfully.")
