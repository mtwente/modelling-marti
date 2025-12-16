library(here)
library(hunspell)

# Set the directory containing your text files
folder_path <- here("data", "clean")

# Get a list of all .txt files in the folder
txt_files <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Read each file into a list
text_list <- lapply(txt_files, readLines, encoding = "UTF-8")

# Optionally, combine all files into a single character vector
all_text <- unlist(text_list)

# Print the first few lines to check
head(all_text)

misspelled_words <- hunspell(all_text, dict = "de_DE")

unique_misspelled <- unique(unlist(misspelled_words))
print(unique_misspelled)

writeLines(unique_misspelled, here("build", "hunspell_result.txt"))

