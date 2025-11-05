library(here)
library(readr)
library(stm)
library(ggplot2)
library(tidyr)
library(dplyr)


# Read Data and Source Pre-Processing

source(here("src", "3_preprocessing.R"))

## preprocessing script creates a stmdfm_marti object for use in stm

## prepare stm object

stm_marti <- convert(dfm_marti, to = "stm",
                     docvars = docvars(marti_corpus))

stm_marti_prepped <- prepDocuments(stm_marti$documents, stm_marti$vocab,
                                   stm_marti$meta, lower.thresh = 0)

# Compare Numbers of Topics to Identify

K <- c(5, 9, 10, 11, 15, 20, 30)
kresult <- searchK(stm_marti_prepped$documents, stm_marti_prepped$vocab,
                   K,
                   data = stm_marti_prepped$meta,
                   max.em.its = 150, 
                   init.type = "Spectral")

plot(kresult)

# Create dataframe
kresult_df <- as.data.frame(kresult$results) %>%
  mutate(
    K        = as.numeric(unlist(K)),
    heldout  = as.numeric(unlist(heldout)),
    residual = as.numeric(unlist(residual)),
    semcoh   = as.numeric(unlist(semcoh)),
    lbound   = as.numeric(unlist(lbound))
  )

# Find the best K based on maximum semantic coherence
best_k <- kresult_df %>%
  filter(semcoh == max(semcoh, na.rm = TRUE)) %>%
  pull(K)

# Find the y-value of that point for the line endpoint
best_y <- kresult_df %>%
  filter(K == best_k) %>%
  pull(semcoh)

# Prepare for geom_segment at k=9 
k_value <- 9

# Find the y-value of that point for the line endpoint
y_for_k_value <- kresult_df %>%
  filter(K == k_value) %>%
  pull(semcoh)


# Convert to long format for plotting
kresult_long <- kresult_df %>%
  pivot_longer(
    cols = c(heldout, residual, semcoh, lbound),
    names_to = "metric",
    values_to = "value"
  )

# Plot
ggplot(kresult_long, aes(x = K, y = value)) +
  
  # red line only for semantic coherence facet, from 0 to actual max point
  geom_segment(
    data = subset(kresult_long, metric == "semcoh"),
    aes(x = k_value, xend = k_value, y = min(value), yend = y_for_k_value),
    color = "#B2182B", linetype = "dashed", linewidth = 0.5
  ) +
  
  geom_line(linewidth = 1, color = "#1965b0") +
  geom_point(color = "#1965b0", size = 2) +
  
  facet_wrap(
    ~ metric,
    scales = "free_y",
    ncol = 2,
    labeller = as_labeller(c(
      heldout  = "Held-out Likelihood",
      residual = "Residuals",
      semcoh   = "Semantic Coherence",
      lbound   = "Lower Bound"
    ))
  ) +
  scale_x_continuous(
    breaks = c(5, 9, 10, 15, 20, 30),
  ) +
  labs(
    x = "Number of Topics (K)",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )