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

# compare number of topics to identify

K <- c(5, 9, 10, 11, 15, 20, 30)
kresult <- searchK(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                   K,
                   data = stm_marti_prepped$meta,
                   max.em.its = 150, 
                   init.type = "Spectral")

plot(kresult)


# Fit Model with Covariates

k <- 10

stmFit_cov <- stm(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                      K = k,
                      prevalence = ~publication + pol_mandat,
                      max.em.its = 150,
                      data = stm_marti_prepped$meta,
                      init.type = "Spectral", seed = 300)

plot(stmFit_cov, type = "summary",
     xlim = c(0, 0.7), ylim = c(0, 10.4), n = 5,
     main = "Modell mit Covariates (publication + pol_mandat)",
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

topicQuality(stmFit_cov, documents = stm_marti_prepped$documents)


# Visualize Correlation

threshold <- 0.14
# 0.12 bis 0.14 scheint Sinn zu ergeben

cormat <- cor(stmFit_cov$theta)
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

TopicProportions <- colMeans(stmFit_cov$theta)

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

# COVARIATES

## publication

prep <- estimateEffect(1:k ~ publication, stmFit_cov, gadarian)
summary(prep)
plot(prep, "treatment", model=gadarianFit, method="pointestimate")


Result <- plot(prep, "publication", method = "difference",
               cov.value1 = "NZZ",
               cov.value2 = "Schweizerische Bauzeitung", 
               verbose.labels = F, model = stmFit_cov, labeltype = "custom", custom.labels = topic$topicnames, 
               ylab = "Exp Topic Difference", xlab = "NZZ                        Not Significant                       SBZ", 
               main = "Effect of Publication on Topic Prevelance", xlim = c(-0.5, 0.5), width = 40, 
               ci.level = 0.95)
