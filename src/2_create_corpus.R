library(here)
library(readtext)
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

# Keep German Texts Only
text_data <- text_data[text_data$lang == "de", ]

# Create Corpus -------
marti_corpus <- corpus(text_data, text_field = "text")

# Write Corpus to CSV
corpus_df <- convert(marti_corpus, to = "data.frame")
write.csv(corpus_df, here("build", "marti_corpus.csv"), row.names = FALSE)

# Create Corpus Metadata File -------
meta_marti <- annotate(data = corpus_df,
                      title = "Publizistische Tätigkeit von Hans Marti (Korpus)",
                      column_description = c("ID des Artikels", "Volltext des Artikels, je nach Text generiert aus PDF-Dateien oder aus OCR-Transkription auf e-newspaperarchives.ch", "Titel des Artikels", "Publikation, in dem der Artikel (erst-)veröffentlicht wurde", "Veröffentlichungsdatum im Format %d.%m.%y oder, vereinzelt, im Format %Y.", "ISO 639-1:2002-Code der Sprache, in der der Artikel verfasst ist"),
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