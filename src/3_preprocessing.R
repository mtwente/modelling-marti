# https://rawgit.com/wesslen/text-analysis-org-science/master/01-datacleaning-exploration.html

library(here)
library(readr)
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)
library(dplyr)
library(stm)

# read data
text_data <- read_csv(here("build", "marti_corpus.csv"),
                      col_types = cols(
                        date = col_date(format = "%Y-%m-%d"))
                      )
# create corpus

marti_corpus <- corpus(text_data, text_field = "text")

# find shortest texts
maxWords <- 300
under300 <- as.data.frame(text_data$text[which(ntoken(tokens(text_data$text)) < maxWords)])

# find covariates
text_data %>% group_by(publication) %>% summarise(Count = n())

## covariates: job positions
## now part of corpus creation

# tokenize & remove stopwords

marti_tokens_full <- marti_corpus %>%
  tokens(remove_punct = TRUE,
         remove_numbers = TRUE,
         remove_symbols = TRUE) %>%
  tokens_tolower(keep_acronyms = T)

extra_stopwords <- c("ja", "dass", "müssen", "schon", "wäre", "würde", "worden",
                     "wurde", "wurden", "sollen", "a", "h", "dr", "i", "s", "beim",
                     "sei", "überhaupt", "gerade", "einfach", "nämlich", "wer", "dafür", "m",
                     "gar", "ganz", "wären",
                     
                     # extra after iterations
                     "stadt", "städte", "heute", "mehr", "nr", "jahren", "bild", "cm", "ca",
                     "e", "etwa", "immer", "wohl", "viele", "sogar", "vielleicht", "grosse", "gross",
                     
                     # frz. Reste
                     "le", "les", "de")

marti_tokens_clean <- marti_tokens_full %>%
  tokens_remove(pattern = c(stopwords("de"),
                            extra_stopwords))

# find collocations

marti_tokens_collocations <- textstat_collocations(marti_tokens_clean,
                                                   min_count = 3)
head(marti_tokens_collocations, 10)

## nur kanton ZH und Region ZH und Agglomeration ZH verwenden, aber nicht stadt
collocations <- c("kanton zürich", "agglomeration zürich", "region zürich",
                  "kanton solothurn", "kanton bern", "kanton st gallen", "st gallen",
                  "hans marti", "max frisch", "werner moser", "rolf meyer",
                  "vereinigung landesplanung", "knonauer amt", "st margrethen") %>%
  phrase()

marti_tokens_compounded <- tokens_compound(marti_tokens_clean,
                                           pattern = collocations)

kw_comp <- kwic(marti_tokens_compounded, pattern = c("st_*"))

dfm_marti <- dfm(marti_tokens_compounded)
topfeatures(dfm_marti)

#### EXTRA

# Stemming

dfm_marti <- dfm_wordstem(dfm_marti, language = "de")

# x-ray plot for additional stemming

kwic_zurich <- kwic(marti_tokens_compounded, pattern = "zürich")

textplot_xray(kwic_zurich) +
  ggtitle(paste('Keywords in context:', 'zürich'))

# remove additional stopwords after stemming
stemmed_stopwords <- c("uns", "gross", "erst", "neu", "alt", "wohl", "abb",
                       "zurich", "plan", "bau", "gemeind", "planung")

dfm_marti <- dfm_remove(dfm_marti, pattern = stemmed_stopwords)

# visualise top features

tstat_freq_marti <- textstat_frequency(dfm_marti, n = 100)

ggplot(tstat_freq_marti, aes(x = frequency, y = reorder(feature, frequency))) +
  geom_point() + 
  labs(x = "Frequency", y = "Feature")

####

# Sparse Terms

## Explore sparse terms
dfm_sparse <- dfm_trim(dfm_marti, max_docfreq = 2)
topfeatures(dfm_sparse)

## Visualize Sparsity Settings with stm

stmdfm_marti <- convert(dfm_marti, to = "stm",
                        docvars = docvars(marti_corpus))

sparsity_details <- plotRemoved(stmdfm_marti$documents,
                                lower.thresh = seq(1, 10, by = 1))

## Remove sparse terms
dfm_marti <- dfm_trim(dfm_marti, min_docfreq = 2)

# Export dfm as data frame for easy re-use in analysis script

#dfm_marti_df <- dfm_marti %>%
#  convert(to = "data.frame") %>% 
#  cbind(docvars(dfm_marti))

### this csv will be gitignored
#write.csv(dfm_marti_df, here("build", "marti_dfm_df.csv"), row.names = FALSE)

#stm_marti <- convert(dfm_marti, to = "stm")