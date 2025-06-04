# Explorative Visualizations

library(here)
library(quanteda)
library(quanteda.textplots)
library(RColorBrewer)
library(dendextend)

# Read Data and Source Pre-Processing

source(here("src", "3_preprocessing.R"))

# Wordcloud

textplot_wordcloud(dfm_marti, scale = c(3.5, 0.75), colors = brewer.pal(8, "Dark2"), random.order = F, 
                   rot.per = 0.1, max.words = 100)

# Dendrogram
wordDfm <- dfm_sort(dfm_weight(dfm_marti, "prop"))
wordDfm <- t(wordDfm)[1:50, ]
wordDistMat <- dist(wordDfm)
wordCluster <- hclust(wordDistMat)

dend <- as.dendrogram(wordCluster) %>%
  hang.dendrogram()

## Optional customizations
dend <- set(dend, "labels_cex", 0.5)
dend <- set(dend, "branches_lwd", 1.2)

## Plot with horizontal layout and rotated labels
plot_horiz.dendrogram(dend,
                      side = F)

# Co-Occurrence Network
topterms <- names(topfeatures(dfm_marti, 30))

fcmat_marti_topterms <- fcm(dfm_marti) %>%
  fcm_select(pattern = topterms)

prop_size <- rowSums(fcmat_marti_topterms)/min(rowSums(fcmat_marti_topterms))

set.seed(20)
textplot_network(fcmat_marti_topterms,
                 min_freq = 0.5,
                 edge_alpha = 0.5, 
                 edge_size = 1.3,
                 vertex_labelsize = 0.7*prop_size)