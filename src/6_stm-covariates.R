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

stm_marti <- convert(dfm_marti, to = "stm",
                     docvars = docvars(marti_corpus))

stm_marti_prepped <- prepDocuments(stm_marti$documents, stm_marti$vocab,
                                   stm_marti$meta, lower.thresh = 0)

# Identify Number of Topics to Compare
## this is now part of a separate script to increase computational speed

# Fit Model with Covariates

k <- 9

stmFit_cov <- stm(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                      K = k,
                      prevalence = ~publication + pol_mandat + fachpublikum,
                      max.em.its = 150,
                      data = stm_marti_prepped$meta,
                      init.type = "Spectral", seed = 300)

plot(stmFit_cov, type = "summary",
     xlim = c(0, 0.7), ylim = c(0, 10.4), n = 5,
     main = "Modell mit Covariates (publication + pol_mandat + fachpublikum)",
     width = 10, text.cex = 1)

# Label Topics

topicNames_cov <- labelTopics(stmFit_cov)
topic_cov <- data.frame(topicnames = paste0("Topic ", 1:k),
                    TopicNumber = 1:k,
                    TopicProportions = colMeans(stmFit_cov$theta))

cov_labels <- labelTopics(stmFit_cov, 1:k)

topic <- data.frame(topicnames = paste0("Topic ", 1:k),
                    TopicNumber = 1:k,
                    TopicProportions = colMeans(stmFit_cov$theta))

cov_labels <- labelTopics(stmFit_cov, 1:k)

## Compare Labels

output_cov <- ""

for (topic_num in 1:k) {
  prob_words <- cov_labels[["prob"]][topic_num, ]
  frex_words <- cov_labels[["frex"]][topic_num, ]
  
  topic_text <- sprintf(
    "Top Features für Thema %d\nPROB:  %s\nFREX:  %s\n\n",
    topic_num,
    paste(prob_words, collapse = ", "),
    paste(frex_words, collapse = ", ")
  )
  
  output_cov <- paste0(output_cov, topic_text)
}

# Print all at once
cat(output_cov)

# Assess Topic Quality

topicQuality(stmFit_cov, documents = stm_marti_prepped$documents,
             xlab = "semantische Kohärenz",
             ylab = "Exklusivität")

# Visualize Correlation

threshold <- -0.18
# alle Korrelationen sind negativ offenbar, daher abs() aus dem if clause entfernt

cormat_cov <- cor(stmFit_cov$theta)
adjmat_cov <- ifelse(cormat_cov < threshold, 1, 0)

links2_cov <- as.matrix(adjmat_cov)
net2_cov <- graph_from_adjacency_matrix(links2_cov, mode = "undirected")
net2_cov <- igraph::simplify(net2_cov, remove.multiple = FALSE, remove.loops = TRUE)

data_cov <- toVisNetworkData(net2_cov)

nodes_cov <- data_cov[[1]]
edges_cov <- data_cov[[2]]

## Community Detection
clp_cov <- cluster_label_prop(net2_cov)
nodes_cov$community <- clp_cov$membership
qual_col_pals = brewer.pal.info[brewer.pal.info$category == "qual", ]
col_vector = unlist(mapply(brewer.pal,
                           qual_col_pals$maxcolors,
                           rownames(qual_col_pals)))

col_vector <- c(col_vector, col_vector)

col_cov <- col_vector[nodes_cov$community + 1]

links_cov <- igraph::as_data_frame(net2_cov, what = "edges")
nodes_cov <- igraph::as_data_frame(net2_cov, what = "vertices")

TopicProportions_cov <- colMeans(stmFit_cov$theta)

## visNetwork Settings
nodes_cov$shadow <- TRUE
nodes_cov$label <- paste0("Topic ", 1:k)
nodes_cov$size <- (TopicProportions_cov/max(TopicProportions_cov)) * 40 
nodes_cov$borderWidth <- 2

nodes_cov$color.background <- col_cov
nodes_cov$color.border <- "#000"
nodes_cov$color.highlight.border <- "darkred"
nodes_cov$id <- 1:nrow(nodes_cov)

visNetwork(nodes_cov, links_cov, width = "100%") %>%
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visLayout(randomSeed = 123) %>%
  visInteraction(dragNodes = FALSE, 
                 dragView = FALSE, 
                 zoomView = FALSE)