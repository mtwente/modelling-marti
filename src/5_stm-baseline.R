library(here)
library(readr)
library(stm)
library(ggplot2)

# Read Data and Source Pre-Processing

source(here("src", "3_preprocessing.R"))

## preprocessing script creates a stmdfm_marti object for use in stm

## prepare stm object

#marti_prepped <- prepDocuments(stmdfm_marti$documents, stmdfm_marti$vocab, 
#                     stmdfm_marti$meta, lower.thresh = 1) # returns the same as dfm_trim w/2 docfreq!

stm_marti <- convert(dfm_marti, to = "stm",
                     docvars = docvars(marti_corpus))

stm_marti_prepped <- prepDocuments(stm_marti$documents, stm_marti$vocab,
                                   stm_marti$meta, lower.thresh = 0)

# compare number of topics to identify

#K <- c(5, 10, 15, 20, 30)
#kresult <- searchK(marti_prepped$documents, marti_prepped$vocab,
#                   K,
#                   data = marti_prepped$meta,
#                   max.em.its = 150, 
#                   init.type = "Spectral")

#plot(kresult)

# Baseline Model

k <- 10

stmFit_baseline <- stm(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                       K = k, max.em.its = 150,
                       data = stm_marti_prepped$meta,
                       init.type = "Spectral", seed = 300)

plot(stmFit_baseline, type = "summary",
     xlim = c(0, 0.7), ylim = c(0, 10.4), n = 5,
     main = "Baseline-Modell",
     width = 10, text.cex = 1)

## Plot Baseline Topics

topic <- data.frame(topicnames = paste0("Topic ", 1:k),
                    TopicNumber = 1:k,
                    TopicProportions = colMeans(stmFit_baseline$theta))

topicNames <- labelTopics(stmFit_baseline)

## Plot Baseline Topic Labels

#par(mfrow = c(k, 2), mar = c(1, 1, 2, 1))
#for (i in 1:k) {
#  plot(stmFit_baseline, type = "labels", n = 20, topics = i, main = "Label nach Wahrscheinlichkeiten", 
#       width = 40)
#  plot(stmFit_baseline, type = "labels", n = 20, topics = i, main = "Gewichtete Label (FREX)", labeltype = "frex", 
#       width = 50)
#}

baseline_labels <- labelTopics(stmFit_baseline, 1:k)
