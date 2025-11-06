library(here)
library(readr)
library(stm)
library(lubridate)
library(dplyr)
library(tidyr)

# Read Data and Source Pre-Processing

source(here("src", "6_stm-covariates.R"))

# Turn Metadata Variables into categorical format:

cols_cov <- c("publication", "pol_mandat", "fachpublikum")

stm_marti_prepped$meta[cols_cov] <- lapply(
  stm_marti_prepped$meta[cols_cov],
  as.factor
  )

# EFFECT 1: FACHPUBLIKUM

## Estimate effect
topic_effect_fachpublikum <- estimateEffect(
  1:k ~ fachpublikum,
  stmFit_cov,
  metadata = stm_marti_prepped$meta,
  documents = stm_marti_prepped$documents
)

summary(topic_effect_fachpublikum)

# Plotting the difference in topic prevalence: fachpublikum = TRUE vs FALSE
plot.estimateEffect(
  topic_effect_fachpublikum,
  covariate = "fachpublikum",
  topics = 1:k,
  model = stmFit_cov,
  method = "difference",
  cov.value1 = "TRUE",  # Treated as group 1
  cov.value2 = "FALSE", # Treated as reference
  xlab = "Effect of Fachpublikum (TRUE vs FALSE)",
  main = "Topic Prevalence by Fachpublikum",
  xlim = c(-0.2, 0.2)
)

# EFFECT 1a: FACHPUBLIKUM OVER TIME

stm_marti_prepped$meta$year <- as.numeric(format(ymd(stm_marti_prepped$meta$date), "%Y"))

topic_effect_fachpublikum_time <- estimateEffect(
  1:k ~ fachpublikum * year,
  stmFit_cov,
  metadata = stm_marti_prepped$meta,
  documents = stm_marti_prepped$documents
)

plot.estimateEffect(
  topic_effect_fachpublikum_time,
  covariate = "year",
  method = "continuous",
  moderator = "fachpublikum",
  moderator.value = c("TRUE", "FALSE"),
  topics = c(6, 7),
  model = stmFit_cov,
  printlegend = TRUE
)

# EFFECT 2: PUBLICATION COMPARISON

## Estimate the effect of publication on topic prevalence
topic_effect_publication <- estimateEffect(
  1:k ~ publication,
  stmFit_cov,
  metadata = stm_marti_prepped$meta,
  documents = stm_marti_prepped$documents
)

summary(topic_effect_publication)

plot.estimateEffect(
  topic_effect_publication,
  covariate = "publication",
  topics = 1:k,
  model = stmFit_cov,
  method = "difference",
  cov.value1 = "NZZ", # Group of interest
  cov.value2 = "Schweizerische Bauzeitung", # Reference group
  xlab = "Effect of Publication (NZZ vs SBZ)",
  main = "Topic Prevalence by Journal",
  xlim = c(-0.2, 0.2),
)

# EFFECT 3: POL_MANDAT

topic_effect_pol_mandat <- estimateEffect(
  1:k ~ pol_mandat,
  stmFit_cov,
  metadata = stm_marti_prepped$meta,
  documents = stm_marti_prepped$documents
)

# DIFFERENCES IN TRAFFIC TOPICS 6,7

plot(stmFit_cov, type="perspectives", topics = c(6,7),
     plabels = c("6 Strassenbau", "7 Stadtraum"))