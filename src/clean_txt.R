library(tidyverse)
library(here)

# Define folders
input_folder <- here("data", "raw", "txt_trimmed")  # Folder with trimmed txt files
output_folder <- here("data", "raw", "txt_cleaned")  # Folder for fully cleaned txt files

# Create output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Get all trimmed txt files
txt_files <- list.files(input_folder, pattern = "\\.txt$", full.names = TRUE)

# Function to remove lines containing "SCHWEIZERISCHE BAUZEITUNG"
clean_file <- function(txt_file) {
  # Read text file
  text_vector <- readLines(txt_file, warn = FALSE)
  
  # Remove lines containing "SCHWEIZERISCHE BAUZEITUNG" (case-sensitive)
  cleaned_text <- text_vector[!str_detect(text_vector, "SCHWEIZERISCHE BAUZEITUNG|Schweiz\\. Bauzeitung")] %>%
    str_replace_all(., "[^[:alnum:].:,?!;]", " ") %>% # replace all characters that are neither letters, numbers, nor punctuation
    str_squish() %>% # reduce whitespace
    discard(~ nchar(.x) <= 2) # discard lines with two characters only or less
  
  cleaned_filename <- str_replace(basename(txt_file), "_trimmed\\.txt$", "_cleaned.txt")
  cleaned_txt_file <- file.path(output_folder, cleaned_filename)
  
  # Write cleaned text to a new file
  writeLines(cleaned_text, cleaned_txt_file)
  
  message("Processed: ", basename(txt_file))
}

# Loop over all txt files and clean them
lapply(txt_files, clean_file)

message("All files cleaned successfully.")
