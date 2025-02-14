library(hunspell)
library(readtext)
library(here)
library(tidyverse)

# Load German dictionary
de_ch <- hunspell::dictionary(here("assets", "de_CH", "de_CH.dic"))

# Initialize spacy safely
tryCatch({
  spacy_initialize(model = "de_core_news_sm")
}, error = function(e) {
  message("Error initializing spacyr: ", e)
  stop("Please check your spaCy installation.")
})

# Define folders
input_folder <- here("data", "raw", "txt_cleaned")
output_folder <- here("data", "raw", "txt_checked")

if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Load text files safely
txt_files <- list.files(input_folder, pattern = "\\.txt$", full.names = TRUE)

# Function to check and correct spelling
correct_spelling_spacy <- function(text, dict) {
  # Split text into lines (prevents crashes)
  text_lines <- unlist(strsplit(text, "\n"))
  corrected_lines <- c()
  
  for (line in text_lines) {
    if (nchar(line) > 2) {  # Ignore very short lines
      spacy_output <- spacy_parse(line, pos = TRUE, lemma = TRUE)
      words <- spacy_output$token
      
      # Filter out numbers and symbols before checking spelling
      words <- words[str_detect(words, "^[A-Za-zäöüÄÖÜß-]+$")]
      
      misspelled <- words[!hunspell_check(words, dict = dict)]
      
      if (length(misspelled) > 0) {
        suggestions <- hunspell_suggest(misspelled, dict = dict)
        
        corrected_words <- words
        for (i in seq_along(misspelled)) {
          if (length(suggestions[[i]]) > 0) {
            corrected_words[corrected_words == misspelled[i]] <- suggestions[[i]][1]  # Use first suggestion
          }
        }
        corrected_lines <- c(corrected_lines, paste(corrected_words, collapse = " "))
      } else {
        corrected_lines <- c(corrected_lines, line)
      }
    }
  }
  
  return(paste(corrected_lines, collapse = "\n"))
}

# Process each file safely
for (txt_file in txt_files) {
  tryCatch({
    text <- readLines(txt_file, warn = FALSE)
    corrected_text <- correct_spelling_spacy(paste(text, collapse = "\n"), dict = de_ch)
    
    # Save corrected text
    corrected_filename <- str_replace(basename(txt_file), "_cleaned\\.txt$", "_checked.txt")
    writeLines(corrected_text, file.path(output_folder, corrected_filename))
    
    message("Processed: ", corrected_filename)
  }, error = function(e) {
    message("Error processing ", txt_file, ": ", e)
  })
}

message("All files spell-checked and saved successfully.")

# Finalize spacy session
spacy_finalize()
