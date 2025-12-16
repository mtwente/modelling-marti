library(quanteda)
library(textTinyR)
library(readr)
library(here)

# compare preprocessing stopwords from different sources
# based on:
# https://kodaqs-toolbox.gesis.org/github.com/YannikPeters/DQ_Tool_TextPreprocessing/index/

# Load Data

text_data <- read_csv(here("build", "marti_corpus.csv"),
                      col_types = cols(
                        date = col_date(format = "%Y-%m-%d"))
)

# Test Stopwords

#stop_de_snowball <- stopwords("de", source = "snowball") # 231
stop_de_iso <- stopwords("de", source = "stopwords-iso") # 621
stop_de_marimo <- stopwords("de", source = "marimo") # 505
stop_de_nltk <- stopwords("de", source = "nltk") # 232

marti_text_full_nltk <- text_data
marti_text_full_marimo <- text_data
marti_text_full_iso <- text_data

#function to extract stopwords
extract_stopwords <- function(text, source) {
  # Get stopwords for the specified source
  stops <- stopwords::stopwords(language = "de", source = source)
  # Split into words
  words <- text %>%
    strsplit("\\s+") %>%
    unlist()
  # Find intersection with stopwords
  found_stops <- intersect(words, stops)
  # Return as string
  paste(found_stops, collapse = ", ")
}

# Apply extraction for each source

marti_text_full_nltk <- marti_text_full_nltk %>%
  dplyr::mutate(
    nltk_stopwords = sapply(text, extract_stopwords, source = "nltk"))

marti_text_full_marimo <- marti_text_full_marimo %>%
  dplyr::mutate(
    marimo_stopwords = sapply(text, extract_stopwords, source = "marimo"))

marti_text_full_iso <- marti_text_full_iso %>%
  dplyr::mutate(
    iso_stopwords = sapply(text, extract_stopwords, source = "stopwords-iso"))

#number of stopwords (unique stopwords per row)
sum(stringr::str_count(marti_text_full_nltk$nltk_stopwords, '\\w+'))
sum(stringr::str_count(marti_text_full_marimo$marimo_stopwords, '\\w+'))
sum(stringr::str_count(marti_text_full_iso$iso_stopwords, '\\w+'))

## Compare Similarities between Stopword Sources

remove_stopwords <- function(data, text_column, stopword_source) {
  # Get stopwords from the stopwords package
  stops <- stopwords::stopwords(language = "de", source = stopword_source)
  
  # Remove stopwords from the specified text column
  data[[text_column]] <- sapply(data[[text_column]], function(text) {
    words <- strsplit(text, "\\s+")[[1]]       # Split text into words
    filtered_words <- setdiff(words, stops)     # Remove stopwords
    paste(filtered_words, collapse = ", ")       # Reassemble text without stopwords
  })
  
  return(data)
}

# Example usage
marti_text_full_nltk <- remove_stopwords(marti_text_full_nltk, "text", "nltk")
marti_text_full_marimo <- remove_stopwords(marti_text_full_marimo, "text", "marimo")
marti_text_full_iso <- remove_stopwords(marti_text_full_iso, "text", "stopwords-iso")

# Calculating cosine similarity
cosine_similarities_nltk_marimo <- textTinyR::COS_TEXT(marti_text_full_nltk$text, marti_text_full_marimo$text, separator = " ")
cosine_similarities_nltk_iso <- textTinyR::COS_TEXT(marti_text_full_nltk$text, marti_text_full_iso$text, separator = " ")
cosine_similarities_marimo_iso <- textTinyR::COS_TEXT(marti_text_full_marimo$text, marti_text_full_iso$text, separator = " ")

mean(cosine_similarities_nltk_marimo)
mean(cosine_similarities_nltk_iso)
mean(cosine_similarities_marimo_iso)

# Identify words exclusively removed by one source

# Combine the three stopword variables into one data frame
combined_df <- data.frame(nltk_stopwords = marti_text_full_nltk$nltk_stopwords,
                          marimo_stopwords = marti_text_full_marimo$marimo_stopwords,
                          iso_stopwords = marti_text_full_iso$iso_stopwords,
                          stringsAsFactors = FALSE)

# Function to create a unique word list from a string
get_unique_words <- function(column) {
  unique(unlist(stringr::str_split(column, ",\\s*")))  # Split by commas and remove spaces
}

# Create sets of unique words for each column
words_nltk <- get_unique_words(combined_df$nltk_stopwords)
words_marimo <- get_unique_words(combined_df$marimo_stopwords)
words_iso <- get_unique_words(combined_df$iso_stopwords)

# Words only in column nltk_stopwords
unique_nltk <- setdiff(words_nltk, union(words_marimo, words_iso))

# Words only in column marimo_stopwords
unique_marimo <- setdiff(words_marimo, union(words_nltk, words_iso))

# Words only in column iso_stopwords
unique_iso <- setdiff(words_iso, union(words_nltk, words_marimo))

# Display the results
cat("Words only in nltk_stopwords:", unique_nltk, "\n")

# Compare Marimo and Iso Stop Word Lists

get_unique_words_2 <- function(column) {
  unique(unlist(stringr::str_split(column, ",\\s*")))  # Split by commas and remove spaces Leerzeichen
}

# Create sets of unique words for each column
words_marimo <- get_unique_words(combined_df$marimo_stopwords)
words_iso <- get_unique_words(combined_df$iso_stopwords)

# Words only in column marimo_stopwords
unique_marimo <- setdiff(words_marimo, words_iso)

# Words only in column iso_stopwords
unique_iso <- setdiff(words_iso, words_marimo)

# Display the results
cat("Words only in marimo_stopwords:", unique_marimo, "\n")
cat("Words only in iso_stopwords:", unique_iso, "\n")