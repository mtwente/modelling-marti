library(tidyverse)
library(rJava)
library(tabulapdf)

# Function to process a single PDF file
process_pdf <- function(pdf_file) {
  text_content <- extract_text(pdf_file)
  text_vector <- str_split(text_content, "\n")[[1]]
  
  # Remove e-periodica header
  end_index <- which(str_detect(text_vector, "https://www\\.e-periodica\\.ch$"))
  if (length(end_index) > 0) {
    text_vector <- text_vector[(end_index + 1):length(text_vector)]
  }
  
  file_id <- str_replace(basename(pdf_file), "\\.pdf$", "")
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
    discard(~ str_detect(.x, "SCHWEIZERISCHE BAUZEITUNG|Schweiz\\. Bauzeitung|SCHWEIZERISCHE BAUZ|Bauzeltung|Beuzeltung|Schweizerische Bauzeitung\\s\\d+")) %>%
    discard(~ str_detect(.x, "([A-Za-z])\\1{3,}")) %>% # discard lines with the same letter three times in a row or more,
    discard(~ str_detect(.x, "^[^aeiouAEIOU]*$")) %>% # discard lines with no vowels,
    discard(~ str_detect(.x, "^(?!(.*\\b\\w{3,}\\b)).*$")) %>% # discard lines only with words with less than 4 characters
    discard(~ str_detect(.x, "^DD|DD$")) %>%
    str_replace_all("DK\\s\\d+\\W\\d+", "") %>% # discard newspaper meta information artefacts
    str_replace_all("[^[:alnum:].:,?!;\\-]", " ") %>% # replace all characters that are neither letters, numbers, nor punctuation
    str_squish() %>% # reduce whitespace
    discard(~ nchar(.x) <= 2) %>% # discard lines with two characters only or less
    discard(~ !str_detect(.x, "[A-Za-z]")) # discard lines with no letters in it
  
  if (length(text_vector) > 0) {
    text_vector[length(text_vector)] <- str_replace_all(text_vector[length(text_vector)], "Hans Marti|H. M.", "")
  }
  
  # Apply OCR corrections
  text_vector <- str_replace_all(text_vector, ocr_corrections) %>%
    discard(~ str_detect(.x, "[a-z][A-Z][a-z]")) # discard camelcase writing
  
  # Save final cleaned text
  output_file <- file.path(output_folder, paste0(file_id, ".txt"))
  writeLines(text_vector, output_file)
  
  message("Processed: ", file_id)
}