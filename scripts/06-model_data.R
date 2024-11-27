#### Preamble ####
# Purpose: Models... [...UPDATE THIS...]
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

#### Modeling function ####
# Function to build and summarize linear regression models
build_model <- function(data, league_name) {
  # Build the linear regression model
  model <- lm(
    market_value ~ age + goals + assists + club_ranking + 
      national_team_ranking + minutes_played + position,
    data = data
  )
  
  # Tidy the model summary
  model_summary <- tidy(model) %>%
    mutate(League = league_name)  # Add league information for later comparison
  
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
      position = as.factor(position)  # Ensure position is treated as categorical
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

# Optional: Analyze key findings, such as comparing coefficients across leagues
