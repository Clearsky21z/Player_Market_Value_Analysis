#### Preamble ####
# Purpose: Downloads and saves the player name and market value data from Transfermarkt club squad pages.
# Author: John Zhang
# Date: 21 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT
# Pre-requisites:
#   - Python installed on your system.
#   - Required libraries installed: requests, BeautifulSoup4, pandas.
#   - Internet connection to access the Transfermarkt website.
# Any other information needed? Ensure compliance with Transfermarkt's terms of service when scraping data.

#### Workspace Setup ####
import requests
from bs4 import BeautifulSoup
import pandas as pd
import os

#### Scrape Data ####
# List of URLs
urls = [
    "https://www.transfermarkt.com/arsenal-fc/kader/verein/11/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/aston-villa/kader/verein/405/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/afc-bournemouth/kader/verein/989/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/brentford-fc/kader/verein/1148/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/brighton-amp-hove-albion/kader/verein/1237/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/chelsea-fc/kader/verein/631/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/crystal-palace/kader/verein/873/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/everton-fc/kader/verein/29/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fulham-fc/kader/verein/931/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-liverpool/kader/verein/31/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/manchester-city/kader/verein/281/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/manchester-united/kader/verein/985/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/newcastle-united/kader/verein/762/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/nottingham-forest/kader/verein/703/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/tottenham-hotspur/kader/verein/148/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/west-ham-united/kader/verein/379/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/wolverhampton-wanderers/kader/verein/543/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/burnley-fc/kader/verein/1132/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/sheffield-united/kader/verein/350/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/luton-town/kader/verein/1031/plus/0/galerie/0?saison_id=2023"
]

# Function to scrape a single URL
def scrape_transfermarkt(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0 Safari/537.36"
    }
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.content, 'html.parser')

    # Extract player names and market values
    players = []
    table = soup.find('table', {'class': 'items'})
    if table:
        rows = table.find_all('tr', {'class': ['odd', 'even']})  # Rows with player data
        for row in rows:
            name_cell = row.find('td', {'class': 'hauptlink'})
            value_cell = row.find('td', {'class': 'rechts hauptlink'})
            if name_cell and value_cell:
                name = name_cell.text.strip()
                market_value = value_cell.text.strip()
                players.append({"Name": name, "Market Value": market_value})
    return players

# Scrape all URLs and combine data
all_players = []
for url in urls:
    all_players.extend(scrape_transfermarkt(url))
    
#### Save Scraped Data ####
# Convert to DataFrame and save to CSV
df = pd.DataFrame(all_players)

# Define file path
output_path = "data/01-raw_data/raw_player_market_value_data.csv"
os.makedirs(os.path.dirname(output_path), exist_ok=True)  # Create directories if they don't exist
df.to_csv(output_path, index=False)

print(f"Scraping complete. Data saved to {output_path}")
