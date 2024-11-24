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
market_value_data <- read.csv("data/01-raw_data/raw_player_market_value_data.csv", stringsAsFactors = FALSE)
performance_data <- read.csv("data/01-raw_data/raw_player_performance_data.csv", stringsAsFactors = FALSE)

# Rename the player name column in performance data for merging
performance_data <- performance_data %>% rename(Name = Player)

# Drop unnecessary columns
performance_data <- performance_data %>% 
  select(-Season, -Comp)

# Merge the datasets on "Name"
combined_data <- market_value_data %>%
  inner_join(performance_data, by = "Name")

# Remove rows with any empty string or "-" in the Market.Value column
cleaned_data <- combined_data %>% 
  filter_all(all_vars(. != "")) %>%  # Remove rows where any column has an empty string
  filter(Market.Value != "-") %>%   # Remove rows where Market.Value is "-"
  filter(Pos != "GK") %>%           # Remove rows where Pos (Position) is GK
  filter(!Team %in% c("2 Team", "2 Teams")) %>% # Remove rows where Team is "2 Team" or "2 Teams"
  select(-Rk)                       # Drop the Rk column

# Extract only the three-letter ISO code from the Nation column
cleaned_data <- cleaned_data %>%
  mutate(Nation = str_extract(Nation, "\\b[A-Z]{3}\\b")) %>% # Extract 3 uppercase letters
  drop_na(Nation)  # Remove rows where Nation is NA

# Ensure data frame is correctly formatted and free of malformed values
cleaned_data <- as.data.frame(cleaned_data)

country_mapping <- list(
  "AFG" = "Afghanistan", "ALB" = "Albania", "ALG" = "Algeria",
  "ASA" = "American Samoa", "AND" = "Andorra", "ANG" = "Angola",
  "AIA" = "Anguilla", "ARG" = "Argentina", "ARM" = "Armenia",
  "ARU" = "Aruba", "AUS" = "Australia", "AUT" = "Austria",
  "AZE" = "Azerbaijan", "BAH" = "Bahamas", "BHR" = "Bahrain",
  "BAN" = "Bangladesh", "BRB" = "Barbados", "BLR" = "Belarus",
  "BEL" = "Belgium", "BLZ" = "Belize", "BEN" = "Benin",
  "BER" = "Bermuda", "BHU" = "Bhutan", "BOL" = "Bolivia",
  "BIH" = "Bosnia and Herzegovina", "BOT" = "Botswana",
  "BRA" = "Brazil", "VGB" = "British Virgin Islands", "BRU" = "Brunei Darussalam",
  "BUL" = "Bulgaria", "BFA" = "Burkina Faso", "BDI" = "Burundi",
  "CPV" = "Cabo Verde", "CAM" = "Cambodia", "CMR" = "Cameroon",
  "CAN" = "Canada", "CAY" = "Cayman Islands", "CTA" = "Central African Republic",
  "CHA" = "Chad", "CHI" = "Chile", "CHN" = "China",
  "COL" = "Colombia", "COM" = "Comoros", "CGO" = "Congo",
  "COD" = "DR Congo", "COK" = "Cook Islands", "CRC" = "Costa Rica",
  "CIV" = "Côte d'Ivoire", "CRO" = "Croatia", "CUB" = "Cuba",
  "CUW" = "Curaçao", "CYP" = "Cyprus", "CZE" = "Czech Republic",
  "DEN" = "Denmark", "DJI" = "Djibouti", "DMA" = "Dominica",
  "DOM" = "Dominican Republic", "ECU" = "Ecuador", "EGY" = "Egypt",
  "SLV" = "El Salvador", "GNQ" = "Equatorial Guinea", "ERI" = "Eritrea",
  "EST" = "Estonia", "ETH" = "Ethiopia", "FRO" = "Faroe Islands",
  "FIJ" = "Fiji", "FIN" = "Finland", "FRA" = "France",
  "PYF" = "French Polynesia", "GAB" = "Gabon", "GMB" = "Gambia",
  "GEO" = "Georgia", "GER" = "Germany", "GHA" = "Ghana",
  "GIB" = "Gibraltar", "GRE" = "Greece", "GRL" = "Greenland",
  "GRN" = "Grenada", "GUM" = "Guam", "GUA" = "Guatemala",
  "GUI" = "Guinea", "GBS" = "Guinea-Bissau", "GUY" = "Guyana",
  "HAI" = "Haiti", "HON" = "Honduras", "HKG" = "Hong Kong",
  "HUN" = "Hungary", "ISL" = "Iceland", "IND" = "India",
  "IDN" = "Indonesia", "IRN" = "Iran", "IRQ" = "Iraq",
  "IRL" = "Republic of Ireland", "IMN" = "Isle of Man", "ISR" = "Israel",
  "ITA" = "Italy", "JAM" = "Jamaica", "JPN" = "Japan",
  "JOR" = "Jordan", "KAZ" = "Kazakhstan", "KEN" = "Kenya",
  "KIR" = "Kiribati", "PRK" = "North Korea", "KOR" = "South Korea",
  "KOS" = "Kosovo", "KUW" = "Kuwait", "KGZ" = "Kyrgyzstan",
  "LAO" = "Laos", "LAT" = "Latvia", "LBN" = "Lebanon",
  "LES" = "Lesotho", "LBR" = "Liberia", "LBY" = "Libya",
  "LIE" = "Liechtenstein", "LTU" = "Lithuania", "LUX" = "Luxembourg",
  "MAC" = "Macau", "MAD" = "Madagascar", "MWI" = "Malawi",
  "MAS" = "Malaysia", "MDV" = "Maldives", "MLI" = "Mali",
  "MLT" = "Malta", "MHL" = "Marshall Islands", "MTQ" = "Martinique",
  "MTN" = "Mauritania", "MRI" = "Mauritius", "MEX" = "Mexico",
  "FSM" = "Micronesia", "MDA" = "Moldova", "MON" = "Monaco",
  "MNG" = "Mongolia", "MNE" = "Montenegro", "MSR" = "Montserrat",
  "MAR" = "Morocco", "MOZ" = "Mozambique", "MYA" = "Myanmar",
  "NAM" = "Namibia", "NRU" = "Nauru", "NEP" = "Nepal",
  "NED" = "Netherlands", "NCL" = "New Caledonia", "NZL" = "New Zealand",
  "NCA" = "Nicaragua", "NIG" = "Niger", "NGA" = "Nigeria",
  "NIU" = "Niue", "NFK" = "Norfolk Island", "MKD" = "North Macedonia",
  "NOR" = "Norway", "OMA" = "Oman", "PAK" = "Pakistan",
  "PLW" = "Palau", "PLE" = "Palestine", "PAN" = "Panama",
  "PNG" = "Papua New Guinea", "PAR" = "Paraguay", "PER" = "Peru",
  "PHI" = "Philippines", "POL" = "Poland", "POR" = "Portugal",
  "PUR" = "Puerto Rico", "QAT" = "Qatar", "ROU" = "Romania",
  "RUS" = "Russia", "RWA" = "Rwanda", "SKN" = "Saint Kitts and Nevis",
  "LCA" = "Saint Lucia", "VCT" = "Saint Vincent and the Grenadines",
  "SAM" = "Samoa", "SMR" = "San Marino", "STP" = "Sao Tome and Principe",
  "KSA" = "Saudi Arabia", "SEN" = "Senegal", "SRB" = "Serbia",
  "SEY" = "Seychelles", "SLE" = "Sierra Leone", "SGP" = "Singapore",
  "SVK" = "Slovakia", "SVN" = "Slovenia", "SOL" = "Solomon Islands",
  "SOM" = "Somalia", "RSA" = "South Africa", "ESP" = "Spain",
  "SRI" = "Sri Lanka", "SDN" = "Sudan", "SUR" = "Suriname",
  "SWE" = "Sweden", "SUI" = "Switzerland", "SYR" = "Syria",
  "TPE" = "Chinese Taipei", "TJK" = "Tajikistan", "TAN" = "Tanzania",
  "THA" = "Thailand", "TLS" = "Timor-Leste", "TOG" = "Togo",
  "TGA" = "Tonga", "TRI" = "Trinidad and Tobago", "TUN" = "Tunisia",
  "TUR" = "Turkiye", "TKM" = "Turkmenistan", "TCA" = "Turks and Caicos Islands",
  "UGA" = "Uganda", "UKR" = "Ukraine", "UAE" = "United Arab Emirates",
  "USA" = "United States", "URU" = "Uruguay", "UZB" = "Uzbekistan",
  "VAN" = "Vanuatu", "VEN" = "Venezuela", "VIE" = "Vietnam",
  "ISV" = "US Virgin Islands", "WAL" = "Wales", "YEM" = "Yemen",
  "ZAM" = "Zambia", "ZIM" = "Zimbabwe", "ENG" = "England", "SCO" = "Scotland", "NIR" = "Northern Ireland", "GNB" = "Guinea-Bissau"
)

# Replace three-letter codes with full country names
cleaned_data <- cleaned_data %>%
  mutate(Nation = recode(Nation, !!!country_mapping))


#### Save data ####
# Save the cleaned dataset to a CSV file
write.csv(cleaned_data, "data/02-analysis_data/cleaned_player_data.csv", row.names = FALSE)
