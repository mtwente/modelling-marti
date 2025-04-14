library(csvwr)
library(jsonlite)

annotate <- function(data, title, column_description, subject, object_description, creator,
                     date, temporal, source, rights, license) {
  
  # derive basic schema using csvwr::derive_table_schema()
  schema <- derive_table_schema(data)
  
  # add Corpus Data Model
  
  schema$title <- title
  schema$subject <- subject
  schema$description <- object_description
  schema$creator <- creator
  schema$columns[["description"]] <- column_description
  schema$date <- date
  schema$temporal <- temporal
  schema$type <- "Dataset"
  schema$format <- "text/csv"
  schema$source <- source
  schema$language <- "de"
  schema$rights <- rights
  schema$license <- license
  schema$modified <- Sys.time()
  schema$bibliographicCitation <- paste0(
    "Twente, Moritz: ", title, ". Modelling Marti: Die Geschichte der Schweizer Raumplanung entlang der publizistischen Arbeit von Hans Marti, <https://github.com/mtwente/modelling-marti>, letzte Aktualisierung: ", format(Sys.Date(), format = "%d.%m.%Y"), "."
  )
  
  # write JSON
  list(url = "marti_corpus.csv",
       tableSchema = schema) %>%
    create_metadata() %>%
    toJSON() %>%
    prettify() %>%
    write(here("build", "marti_corpus.csv-metadata.json"))

  return(metadata)
}