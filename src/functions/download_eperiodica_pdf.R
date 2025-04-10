library(httr)

# Function to download PDF from e-periodica.ch
download_pdf <- function(url, file_id, output_dir = output_folder) {
  if (!dir.exists(output_dir)) dir.create(output_dir)
  
  pdf_path <- file.path(output_dir, paste0(file_id, ".pdf"))
  
  response <- GET(url, write_disk(pdf_path, overwrite = TRUE))
  
  if (inherits(response, "try-error") || status_code(response) != 200) {
    message("Failed to fetch: ", article_id)
    return(NULL)
  }
  
  #if (http_status(response)$category == "Success") {
  #  message("Downloaded: ", pdf_path)
  #} else {
  #  message("Failed to download: ", file_id)
  #}
  
  message("Downloaded: ", file_id)
}