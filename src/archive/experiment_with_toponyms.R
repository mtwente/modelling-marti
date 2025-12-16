library(readr)
library(here)
library(magrittr)
library(quanteda)
library(dplyr)

marti_corpus <- read_csv(here("build", "marti_corpus.csv")) %>%
  corpus(text_field = "text")

marti_tokens <- marti_corpus %>%
  tokens(remove_punct = TRUE,
         remove_numbers = TRUE,
         remove_symbols = TRUE) %>%
  tokens_tolower(keep_acronyms = T)


AMTOVZ_CSV_LV95 <- read_delim("assets/AMTOVZ_CSV_LV95/AMTOVZ_CSV_LV95.csv", 
                              delim = ";", escape_double = FALSE, trim_ws = TRUE)

#toponyms_filtered <- subset(AMTOVZ_CSV_LV95, Ortschaftsname != "Ins")

kwic_matches <- kwic(marti_tokens, pattern = AMTOVZ_CSV_LV95$Ortschaftsname,
                     valuetype = "fixed", case_insensitive = TRUE)
# this returns duplicates

toporesults <- kwic_matches %>%
  count(pattern, name = "frequency")

toporesults <- toporesults %>%
  left_join(AMTOVZ_CSV_LV95 %>% select(Ortschaftsname, E, N), 
            by = c("pattern" = "Ortschaftsname"))