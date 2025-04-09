# Define the function to generate the URL from the articles' archive ID at e-newspaperarchives.ch

library(tidyverse)

generate_veridian_url <- function(article_id) {
  glue("https://www.e-newspaperarchives.ch/?a=da&command=getSectionText&d={article_id}&srpos=&f=AJAX&e=-------de-20--1--img-txIN--------0-----")
}
