cutoff <- function(text_vector, file_id, manual_cutoffs) {
  start_str <- NULL
  end_str <- NULL
  
  # Get cutoff strings for this file
  if (is.data.frame(manual_cutoffs)) {
    cutoff_row <- manual_cutoffs %>% filter(id == file_id)
    if (nrow(cutoff_row) == 1) {
      start_str <- cutoff_row$start_string
      end_str <- cutoff_row$end_string
    }
  } else if (is.list(manual_cutoffs)) {
    start_str <- manual_cutoffs[[file_id]]$start
    end_str <- manual_cutoffs[[file_id]]$end
  }
  
  # Collapse text to single string
  full_text <- paste(text_vector, collapse = " ")
  
  # Apply start cutoff
  if (!is.null(start_str) && !is.na(start_str) && start_str != "") {
    start_pos <- str_locate(full_text, fixed(start_str))[2]
    if (!is.na(start_pos)) {
      full_text <- str_sub(full_text, start_pos + 1)
      message("Start cutoff applied for ", file_id, " at '", start_str, "'")
    }
  }
  
  # Apply end cutoff
  if (!is.null(end_str) && !is.na(end_str) && end_str != "") {
    end_pos <- str_locate(full_text, fixed(end_str))[1]
    if (!is.na(end_pos)) {
      full_text <- str_sub(full_text, 1, end_pos - 1)
      message("End cutoff applied for ", file_id, " at '", end_str, "'")
    }
  }
  
  # Split text back into chunks (heuristic: sentence endings or double spaces)
  #text_vector <- str_split(full_text, "\\s{2,}|(?<=[.!?])\\s+")[[1]]
  return(full_text)
}