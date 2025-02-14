library(readtext)
library(here)
library(quanteda)
library(quanteda.textplots)
library(seededlda)

text_data <- readtext(here("data", "clean", "*.txt"))
text_data$doc_id <- sub("\\.txt$", "", text_data$doc_id)

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
nzz_corpus <- corpus(text_data, text_field = "text")
summary(nzz_corpus)

# tokenize corpus
nzz_tokens <- tokens(nzz_corpus, remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE)
summary(nzz_tokens, 5)

# explore corpus
kwic(nzz_tokens, pattern = "Arbon")

head(docvars(nzz_corpus))

# remove stopwords
nzz_tokens_nostop <- tokens_select(nzz_tokens, pattern = c(stopwords("de"), "dass"), selection = "remove")

# create dfm
dfmat_nzz <- nzz_corpus |>
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) |>
  tokens_select(pattern = c(stopwords("de"), "dass"), selection = "remove") |>
  dfm()

print(dfmat_nzz)

textplot_wordcloud(dfmat_nzz)
topfeatures(dfmat_nzz, 20)

dfmat_nzz_stem <- dfm_wordstem(dfmat_nzz, language = "de")

# remove infrequent terms
#dfmat_nzz_freq <- dfm_trim(dfmat_nzz, min_termfreq = 10) # removes features that appear less than 10 times (uncommon features)
#print(dfmat_nzz_freq)
#nfeat(dfmat_nzz_freq)
#nfeat(dfmat_nzz)

# topic modelling
tmod_lda <- textmodel_lda(dfmat_nzz_stem, k = 10)
terms(tmod_lda, 10)
topics(tmod_lda)