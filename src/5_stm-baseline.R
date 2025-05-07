library(here)
library(readr)
library(stm)
library(ggplot2)
library(igraph)
library(visNetwork)
library(RColorBrewer)

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

K <- c(5, 10, 15, 20, 30)
kresult <- searchK(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                   K,
                   data = stm_marti_prepped$meta,
                   max.em.its = 150, 
                   init.type = "Spectral")

plot(kresult)

# Baseline Model

k <- 9

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

baseline_labels <- labelTopics(stmFit_baseline, 1:k)

output <- ""

for (topic_num in 1:k) {
  prob_words <- baseline_labels[["prob"]][topic_num, ]
  frex_words <- baseline_labels[["frex"]][topic_num, ]
  
  topic_text <- sprintf(
    "Top Features für Thema %d\nPROB:  %s\nFREX:  %s\n\n",
    topic_num,
    paste(prob_words, collapse = ", "),
    paste(frex_words, collapse = ", ")
  )
  
  output <- paste0(output, topic_text)
}

# Print all at once
cat(output)


## Plot Baseline Topic Labels

#par(mfrow = c(k, 2), mar = c(1, 1, 2, 1))
#for (i in 1:k) {
#  plot(stmFit_baseline, type = "labels", n = 20, topics = i, main = "Label nach Wahrscheinlichkeiten", 
#       width = 40)
#  plot(stmFit_baseline, type = "labels", n = 20, topics = i, main = "Gewichtete Label (FREX)", labeltype = "frex", 
#       width = 50)
#}

baseline_labels <- labelTopics(stmFit_baseline, 1:k)
# Visualize Correlation

threshold <- 0.17 # für k=9

cormat <- cor(stmFit_baseline$theta)
adjmat <- ifelse(abs(cormat) > threshold, 1, 0)

links2 <- as.matrix(adjmat)
net2 <- graph_from_adjacency_matrix(links2, mode = "undirected")
net2 <- igraph::simplify(net2, remove.multiple = FALSE, remove.loops = TRUE)

data <- toVisNetworkData(net2)

nodes <- data[[1]]
edges <- data[[2]]

## Community Detection
clp <- cluster_label_prop(net2)
nodes$community <- clp$membership
qual_col_pals = brewer.pal.info[brewer.pal.info$category == "qual", ]
col_vector = unlist(mapply(brewer.pal,
                           qual_col_pals$maxcolors,
                           rownames(qual_col_pals)))

col_vector <- c(col_vector, col_vector)

col <- col_vector[nodes$community + 1]

links <- igraph::as_data_frame(net2, what = "edges")
nodes <- igraph::as_data_frame(net2, what = "vertices")

TopicProportions <- colMeans(stmFit_baseline$theta)

## visNetwork Settings
nodes$shadow <- TRUE
nodes$label <- paste0("Topic ", 1:k)
nodes$size <- (TopicProportions/max(TopicProportions)) * 40 
nodes$borderWidth <- 2

nodes$color.background <- col
nodes$color.border <- "#000"
nodes$color.highlight.border <- "darkred"
nodes$id <- 1:nrow(nodes)

visNetwork(nodes, links, width = "100%") %>%
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visLayout(randomSeed = 123)