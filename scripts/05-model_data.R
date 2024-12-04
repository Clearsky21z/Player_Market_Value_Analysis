#### Preamble ####
# Purpose:
#   - This script builds and evaluates linear regression models to analyze the determinants of soccer players' market values.
#   - The analysis includes modeling player data from five major European leagues (England, France, Germany, Italy, Spain).
# Author: John Zhang
# Date: 25 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT License
# Pre-requisites:
#   - Cleaned datasets for each league must be available in Parquet format in the directory `data/02-analysis_data/`.
#   - Necessary libraries installed: `tidyverse`, `arrow`, and `broom`.
#     Install them using: install.packages(c("tidyverse", "arrow", "broom")).
# Output:
#   - Linear regression model summaries for each league are saved in `models/player_market_value_models.csv`.
# Notes:
#   - Models account for key predictors such as age, goals, assists, club ranking, national team ranking, minutes played, and position.
#   - The script ensures consistent formatting of variables across datasets for comparability.
#   - Results are aggregated into a single file for streamlined analysis and cross-league comparisons.

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

#### Modeling function ####
# Function to build and summarize linear regression models
build_model <- function(data, league_name) {
  # Scale market value to millions
  data <- data %>%
    mutate(market_value_million = market_value / 1e6)

  # Build the linear regression model
  model <- lm(
    market_value_million ~ age + goals + assists + club_ranking +
      national_team_ranking + minutes_played + position,
    data = data
  )

  # Tidy the model summary
  model_summary <- tidy(model) %>%
    mutate(League = league_name) # Add league information for later comparison

  # Return the summary
  return(model_summary)
}

#### Run models for each league ####
# Initialize an empty list to store results
model_summaries <- list()

for (league in names(parquet_files)) {
  # Load the data
  data <- load_data(parquet_files[[league]])

  # Ensure categorical variables are correctly formatted
  data <- data %>%
    mutate(
      position = as.factor(position) # Ensure position is treated as categorical
    )

  # Build the model and store the summary
  model_summaries[[league]] <- build_model(data, league)
}

#### Combine and Save Results ####
# Combine all summaries into one data frame for easier comparison
combined_summary <- bind_rows(model_summaries)

# Save the summary as a CSV file
write_csv(combined_summary, "models/player_market_value_models.csv")

#### Analysis ####
# View the combined summary
print(combined_summary)

