library(tidyverse)
library(here)
library(hunspell)

de_ch <- dictionary(here("assets", "de_CH", "de_CH.dic"))

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
  cleaned_text <- text_vector[!str_detect(text_vector, "SCHWEIZERISCHE BAUZEITUNG|Schweiz\\. Bauzeitung|SCHWEIZERISCHE BAUZ|Bauzeltung")] %>%
    str_replace_all(., "[^[:alnum:].:,?!;\\-]", " ") %>% # replace all characters that are neither letters, numbers, nor punctuation
    str_squish() %>% # reduce whitespace
    discard(~ nchar(.x) <= 2) %>% # discard lines with two characters only or less
    discard(~ !str_detect(.x, "[A-Za-z]")) # discard lines with no letters in it
  
  # Remove all occurrences of "Hans Marti" in the last line
  if (length(cleaned_text) > 0) {
    cleaned_text[length(cleaned_text)] <- str_replace_all(cleaned_text[length(cleaned_text)], "Hans Marti|H. M.", "")
  }
  
  cleaned_filename <- str_replace(basename(txt_file), "_trimmed\\.txt$", "_cleaned.txt")
  cleaned_txt_file <- file.path(output_folder, cleaned_filename)
  
  # Write cleaned text to a new file
  writeLines(cleaned_text, cleaned_txt_file)
  
  message("Processed: ", basename(txt_file))
}

# Loop over all txt files and clean them
lapply(txt_files, clean_file)

message("All files cleaned successfully.")