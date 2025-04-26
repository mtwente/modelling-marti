# https://rawgit.com/wesslen/text-analysis-org-science/master/01-datacleaning-exploration.html

library(here)
library(readr)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(RColorBrewer)

# read corpus
text_data <- read_csv(here("build", "marti_corpus.csv"),
                      col_types = cols(
                        date = col_date(format = "%Y-%m-%d"))
                      )

marti_corpus <- corpus(text_data, text_field = "text")

# find shortest texts
maxWords <- 300
under300 <- as.data.frame(text_data$text[which(ntoken(text_data$text) < maxWords)])

# find covariates

text_data %>% group_by(publication) %>% summarise(Count = n())

## covariates: job positions
## now part of corpus creation

## tokenize & remove stopwords

marti_tokens <- marti_corpus %>%
  tokens(remove_punct = TRUE,
         remove_numbers = TRUE,
         remove_symbols = TRUE) %>%
  tokens_tolower(keep_acronyms = T)

extra_stopwords <- c("ja", "dass", "müssen", "schon", "wäre", "würde", "worden",
                     "wurde", "wurden", "sollen", "a", "h", "dr", "i", "s", "beim",
                     "sei", "überhaupt", "gerade", "einfach", "nämlich", "wer", "dafür", "m")

dfm_marti <- marti_tokens %>%
  tokens_remove(pattern = c(stopwords("de"),
                            extra_stopwords)) %>%
  dfm()

# Exploration

topfeatures(dfm_marti)

# remove sparse terms
dfm_trimmed <- dfm_trim(dfmat_marti, min_docfreq = 2)
topfeatures(dfm_trimmed)

textplot_wordcloud(dfm_trimmed, scale = c(3.5, 0.75), colors = brewer.pal(8, "Dark2"), random.order = F, 
                   rot.per = 0.1, max.words = 100)

#dfmat_group <- dfm_group(dfm_trimmed, dfm_trimmed$publication)

#cloud_comparison <- textplot_wordcloud(dfmat_group, comparison = TRUE, max_words = 100, colors = brewer.pal(8, "Dark2"))
  
wordDfm <- dfm_sort(dfm_weight(dfmat_marti, "prop"))
wordDfm <- t(wordDfm)[1:50, ]  # because transposed
wordDistMat <- dist(wordDfm)
wordCluster <- hclust(wordDistMat)
plot(wordCluster, xlab = "", main = "Proportional weighting")