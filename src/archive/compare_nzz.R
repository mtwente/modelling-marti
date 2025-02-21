library(stringr)
library(here)

# File paths (adjust if needed)
raw_folder <- here("data", "raw", "txt_nzz")
clean_folder <- here("data", "clean", "nzz_test")
output_file <- here("removed_strings.txt")

# Get list of raw .txt files
raw_files <- list.files(raw_folder, pattern = "\\.txt$", full.names = TRUE)

# Initialize set to store unique removed words
all_removed_words <- character()

for (raw_file in raw_files) {
  # Determine corresponding corrected file
  file_name <- basename(raw_file)
  corrected_file <- file.path(clean_folder, file_name)
  
  if (!file.exists(corrected_file)) {
    cat("Warning: No corrected file found for", file_name, "\n")
    next
  }
  
  # Read and collapse files into a single line
  uncorrected_text <- tolower(paste(readLines(raw_file, warn = FALSE), collapse = " "))
  corrected_text <- tolower(paste(readLines(corrected_file, warn = FALSE), collapse = " "))
  
  # Split into words
  uncorrected_words <- unlist(strsplit(uncorrected_text, "\\s+"))
  corrected_words <- unlist(strsplit(corrected_text, "\\s+"))
  
  # Find words in uncorrected file that are not in corrected file
  removed_words <- setdiff(uncorrected_words, corrected_words)
  
  # Store unique removed words
  all_removed_words <- unique(c(all_removed_words, removed_words))
}

# Save all unique removed words to a file
writeLines(all_removed_words, output_file)

cat("Removed words saved to", output_file, "\n")