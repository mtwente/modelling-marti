library(here)
library(readtext)
library(tidyverse)
library(quanteda)

# Load Metadata Creation Function
source(here("src", "functions", "annotate_metadata.R"))

# Read Data -------
text_data <- readtext(here("data", "clean", "*.txt"))
text_data$doc_id <- sub("\\.txt$", "", text_data$doc_id)

metadata <- read.csv(here("docs", "articles_metadata.csv"), sep = ";")

# Merge .txt Data with Metadata
text_data <- merge(text_data, metadata[, c("id", "title", "publication", "date", "lang")], 
                   by.x = "doc_id", by.y = "id", all.x = TRUE)

# Convert Date Column to Actual Date Format
text_data <- text_data %>%
  mutate(
    date = case_when(
      # if the date is just a 4-digit year (e.g., "1960")
      str_detect(date, "^\\d{4}$") ~ ymd(paste0(date, "-01-01")),
      
      # if the date is in %d.%m.%y format
      str_detect(date, "^\\d{2}\\.\\d{2}\\.\\d{2}$") ~ {
        parsed <- dmy(date)
        # Ensure the year is treated as 1900s
        update(parsed, year = if_else(year(parsed) > 1999, year(parsed) - 100, year(parsed)))
      },
      
      TRUE ~ NA_Date_  # if no date is found
    )
  )

# Keep German Texts Only
text_data <- text_data %>%
  filter(lang == "de")

# Create Corpus -------
marti_corpus <- corpus(text_data, text_field = "text")

# Write Corpus to CSV
corpus_df <- convert(marti_corpus, to = "data.frame")
write.csv(corpus_df, here("build", "marti_corpus.csv"), row.names = FALSE)

# Create Corpus Metadata File -------
meta_marti <- annotate(data = corpus_df,
                      title = "Publizistische Tätigkeit von Hans Marti (Korpus)",
                      column_description = c("ID des Artikels", "Volltext des Artikels, je nach Text generiert aus PDF-Dateien oder aus OCR-Transkription auf e-newspaperarchives.ch", "Titel des Artikels", "Publikation, in dem der Artikel (erst-)veröffentlicht wurde", "Veröffentlichungsdatum im Format %Y-%m-%d. Für die laut Daten am 01.01. eines jeweiligen Jahres publizierten Beiträge sind in der Regel keine tagesgenauen Angaben vorhanden.", "ISO 639-1:2002-Code der Sprache, in der der Artikel verfasst ist"),
                      subject = c("Hans Marti", "Raumplanung", "Planungsgeschichte", "Schweizerische Bauzeitung", "Neue Zürcher Zeitung", "Das Werk", "Plan"),
                      object_description = "...",
                      creator = list(name = "Moritz Twente",
                                     email = "mtwente@protonmail.com",
                                     orcid = "0009-0005-7187-9774"),
                      date = "1946/1989",
                      temporal = "Contemporary",
                      source = "Volltexte von e-periodica.ch und e-newspaperarchives.ch. Bibliographie nach Ruedin/Hanak 2008 und eigener Recherche. Ersteller: Moritz Twente",
                      rights = "",
                      license = ""
)