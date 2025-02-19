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
    discard(~ str_detect(.x, "SCHWEIZERISCHE BAUZEITUNG|Schweiz\\. Bauzeitung|SCHWEIZERISCHE BAUZ|Bauzeltung")) %>%
    str_replace_all("[^[:alnum:].:,?!;\\-]", " ") %>% # replace all characters that are neither letters, numbers, nor punctuation
    str_squish() %>% # reduce whitespace
    discard(~ nchar(.x) <= 2) %>% # discard lines with two characters only or less
    discard(~ !str_detect(.x, "[A-Za-z]")) # discard lines with no letters in it
  
  if (length(text_vector) > 0) {
    text_vector[length(text_vector)] <- str_replace_all(text_vector[length(text_vector)], "Hans Marti|H. M.", "")
  }
  
  # Apply OCR corrections
  text_vector <- str_replace_all(text_vector, ocr_corrections)
  
  # Save final cleaned text
  output_file <- file.path(output_folder, paste0(file_id, ".txt"))
  writeLines(text_vector, output_file)
  
  message("Processed: ", file_id)
}