library(tidyverse)

# Function to process a single NZZ txt file
process_nzz <- function(nzz_file) {
  text_vector <- readLines(nzz_file, warn = FALSE)
  
  file_id <- str_replace(basename(nzz_file), "\\.txt$", "")
  meta_row <- metadata %>% filter(id == file_id)
  
  if (nrow(meta_row) == 0 || is.na(meta_row$first_row) || is.na(meta_row$last_row)) {
    message("Skipping: ", file_id, " (No metadata)")
    return()
  }
  
  # Trim text based on metadata
  first_row <- meta_row$first_row
  last_row <- meta_row$last_row
  if (first_row > length(text_vector) || last_row < 1) {
    message("Skipping: ", file_id, " (Invalid row range)")
    return()
  }
  text_vector <- text_vector[first_row:last_row]
  
  # Clean text
  text_vector <- text_vector %>%
    str_replace_all("Eans|Hans Marti|H. M.|H.M.|Haus Marti|Marf|Marti|Hans Marli|Ti. M.|rti$", "") %>%
    str_replace_all("Vgl. Nr.", "") %>% # remove internal newspaper references
    str_replace_all("(Fortsetzung folgt)", "") %>%
    discard(~ str_detect(.x, "^[^aeiouAEIOU]*$")) %>% # discard lines with no vowels,
    str_replace_all("[^[:alnum:].:,?!;\\-]", " ") %>% # replace all characters that are neither letters, numbers, nor punctuation
    str_squish() %>% # reduce whitespace
    discard(~ .x == "Von") %>%
    discard(~ nchar(.x) <= 3) # discard lines with two characters only or less

  # Apply NZZ OCR corrections
  text_vector <- str_replace_all(text_vector, nzz_corrections)
  
  # Save final cleaned text
  output_file <- file.path(output_folder, paste0(file_id, ".txt"))
  writeLines(text_vector, output_file)
  
  message("Processed: ", file_id)
}