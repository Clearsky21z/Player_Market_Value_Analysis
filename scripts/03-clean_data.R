#### Preamble ####
# Purpose: Cleans the raw player data recorded by two observers, merges, and removes rows with missing values.
# Author: Rohan Alexander [...UPDATE THIS...]
# Date: 6 April 2023 [...UPDATE THIS...]
# Contact: rohan.alexander@utoronto.ca [...UPDATE THIS...]
# License: MIT
# Pre-requisites: 
# - Files `raw_player_market_value_data.csv` and `raw_player_performance_data.csv` should be in the specified directory.
# - Necessary libraries installed: tidyverse, dplyr.
# Any other information needed? Ensure the data columns are correctly formatted.

#### Workspace setup ####
library(tidyverse)
library(dplyr)

#### Clean data ####
# Read the datasets
market_value_data <- read.csv("data/01-raw_data/raw_player_market_value_data.csv")
performance_data <- read.csv("data/01-raw_data/raw_player_performance_data.csv")

# Rename the player name column in performance data for merging
performance_data <- performance_data %>% rename(Name = Player)

# Drop unnecessary columns
performance_data <- performance_data %>% 
  select(-Season, -Comp)

# Merge the datasets on "Name"
combined_data <- market_value_data %>%
  inner_join(performance_data, by = "Name")

# Remove rows with any NA values
cleaned_data <- combined_data %>% 
  drop_na()

# View the cleaned data
print(head(cleaned_data))

#### Save data ####
# Save the cleaned dataset to a CSV file
write.csv(cleaned_data, "data/02-analysis_data/cleaned_player_data.csv", row.names = FALSE)

