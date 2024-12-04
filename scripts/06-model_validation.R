#### Preamble ####
# Purpose:
#   - Evaluate model performance using Mean Squared Error (MSE) for each league.
#   - Quantify prediction accuracy and analyze differences in MSE across leagues.
# Author: John Zhang
# Date: 25 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT License
# Pre-requisites:
#   - Cleaned datasets in Parquet format must be available under `data/02-analysis_data/`.
#   - Necessary libraries installed: `tidyverse`, `arrow`, `broom`, `caret`.
# Output:
#   - MSE values for each league printed and saved to a CSV file.
#   - Diagnostics for model evaluation saved in a structured format.

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(caret)

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

#### Model Validation ####
# Initialize an empty list to store MSE results
mse_results <- list()

for (league in names(parquet_files)) {
  # Load the data
  data <- load_data(parquet_files[[league]])

  # Ensure categorical variables are correctly formatted
  data <- data %>%
    mutate(position = as.factor(position)) # Ensure position is treated as categorical

  # Split the data into training and testing sets (80-20 split)
  set.seed(123)
  train_indices <- createDataPartition(data$market_value, p = 0.8, list = FALSE)
  train_data <- data[train_indices, ]
  test_data <- data[-train_indices, ]

  # Train the linear regression model on the training set
  model <- lm(
    market_value / 1e6 ~ age + goals + assists + club_ranking +
      national_team_ranking + minutes_played + position,
    data = train_data
  )

  # Generate predictions on the test set
  predictions <- predict(model, newdata = test_data)

  # Compute Mean Squared Error (MSE)
  mse <- mean((test_data$market_value / 1e6 - predictions)^2)

  # Store the MSE result
  mse_results[[league]] <- mse
}

#### Save Results ####
# Convert MSE results to a data frame
mse_df <- tibble(
  League = names(mse_results),
  MSE = unlist(mse_results)
)

# Print MSE results
print(mse_df)

# Save the MSE results to a CSV file
write_csv(mse_df, "models/mse_results.csv")
