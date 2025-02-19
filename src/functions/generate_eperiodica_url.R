# Define the function to generate the URL from the file ID
generate_url <- function(file_id) {
  base_url <- "https://www.e-periodica.ch/cntmng?type=pdf&pid="
  
  # Extract relevant parts from file_id (assuming consistent pattern)
  parts <- unlist(strsplit(file_id, "_"))
  if (length(parts) < 4) return(NA)  # Ensure correct format
  
  journal_code <- parts[1]
  year <- parts[2]
  volume <- parts[3]
  article_number <- parts[5]
  
  # Extract numerical part of article_number
  article_number <- gsub("[^0-9]", "", article_number)
  
  paste0(base_url, journal_code, ":", year, ":", volume, "::", article_number)
}