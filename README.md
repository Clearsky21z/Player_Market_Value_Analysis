# Player Market Value Analysis

## Overview

This repository contains the data, scripts, and outputs for the analysis of soccer players' market values in the major European leagues. The analysis investigates the relationship between player attributes, performance metrics, and contextual factors with their estimated market values. It spans five major European leagues—Premier League (England), La Liga (Spain), Serie A (Italy), Bundesliga (Germany), and Ligue 1 (France).

The project forms part of the broader effort to uncover the determinants of market value and provide actionable insights for soccer clubs, agents, and analysts.

## File Structure

The repository is organized as follows:

- **data/**
  - `00-simulated_data/`: Contains simulated datasets for England, France, Germany, Italy, and Spain in CSV format.
  - `01-raw_data/`: Raw data, including:
    - `raw_market_value_data/`: Market value data scraped from Transfermarkt.
    - `raw_performance_data/`: Player performance statistics.
  - `02-analysis_data/`: Cleaned and processed datasets stored in Parquet format for analysis.

- **models/**
  - `player_market_value_models.csv`: Regression model outputs summarizing the relationships between player attributes and market values.
  - `mse_results.csv`: Results of the model validation using Mean Squared Error (MSE).

- **other/**
  - `datasheet/`: Datasheets providing metadata and context for each dataset.
  - `llm_usage/`: Documentation of interactions and assistance provided by language models (LLMs).
  - `sketches/`: Drafts, notes, and exploratory visualizations related to the project.

- **paper/**
  - `paper.qmd`: Source file for the research paper written in Quarto.
  - `references.bib`: Bibliography for the paper.
  - `paper.pdf`: Final version of the research paper.

- **scripts/**
  - `00-simulate_data.R`: Script to generate simulated data for testing.
  - `01-test_simulated_data.R`: Tests on the simulated datasets.
  - `02-scrape_data.py`: Python script to scrape raw market value and performance data.
  - `03-clean_data.R`: Cleans and prepares raw datasets for analysis.
  - `04-test_analysis_data.R`: Validates cleaned datasets.
  - `05-model_data.R`: Builds regression models to analyze market value determinants.
  - `06-model_validation.R`: Validates the models and evaluates their performance.

## Statement on LLM Usage

This project utilized ChatGPT for assistance with various tasks, including:

- Writing and refining code used in data cleaning, analysis, and modeling.
- Generating ideas and brainstorming approaches for the project's methodology.
- Drafting and summarizing sections of the research paper, including the abstract, introduction, and discussions.

All interactions with ChatGPT were focused on improving the clarity, structure, and efficiency of the project while maintaining human oversight and final approval of all outputs.

The full chat history of interactions is documented in `other/llm_usage/`.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
