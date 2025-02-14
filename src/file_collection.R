# Load necessary library
library(dplyr)
library(here)

# Define the folders to scan
folders <- c(here("txt_nzz"), here("txt"))

# Get the list of .txt files from both folders
file_list <- unlist(lapply(folders, function(folder) {
  list.files(path = folder, pattern = "\\.txt$", full.names = TRUE)
}))

# Function to read the first line of a file
read_first_line <- function(file_path) {
  con <- file(file_path, "r")  # Open file for reading
  first_line <- readLines(con, n = 1, warn = FALSE)  # Read first line
  close(con)  # Close connection
  return(first_line)
}

# Create a data frame with file names and first lines
articles <- data.frame(
  file_name = tools::file_path_sans_ext(basename(file_list)),
  first_line = sapply(file_list, read_first_line),
  stringsAsFactors = FALSE
)

# Save the data frame as a CSV file
write.csv(articles, "articles.csv", row.names = FALSE)

# Print message
cat("CSV file 'articles.csv' has been created.\n")
