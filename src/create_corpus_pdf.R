library(readtext)
library(here)
library(quanteda)
library(quanteda.textplots)

text_data <- readtext(here("data", "raw", "txt_cleaned", "*.txt"))
text_data$doc_id <- sub("\\_cleaned.txt$", "", text_data$doc_id)

# Data Cleaning
# Replace "sieh" with "sich"
text_data$text <- gsub("\\bsieh\\b", "sich", text_data$text)

metadata <- read.csv(here("docs", "overview.csv"), sep = ";")

# merge .txt data with metadata from overview file
text_data <- merge(text_data, metadata[, c("id", "title", "publication", "date", "lang")], 
                   by.x = "doc_id", by.y = "id", all.x = TRUE)

# remove articles that are not in German
text_data <- text_data[text_data$lang == "de", ]

# create corpus
marti_corpus <- corpus(text_data, text_field = "text")
summary(marti_corpus)

# tokenize corpus
marti_tokens <- tokens(marti_corpus,
                       remove_punct = TRUE,
                       remove_numbers = TRUE,
                       remove_symbols = TRUE)

summary(marti_tokens, 5)

# explore corpus
kwic(marti_tokens, pattern = "Locle")

head(docvars(marti_corpus))

# remove stopwords
marti_tokens_nostop <- tokens_select(marti_tokens,
                                     pattern = c(stopwords("de"), "dass"),
                                     selection = "remove")

# create dfm
dfmat_marti <- marti_corpus |>
  tokens(remove_punct = TRUE,
         remove_numbers = TRUE,
         remove_symbols = TRUE) |>
  tokens_select(pattern = c(stopwords("de"), "dass"),
                selection = "remove") |>
  dfm()

dfmat_marti_clean <- dfm_select(dfmat_marti, min_nchar = 2)

print(dfmat_marti_clean)

dfmat_marti_stem <- dfm_wordstem(dfmat_marti_clean, language = "de")

textplot_wordcloud(dfmat_marti_clean)
topfeatures(dfmat_marti_clean, 20)