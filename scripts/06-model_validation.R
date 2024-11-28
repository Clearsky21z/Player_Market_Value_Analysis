#### Preamble ####
# Purpose: [...UPDATE THIS...]
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 11 February 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: [...UPDATE THIS...]
# Any other information needed? [...UPDATE THIS...]

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(broom)

# Paths to the cleaned Parquet files
parquet_files <- list(
  "England" = "data/02-analysis_data/cleaned_england_data.parquet",
  "France" = "data/02-analysis_data/cleaned_france_data.parquet",
  "Germany" = "data/02-analysis_data/cleaned_germany_data.parquet",
  "Italy" = "data/02-analysis_data/cleaned_italy_data.parquet",
  "Spain" = "data/02-analysis_data/cleaned_spain_data.parquet"
)

# Function to read Parquet data
load_data <- function(file) {
  read_parquet(file)
}

#### Model Diagnostics ####
for (league in names(parquet_files)) {
  # Load the data
  data <- load_data(parquet_files[[league]])
  
  # Ensure categorical variables are correctly formatted
  data <- data %>%
    mutate(
      position = as.factor(position)  # Ensure position is treated as categorical
    )
  
  # Train the model for the league
  model <- lm(
    market_value / 1e6 ~ age + goals + assists + club_ranking +
      national_team_ranking + minutes_played + position,
    data = data
  )
  
  # Generate residuals
  residuals <- augment(model, data = data)
  
  # Save Residuals vs Fitted Plot
  ggplot(residuals, aes(.fitted, .resid)) +
    geom_point(alpha = 0.5) +
    geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
    labs(
      title = paste("Residuals vs Fitted for", league),
      x = "Fitted Values",
      y = "Residuals"
    ) +
    theme_minimal() +
    ggsave(
      filename = paste0("models/residuals_vs_fitted_", league, ".png"),
      width = 8, height = 6
    )
  
  # Save QQ Plot
  ggplot(residuals, aes(sample = .resid)) +
    stat_qq() +
    stat_qq_line() +
    labs(
      title = paste("QQ Plot for Residuals in", league),
      x = "Theoretical Quantiles",
      y = "Sample Quantiles"
    ) +
    theme_minimal() +
    ggsave(
      filename = paste0("models/qq_plot_", league, ".png"),
      width = 8, height = 6
    )
  
  # Save Scale-Location Plot
  ggplot(residuals, aes(.fitted, sqrt(abs(.resid)))) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = "loess", color = "red") +
    labs(
      title = paste("Scale-Location Plot for", league),
      x = "Fitted Values",
      y = "Square Root of Standardized Residuals"
    ) +
    theme_minimal() +
    ggsave(
      filename = paste0("models/scale_location_", league, ".png"),
      width = 8, height = 6
    )
}
