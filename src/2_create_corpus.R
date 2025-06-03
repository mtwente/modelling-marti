library(here)
library(readtext)
library(tidyverse)
library(quanteda)
library(readr)
library(dplyr)

# Load Metadata Creation Function
source(here("src", "functions", "annotate_metadata.R"))

# Read Data -------
text_data <- readtext(here("data", "clean", "*.txt"))
text_data$doc_id <- sub("\\.txt$", "", text_data$doc_id)

metadata <- read.csv(here("docs", "articles_metadata.csv"), sep = ";")

berufslaufbahn <- read_csv2(here("docs", "marti_berufslaufbahn.csv"), 
                          col_types = cols(
                            Start = col_date(format = "%Y-%m-%d"),
                            Ende = col_date(format = "%Y-%m-%d")
                          ))

# Transform Data -------

# Merge .txt Data with Metadata
text_data <- merge(text_data, metadata[, c("id", "title", "publication", "date", "language")], 
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

# Turn Metadata into Covariate Variables

## Add Job Positions as Boolean (Ranges)
for (i in seq_len(nrow(berufslaufbahn))) {
  beruf_name <- berufslaufbahn$Beruf[i]
  start_date <- berufslaufbahn$Start[i]
  end_date <- berufslaufbahn$Ende[i]
  
  # Clean column name: make safe for variable names
  col_name <- make.names(beruf_name)
  
  text_data <- text_data %>%
    mutate(!!col_name := date >= start_date & date <= end_date)
}

## add binary columns for covariate analysis
fachzeitschriften <- c("Plan", "Schweizerische Bauzeitung", "Das Werk", "Wohnen")

text_data <- text_data %>%
  mutate(
    fachpublikum = publication %in% fachzeitschriften,
    pol_mandat = Delegierter == TRUE | Gemeinderat == TRUE
  )

# Keep German Texts Only
text_data <- text_data %>%
  filter(language == "de")

# Create Corpus -------
marti_corpus <- corpus(text_data, text_field = "text")

# Write Corpus to CSV
corpus_df <- convert(marti_corpus, to = "data.frame")
write.csv(corpus_df, here("build", "marti_corpus.csv"), row.names = FALSE)

# Create Corpus Metadata File -------
meta_marti <- annotate(data = corpus_df,
                      title = "Publizistische Tätigkeit von Hans Marti (Korpus)",
                      column_description = c("ID des Artikels",
                                             "Volltext des Artikels, je nach Text generiert aus PDF-Dateien oder aus OCR-Transkription auf e-newspaperarchives.ch",
                                             "Titel des Artikels",
                                             "Publikation, in dem der Artikel (erst-)veröffentlicht wurde",
                                             "Veröffentlichungsdatum im Format %Y-%m-%d. Für die laut Daten am 01.01. eines jeweiligen Jahres publizierten Beiträge sind in der Regel keine tagesgenauen Angaben vorhanden",
                                             "ISO 639-1-Code der Sprache, in der der Artikel verfasst ist",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt im Zentralsekretariat der Schweiz. Vereinigung für Landesplanung arbeitete.",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt als Redaktor für die Schweizerische Bauzeitung arbeitete",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt als Delegierter für Stadtplanung des Zürcher Stadtrates arbeitete",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt Mitglied des Zürcher Gemeinderates war",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt pensioniert war",
                                             "Angabe, ob der jeweilige Artikel in einem Medium publiziert wurde, das sich vorrangig an Fachleute im Bereich Planung bzw. Architektur richtete (z.B. die Schweizerische Bauzeitung)",
                                             "Angabe, ob Hans Marti zum Veröffentlichungszeitpunkt ein politisches Mandat innehate (gemeint sind seine Mitgliedschaft im Zürcher Gemeinderat und sein Amt als Delegierter für Stadtplanung)"),
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