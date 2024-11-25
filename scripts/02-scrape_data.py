#### Preamble ####
# Purpose:
#   - This script scrapes player names and market values from Transfermarkt club squad pages.
#   - It processes multiple club squad URLs, consolidates the scraped data into a structured format, 
#     and saves it as CSV files for further analysis.
# Author: John Zhang
# Date: 25 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT License
# Prerequisites:
#   - Python installed on your system.
#   - Required Python libraries installed: requests, BeautifulSoup4, pandas.
#     Install them using: pip install requests beautifulsoup4 pandas
#   - Stable internet connection to access the Transfermarkt website.
#   - Ensure compliance with Transfermarkt's terms of service when scraping data.
# Output:
#   - The script saves the scraped data into CSV files in the specified folder structure: 
#       data/01-raw_data/raw_market_value_data/raw_<country>_market_value_data.csv
#   - Example file: raw_england_market_value_data.csv
# Note:
#   - Transfermarkt data scraping is subject to its terms of service. Be respectful and avoid overwhelming their servers.
#   - If you encounter CAPTCHA challenges, consider adding delays between requests or utilizing an appropriate scraping proxy.

#### Workspace Setup ####
import requests
from bs4 import BeautifulSoup
import pandas as pd
import os

#### Scrape Data Function ####
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

# Function to scrape multiple URLs and save to a file
def scrape_and_save(urls, output_path):
    all_players = []
    for url in urls:
        print(f"Scraping: {url}")
        all_players.extend(scrape_transfermarkt(url))
    
    # Convert to DataFrame and save to CSV
    df = pd.DataFrame(all_players)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)  # Create directories if they don't exist
    df.to_csv(output_path, index=False)
    print(f"Data saved to {output_path}")

#### Scrape Data ####
# Define URL groups and file paths
england_urls = [
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

germany_urls = [
    "https://www.transfermarkt.com/bayer-04-leverkusen/kader/verein/15/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/vfb-stuttgart/kader/verein/79/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/bayern-munich/kader/verein/27/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/rb-leipzig/kader/verein/23826/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/borussia-dortmund/kader/verein/16/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/eintracht-frankfurt/kader/verein/24/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/tsg-1899-hoffenheim/kader/verein/533/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/1-fc-heidenheim-1846/kader/verein/2036/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/sv-werder-bremen/kader/verein/86/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/sc-freiburg/kader/verein/60/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-augsburg/kader/verein/167/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/vfl-wolfsburg/kader/verein/82/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/1-fsv-mainz-05/kader/verein/39/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/borussia-monchengladbach/kader/verein/18/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/1-fc-union-berlin/kader/verein/89/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/vfl-bochum/kader/verein/80/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/1-fc-koln/kader/verein/3/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/sv-darmstadt-98/kader/verein/105/plus/0/galerie/0?saison_id=2023"
]

italy_urls = [
    "https://www.transfermarkt.com/inter-milan/kader/verein/46/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ac-milan/kader/verein/5/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/juventus-fc/kader/verein/506/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/atalanta-bc/kader/verein/800/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/bologna-fc-1909/kader/verein/1025/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/as-roma/kader/verein/12/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ss-lazio/kader/verein/398/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/acf-fiorentina/kader/verein/430/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/torino-fc/kader/verein/416/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ssc-napoli/kader/verein/6195/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/genoa-cfc/kader/verein/252/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ac-monza/kader/verein/2919/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/hellas-verona/kader/verein/276/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/us-lecce/kader/verein/1005/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/udinese-calcio/kader/verein/410/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/cagliari-calcio/kader/verein/1390/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-empoli/kader/verein/749/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/frosinone-calcio/kader/verein/8970/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/us-sassuolo/kader/verein/6574/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/us-salernitana-1919/kader/verein/380/plus/0/galerie/0?saison_id=2023"
]

spain_urls = [
    "https://www.transfermarkt.com/atletico-de-madrid/kader/verein/13/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-barcelona/kader/verein/131/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/real-madrid/kader/verein/418/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/real-betis-balompie/kader/verein/150/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/sevilla-fc/kader/verein/368/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ca-osasuna/kader/verein/331/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/real-sociedad/kader/verein/681/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/athletic-bilbao/kader/verein/621/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/deportivo-alaves/kader/verein/1108/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/celta-de-vigo/kader/verein/940/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/valencia-cf/kader/verein/1049/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/villarreal-cf/kader/verein/1050/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/getafe-cf/kader/verein/3709/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/rayo-vallecano/kader/verein/367/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/rcd-mallorca/kader/verein/237/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ud-las-palmas/kader/verein/472/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/girona-fc/kader/verein/12321/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ud-almeria/kader/verein/3302/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/granada-cf/kader/verein/16795/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/cadiz-cf/kader/verein/2687/plus/0/galerie/0?saison_id=2023"
]

france_urls = [
    "https://www.transfermarkt.com/paris-saint-germain/kader/verein/583/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/as-monaco/kader/verein/162/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/stade-brestois-29/kader/verein/3911/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/losc-lille/kader/verein/1082/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/ogc-nice/kader/verein/417/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/olympique-lyon/kader/verein/1041/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/rc-lens/kader/verein/826/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/olympique-marseille/kader/verein/244/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/stade-reims/kader/verein/1421/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/stade-rennais-fc/kader/verein/273/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-toulouse/kader/verein/415/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/montpellier-hsc/kader/verein/969/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/rc-strasbourg-alsace/kader/verein/667/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-nantes/kader/verein/995/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/le-havre-ac/kader/verein/738/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/clermont-foot-63/kader/verein/3524/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-metz/kader/verein/347/plus/0/galerie/0?saison_id=2023",
    "https://www.transfermarkt.com/fc-lorient/kader/verein/1158/plus/0/galerie/0?saison_id=2023"
]

# Define file paths
england_path = "data/01-raw_data/raw_market_value_data/raw_england_market_value_data.csv"
germany_path = "data/01-raw_data/raw_market_value_data/raw_germany_market_value_data.csv"
italy_path = "data/01-raw_data/raw_market_value_data/raw_italy_market_value_data.csv"
spain_path = "data/01-raw_data/raw_market_value_data/raw_spain_market_value_data.csv"
france_path = "data/01-raw_data/raw_market_value_data/raw_france_market_value_data.csv"

# Scrape and save data for each group
scrape_and_save(england_urls, england_path)
scrape_and_save(germany_urls, germany_path)
scrape_and_save(italy_urls, italy_path)
scrape_and_save(spain_urls, spain_path)
scrape_and_save(france_urls, france_path)
