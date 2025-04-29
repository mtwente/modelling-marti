library(here)

# Define folder path
folder_path <- here("data", "clean")

# Get all .txt files
txt_files <- list.files(folder_path, pattern = "\\.txt$", full.names = TRUE)

# Function to clean hyphenated line breaks with full rule set
clean_hyphenated_breaks <- function(lines) {
  result <- character()
  i <- 1
  while (i <= length(lines)) {
    line <- lines[i]
    
    # Check for a hyphen directly after a non-space character at line end
    if (grepl("[^\\s]-$", line) && i < length(lines)) {
      next_line <- lines[i + 1]
      next_word <- sub("^\\s*", "", next_line)  # Trim leading whitespace
      
      if (grepl("^(und|Abb\\.|Ahl|Fig\\.|beziehungsweise)", next_word)) {
        # Leave unchanged
        result <- c(result, line)
      } else if (grepl("^[A-ZÄÖÜ]", next_word)) {
        # Keep hyphen when next word starts with capital letter
        merged <- paste0(line, next_line)
        result <- c(result, merged)
        i <- i + 1  # Skip next line
      } else {
        # Remove hyphen and merge lines
        merged <- paste0(sub("-$", "", line), next_line)
        result <- c(result, merged)
        i <- i + 1  # Skip next line
      }
    } else {
      result <- c(result, line)
    }
    i <- i + 1
  }
  return(result)
}

# Process each file
for (file in txt_files) {
  lines <- readLines(file, warn = FALSE)
  cleaned_lines <- clean_hyphenated_breaks(lines)
  writeLines(cleaned_lines, con = file)
}
