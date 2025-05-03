# https://rawgit.com/wesslen/text-analysis-org-science/master/01-datacleaning-exploration.html

library(here)
library(readr)
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(RColorBrewer)
library(dplyr)
#library(ggplot2)
library(dendextend)

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

marti_tokens_full <- marti_corpus %>%
  tokens(remove_punct = TRUE,
         remove_numbers = TRUE,
         remove_symbols = TRUE) %>%
  tokens_tolower(keep_acronyms = T)

extra_stopwords <- c("ja", "dass", "müssen", "schon", "wäre", "würde", "worden",
                     "wurde", "wurden", "sollen", "a", "h", "dr", "i", "s", "beim",
                     "sei", "überhaupt", "gerade", "einfach", "nämlich", "wer", "dafür", "m")

marti_tokens_clean <- marti_tokens_full %>%
  tokens_remove(pattern = c(stopwords("de"),
                            extra_stopwords))

#dfm_marti <- dfm(marti_tokens_clean)

# Exploration
#topfeatures(dfm_marti)

# find collocations

marti_tokens_collocations <- textstat_collocations(marti_tokens_clean,
                                                   min_count = 3)
head(marti_tokens_collocations, 10)

# nur kanton ZH und Region ZH und Agglomeration ZH verwenden, aber nicht stadt
collocations <- c("kanton zürich", "agglomeration zürich", "region zürich",
                  "kanton solothurn", "kanton bern", "kanton st gallen", "st gallen",
                  "hans marti", "max frisch", "werner moser", "rolf meyer",
                  "vereinigung landesplanung") %>%
  phrase()

marti_tokens_compounded <- tokens_compound(marti_tokens_clean,
                                           pattern = collocations)

kw_comp <- kwic(marti_tokens_compounded, pattern = c("kanton_st_gallen"))

dfm_marti <- dfm(marti_tokens_compounded)
topfeatures(dfm_marti)

# Sparse Terms

## Explore sparse terms
dfm_sparse <- dfm_trim(dfm_marti, max_docfreq = 2)
topfeatures(dfm_sparse)

# Remove sparse terms
dfm_marti <- dfm_trim(dfm_marti, min_docfreq = 2)

textplot_wordcloud(dfm_marti, scale = c(3.5, 0.75), colors = brewer.pal(8, "Dark2"), random.order = F, 
                   rot.per = 0.1, max.words = 100)

#dfmat_group <- dfm_group(dfm_trimmed, dfm_trimmed$publication)

#cloud_comparison <- textplot_wordcloud(dfmat_group, comparison = TRUE, max_words = 100, colors = brewer.pal(8, "Dark2"))
  
wordDfm <- dfm_sort(dfm_weight(dfm_marti, "prop"))
wordDfm <- t(wordDfm)[1:50, ]
wordDistMat <- dist(wordDfm)
wordCluster <- hclust(wordDistMat)

dend <- as.dendrogram(wordCluster) %>%
  hang.dendrogram()
#dend <- hang.dendrogram(dend)

# Optional customizations
dend <- set(dend, "labels_cex", 0.5)
dend <- set(dend, "branches_lwd", 1.2)

# Plot with horizontal layout and rotated labels
plot_horiz.dendrogram(dend,
                      side = F,
                      )