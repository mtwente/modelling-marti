library(here)
library(readr)
library(stm)
library(ggplot2)

# Read Data and Source Pre-Processing

source(here("src", "3_preprocessing.R"))

## preprocessing script creates a stmdfm_marti object for use in stm

## prepare stm object

stm_marti <- convert(dfm_marti, to = "stm",
                     docvars = docvars(marti_corpus))

stm_marti_prepped <- prepDocuments(stm_marti$documents, stm_marti$vocab,
                                   stm_marti$meta, lower.thresh = 0)

# Compare Numbers of Topics to Identify

K <- c(5, 9, 10, 11, 15, 20, 30)
kresult <- searchK(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                   K,
                   data = stm_marti_prepped$meta,
                   max.em.its = 150, 
                   init.type = "Spectral")

plot(kresult)
