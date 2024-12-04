#### Preamble ####
# Purpose:
#   - This script tests the structure and validity of simulated soccer player datasets for five countries (England, France, Germany, Italy, Spain).
#   - Ensures that the datasets adhere to predefined rules and meet the structural and content requirements for subsequent analysis.
# Author: John Zhang
# Date: 25 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT License
# Pre-requisites:
#   - The `tidyverse`, `testthat`, and `validate` packages must be installed and loaded.
#     Install them using: install.packages(c("tidyverse", "testthat", "validate")).
#   - The script `00-simulate_data.R` must have been successfully run to generate simulated datasets.
# Output:
#   - Validates simulated datasets located in `data/00-simulated_data/`.
#   - Logs test results, highlighting any structural or content issues in the datasets.
# Notes:
#   - Each dataset is subjected to basic, advanced, and country-specific validation tests.
#   - Validates logical constraints such as goals and assists being within reasonable ranges relative to minutes played.
#   - Country-specific club ranking validations are included to ensure consistency with predefined team rankings for each country.

#### Workspace setup ####
library(tidyverse)
library(testthat)
library(validate)

# Paths to the simulated CSV files
csv_files <- c(
  "../data/00-simulated_data/simulated_england_data.csv",
  "../data/00-simulated_data/simulated_france_data.csv",
  "../data/00-simulated_data/simulated_germany_data.csv",
  "../data/00-simulated_data/simulated_italy_data.csv",
  "../data/00-simulated_data/simulated_spain_data.csv"
)

# Country-specific valid team rankings
country_teams <- list(
  England = c(
    "4", "38", "96", "98", "91", "316", "21", "40", "77", "72", "7",
    "409", "1", "36", "25", "141", "838", "39", "86", "137"
  ),
  France = c(
    "70", "479", "414", "75", "46", "400", "66", "71", "568", "37",
    "148", "482", "83", "11", "179", "97", "237", "164"
  ),
  Germany = c(
    "180", "12", "264", "750", "8", "65", "118", "155", "117", "93",
    "250", "5", "74", "10", "14", "184", "101", "170"
  ),
  Italy = c(
    "6", "24", "238", "169", "52", "325", "90", "188", "3", "22", "29",
    "231", "23", "149", "58", "31", "681", "397", "50", "136"
  ),
  Spain = c(
    "124", "363", "27", "16", "9", "57", "249", "115", "192", "18",
    "464", "312", "130", "126", "200", "2", "42", "111", "121", "33"
  )
)

# Helper function to load CSV files
load_data <- function(file) {
  read_csv(file)
}

#### Test data ####
for (file in csv_files) {
  data <- load_data(file)

  # Identify country from file path
  country <- str_extract(file, "england|france|germany|italy|spain") %>%
    str_to_title()
  valid_teams <- country_teams[[country]]

  context(paste("Testing simulated file for", country))

  ### Basic Tests ###
  test_that("dataset is not empty", {
    expect_true(nrow(data) > 0)
    expect_true(ncol(data) > 0)
  })

  test_that("dataset contains all expected columns", {
    expected_columns <- c(
      "Name", "market_value", "age", "national_team_ranking",
      "club_ranking", "minutes_played", "goals", "assists", "position"
    )
    expect_true(all(expected_columns %in% colnames(data)))
  })

  test_that("no missing values in dataset", {
    expect_true(all(!is.na(data)))
  })

  ### Advanced Tests ###
  rules <- validator(
    unique_names = length(unique(data$Name)) == nrow(data),
    valid_market_value = is.numeric(data$market_value) && all(data$market_value > 0),
    realistic_age = is.numeric(data$age) && all(data$age >= 15 & data$age <= 50),
    valid_national_team_ranking = is.numeric(data$national_team_ranking) &&
      all(data$national_team_ranking >= 1 & data$national_team_ranking <= 210),
    valid_club_ranking = is.numeric(data$club_ranking) &&
      all(data$club_ranking > 0 & data$club_ranking <= 1000),
    valid_minutes_played = is.numeric(data$minutes_played) &&
      all(data$minutes_played >= 0),
    valid_goals = is.numeric(data$goals) && all(data$goals >= 0),
    valid_assists = is.numeric(data$assists) && all(data$assists >= 0),
    valid_positions = all(data$position %in% c("MFDF", "FWDF", "FWMF", "DF", "MF", "FW"))
  )

  test_that("Advanced dataset validation", {
    results <- confront(data, rules)
    summary_results <- summary(results)
    expect_true(all(summary_results$passes == summary_results$total)) # All validations must pass
  })

  ### Edge-Case Tests ###
  test_that("third quartile is greater than first quartile for market_value", {
    q1 <- quantile(data$market_value, 0.25)
    q3 <- quantile(data$market_value, 0.75)
    expect_true(q3 > q1)
  })

  test_that("age column follows a realistic distribution", {
    expect_true(mean(data$age) > 20 & mean(data$age) < 35)
    expect_true(median(data$age) > 20 & median(data$age) < 35)
  })

  test_that("goals-to-minutes ratio is reasonable", {
    ratio <- data$goals / (data$minutes_played + 1) # Avoid division by zero
    expect_true(all(ratio < 1))
  })

  test_that("assists-to-minutes ratio is reasonable", {
    ratio <- data$assists / (data$minutes_played + 1) # Avoid division by zero
    expect_true(all(ratio < 1))
  })

  test_that("goal contribution is realistic", {
    total_contribution <- data$goals + data$assists
    expect_true(all(total_contribution <= data$minutes_played))
  })

  test_that("no empty strings in categorical columns", {
    categorical_columns <- c("Name", "position")
    expect_false(any(data[categorical_columns] == ""))
  })

  ### Country-Specific Validation ###
  test_that("club_ranking contains only valid rankings for the country", {
    expect_true(all(data$club_ranking %in% valid_teams))
  })
}
