library(tidyverse)
library(here)
library(rJava)
library(tabulapdf)

input_folder <- here("data", "raw", "pdf")
output_folder <- here("data", "raw", "txt")
#rds_file <- here("datacorpus.rds")

if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# Get a list of all PDF files in the "pdf" folder
pdf_files <- list.files(input_folder, pattern = "\\.pdf$", full.names = TRUE)

# Initialize an empty list to store text data
text_data <- list()

# Function to clean text content
clean_text <- function(text_vector) {
  # Find the index of the line that starts with "DOI:"
  doi_index <- which(str_detect(text_vector, "^DOI:"))
  
  # Find the index of the line that ends with "https://www.e-periodica.ch"
  end_index <- which(str_detect(text_vector, "https://www\\.e-periodica\\.ch$"))
  
  if (length(doi_index) > 0 && length(end_index) > 0) {
    # Keep only the lines before "DOI:" and after "https://www.e-periodica.ch"
    text_vector <- text_vector[c(1:doi_index, (end_index + 1):length(text_vector))]
  }
  
  return(text_vector)
}

# Loop through each PDF file and extract text
for (pdf_file in pdf_files) {
  # Extract text from the PDF
  text_content <- extract_text(pdf_file)
  
  # Convert text content into a vector (one line per element)
  text_vector <- str_split(text_content, "\n")[[1]]
  
  # Clean the text
  cleaned_text <- clean_text(text_vector)
  
  # Generate output filename in the "txt" folder
  txt_filename <- str_replace(basename(pdf_file), "\\.pdf$", ".txt")
  txt_file <- file.path(output_folder, txt_filename)
  
  # Store the cleaned text in a list (collapsed into a single string)
  text_data[[txt_filename]] <- paste(cleaned_text, collapse = "\n")
  
  # Write cleaned text to the .txt file
  #write_lines(cleaned_text, txt_file)
  
  message("Processed: ", basename(pdf_file))
}

# Convert list to data frame
#corpus_df <- tibble(
#  file_name = names(text_data),
#  text = unlist(text_data)
#)

# Save data frame as an RDS file
#saveRDS(corpus_df, rds_file)

#message("Corpus saved to: ", rds_file)