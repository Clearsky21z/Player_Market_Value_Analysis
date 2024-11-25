#### Preamble ####
# Purpose:
#   - This script cleans raw player data from two sources (market value and performance data),
#     merges them, removes rows with missing values, and saves the cleaned dataset in Parquet format.
#   - Ensures consistency and structure in data to support downstream analysis.
# Author: John Zhang
# Date: 25 November 2024
# Contact: junhan.zhang@mail.utoronto.ca
# License: MIT License
# Pre-requisites:
#   - Raw data files should be placed in the following structure:
#       data/01-raw_data/raw_market_value_data/raw_<country>_market_value_data.csv
#       data/01-raw_data/raw_performance_data/raw_<country>_performance_data.csv
#   - Necessary libraries installed: tidyverse, dplyr, arrow.
#     Install them using: install.packages(c("tidyverse", "dplyr", "arrow"))
#   - Ensure column names and formats are consistent across raw data files.
# Output:
#   - Cleaned datasets are saved in Parquet format in:
#       data/02-analysis_data/cleaned_<country>_data.parquet
# Notes:
#   - The script assumes that player names are consistent across market value and performance datasets.
#   - Duplicate rows based on player names are removed entirely (rows where the same name appears multiple times).
#   - Ensure the Parquet format is supported by your analysis tools for compatibility.

#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(arrow)

#### Function to Clean and Transform Data ####
# Read and process datasets
clean_data <- function(market_value_file, performance_file, output_file) {
  cleaned_data <- read.csv(market_value_file, stringsAsFactors = FALSE) %>%
  inner_join(
    read.csv(performance_file, stringsAsFactors = FALSE) %>%
      rename(Name = Player) %>%
      select(-Season, -Comp),
    by = "Name"
  ) %>%
  # Filter rows and drop unnecessary columns
  filter_all(all_vars(. != "")) %>%  # Remove rows where any column has an empty string
  filter(Market.Value != "-") %>%    # Remove rows where Market.Value is "-"
  filter(Pos != "GK") %>%            # Remove rows where Pos is GK
  filter(!Team %in% c("2 Team", "2 Teams")) %>%  # Remove rows with Team "2 Team" or "2 Teams"
  select(-Rk) %>%                    # Drop the Rk column
  # Extract only the three-letter ISO code from the Nation column
  mutate(Nation = str_extract(Nation, "\\b[A-Z]{3}\\b")) %>%  # Extract 3 uppercase letters
  drop_na(Nation) %>%                # Remove rows where Nation is NA
  # Replace three-letter codes with full country names
  mutate(Nation = recode(Nation, 
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
  )) %>% 
  # Map country names to rankings
  mutate(Nation = recode(Nation,
                         "Argentina" = "1", "France" = "2", "Belgium" = "3", "Brazil" = "4", "England" = "5",
                         "Portugal" = "6", "Netherlands" = "7", "Spain" = "8", "Croatia" = "9", "Italy" = "10",
                         "United States" = "11", "Morocco" = "12", "Colombia" = "12", "Uruguay" = "14", "Mexico" = "15",
                         "Germany" = "16", "Japan" = "17", "Senegal" = "18", "Switzerland" = "19", "Iran" = "20",
                         "Denmark" = "21", "South Korea" = "22", "Australia" = "23", "Ukraine" = "24", "Austria" = "25",
                         "Poland" = "26", "Hungary" = "27", "Sweden" = "28", "Wales" = "29", "Ecuador" = "30",
                         "Peru" = "31", "Serbia" = "32", "Russia" = "33", "Czech Republic" = "34", "Qatar" = "35",
                         "Egypt" = "36", "Côte d'Ivoire" = "37", "Nigeria" = "38", "Scotland" = "39", "Chile" = "40",
                         "Tunisia" = "41", "Turkiye" = "42", "Panama" = "43", "Algeria" = "44", "Slovakia" = "45",
                         "Norway" = "46", "Romania" = "47", "Canada" = "48", "Cameroon" = "49", "Mali" = "50",
                         "Greece" = "51", "Costa Rica" = "52", "Jamaica" = "53", "Venezuela" = "54", "Iraq" = "55",
                         "Saudi Arabia" = "56", "Slovenia" = "57", "Paraguay" = "58", "South Africa" = "59",
                         "Republic of Ireland" = "60", "DR Congo" = "61", "Uzbekistan" = "62", "Finland" = "63", "Ghana" = "64",
                         "Cape Verde" = "65", "Albania" = "66", "Burkina Faso" = "67", "Jordan" = "68", "UAE" = "69",
                         "Iceland" = "70", "North Macedonia" = "71", "Montenegro" = "72", "Northern Ireland" = "73",
                         "Georgia" = "74", "Bosnia" = "75", "Oman" = "76", "Guinea" = "77", "Honduras" = "78",
                         "Israel" = "79", "El Salvador" = "80", "Bahrain" = "81", "Bulgaria" = "82", "Gabon" = "83",
                         "Bolivia" = "84", "Luxembourg" = "85", "Haiti" = "86", "Curaçao" = "87", "China" = "88",
                         "Equatorial Guinea" = "89", "Zambia" = "90", "Benin" = "91", "Angola" = "92", "Syria" = "93",
                         "Uganda" = "94", "Palestine" = "95", "Armenia" = "96", "Namibia" = "97", "Belarus" = "98",
                         "Trinidad" = "99", "Thailand" = "100", "Kyrgyzstan" = "101", "Tajikistan" = "102",
                         "Mozambique" = "103", "Madagascar" = "104", "Kosovo" = "105", "Guatemala" = "106",
                         "New Zealand" = "107", "Kenya" = "108", "Kazakhstan" = "109", "North Korea" = "110",
                         "Azerbaijan" = "111", "Mauritania" = "112", "Congo" = "113", "Tanzania" = "114",
                         "Guinea-Bissau" = "115", "Vietnam" = "116", "Lebanon" = "117", "Libya" = "118",
                         "Comoros" = "119", "Togo" = "120", "Sudan" = "121", "Sierra Leone" = "122",
                         "Estonia" = "123", "India" = "124", "Malawi" = "125", "Cyprus" = "126",
                         "Central Africa" = "127", "Niger" = "128", "Zimbabwe" = "129", "Nicaragua" = "130",
                         "Rwanda" = "131", "The Gambia" = "132", "Solomon Islands" = "133", "Indonesia" = "134",
                         "Malaysia" = "135", "Lithuania" = "136", "Kuwait" = "137", "Latvia" = "138",
                         "Faroe Islands" = "139", "Burundi" = "140", "Suriname" = "141", "Liberia" = "142",
                         "Ethiopia" = "143", "Turkmenistan" = "144", "Botswana" = "145", "St. Kitts/Nevis" = "146",
                         "Philippines" = "147", "Antigua and Barbuda" = "148", "Lesotho" = "149",
                         "Dominican Republic" = "150", "Afghanistan" = "151", "Moldova" = "152",
                         "Guyana" = "153", "Eswatini" = "154", "Yemen" = "155", "Puerto Rico" = "156",
                         "Hong Kong" = "157", "New Caledonia" = "158", "Singapore" = "159", "Maldives" = "160",
                         "Tahiti" = "161", "Andorra" = "162", "C. Taipei" = "163", "Myanmar" = "164",
                         "Papua N. Guinea" = "165", "Fiji" = "166", "South Sudan" = "167", "Saint Lucia" = "168",
                         "Cuba" = "169", "Vanuatu" = "170", "Bermuda" = "171", "Malta" = "172", "Grenada" = "173",
                         "St. Vincent" = "174", "Nepal" = "175", "Montserrat" = "176", "Barbados" = "177",
                         "Chad" = "178", "Mauritius" = "179", "Cambodia" = "180", "Samoa" = "181",
                         "Dominica" = "182", "Bhutan" = "183", "Belize" = "184", "Bangladesh" = "185",
                         "Macau" = "186", "Cook Islands" = "187", "A. Samoa" = "188", "Laos" = "189",
                         "Mongolia" = "190", "Brunei" = "191", "São Tomé and P." = "192", "Djibouti" = "193",
                         "Aruba" = "194", "Cayman Islands" = "195", "Timor-Leste" = "196", "Pakistan" = "197",
                         "Gibraltar" = "198", "Liechtenstein" = "199", "Tonga" = "200", "Seychelles" = "201",
                         "Somalia" = "202", "Bahamas" = "203", "Guam" = "204", "Sri Lanka" = "205",
                         "Turks-Caicos" = "206", "B. Virgin" = "207", "US Virgin" = "208", "Anguilla" = "209",
                         "San Marino" = "210"
                         )) %>%
  mutate(Team = recode(Team,
                       "Arsenal" = "4", "Aston Villa" = "38", "Bournemouth" = "96", "Brentford" = "98", 
                       "Brighton" = "91", "Burnley" = "316", "Chelsea" = "21", "Crystal Palace" = "40", 
                       "Everton" = "77", "Fulham" = "72", "Liverpool" = "7", "Luton Town" = "409", 
                       "Manchester City" = "1", "Manchester Utd" = "36", "Newcastle Utd" = "25", 
                       "Nott'ham Forest" = "141", "Sheffield Utd" = "838", "Tottenham" = "39", 
                       "West Ham" = "86", "Wolves" = "137", "Alavés" = "124", "Almería" = "363", 
                       "Athletic Club" = "27", "Atlético Madrid" = "16", "Barcelona" = "9", 
                       "Betis" = "57", "Cádiz" = "249", "Celta Vigo" = "115", "Getafe" = "192", 
                       "Girona" = "18", "Granada" = "464", "Las Palmas" = "312", "Mallorca" = "130", 
                       "Osasuna" = "126", "Rayo Vallecano" = "200", "Real Madrid" = "2", 
                       "Real Sociedad" = "42", "Sevilla" = "111", "Valencia" = "121", 
                       "Villarreal" = "33", "Augsburg" = "180", "Bayern Munich" = "12", 
                       "Bochum" = "264", "Darmstadt 98" = "750", "Dortmund" = "8", 
                       "Eint Frankfurt" = "65", "Freiburg" = "118", "Gladbach" = "155", 
                       "Heidenheim" = "117", "Hoffenheim" = "93", "Köln" = "250", 
                       "Leverkusen" = "5", "Mainz 05" = "74", "RB Leipzig" = "10", 
                       "Stuttgart" = "14", "Union Berlin" = "184", "Werder Bremen" = "101", 
                       "Wolfsburg" = "170", "Atalanta" = "6", "Bologna" = "24", "Cagliari" = "238", 
                       "Empoli" = "169", "Fiorentina" = "52", "Frosinone" = "325", 
                       "Genoa" = "90", "Hellas Verona" = "188", "Inter" = "3", 
                       "Juventus" = "22", "Lazio" = "29", "Lecce" = "231", "Milan" = "23", 
                       "Monza" = "149", "Napoli" = "58", "Roma" = "31", "Salernitana" = "681", 
                       "Sassuolo" = "397", "Torino" = "50", "Udinese" = "136", "Brest" = "70", 
                       "Clermont Foot" = "479", "Le Havre" = "414", "Lens" = "75", 
                       "Lille" = "46", "Lorient" = "400", "Lyon" = "66", "Marseille" = "71", 
                       "Metz" = "568", "Monaco" = "37", "Montpellier" = "148", "Nantes" = "482", 
                       "Nice" = "83", "Paris S-G" = "11", "Reims" = "179", "Rennes" = "97", 
                       "Strasbourg" = "237", "Toulouse" = "164"
                       )) %>%
  # Remove specified columns
  select(-c("MP", "X90s", "Starts", "Subs", "unSub", "G.A", "G.PK", "PK", "PKatt", "PKm", "X.9999")) %>%
  mutate(
    Market.Value = gsub("€", "", Market.Value),  # Remove "€" symbol
    Market.Value = case_when(
      grepl("m$", Market.Value) ~ as.numeric(sub("m$", "", Market.Value)) * 1e6,
      grepl("k$", Market.Value) ~ as.numeric(sub("k$", "", Market.Value)) * 1e3,
      TRUE ~ as.numeric(Market.Value)  # Handles already numeric values
    )
  )
  renamed_data <- cleaned_data %>%
    rename(
      market_value = Market.Value,
      age = Age,
      national_team_ranking = Nation,
      club_ranking = Team,
      minutes_played = Min,
      goals = Gls,
      assists = Ast,
      position = Pos
    ) %>%
    mutate(
      national_team_ranking = as.numeric(national_team_ranking),
      age = as.numeric(age),
      club_ranking = as.numeric(club_ranking),
      minutes_played = as.numeric(minutes_played),
      goals = as.numeric(goals),
      assists = as.numeric(assists),
      position = case_when(
        position == "DFMF" ~ "MFDF",
        position == "DFFW" ~ "FWDF",
        position == "MFFW" ~ "FWMF",
        TRUE ~ position  # Keep other positions unchanged
      )
    ) %>%
    drop_na() %>%  # Remove rows with NA values
    group_by(Name) %>%
    filter(n() == 1) %>%  # Keep only rows where Name appears exactly once
    ungroup()
  

#### Save data ####
  # Save the cleaned dataset as a Parquet file
  write_parquet(renamed_data, output_file)
}

#### Clean and Save Datasets for Each Country ####
# England
clean_data("data/01-raw_data/raw_market_value_data/raw_england_market_value_data.csv", 
           "data/01-raw_data/raw_performance_data/raw_england_performance_data.csv",
           "data/02-analysis_data/cleaned_england_data.parquet")

# Germany
clean_data("data/01-raw_data/raw_market_value_data/raw_germany_market_value_data.csv", 
           "data/01-raw_data/raw_performance_data/raw_germany_performance_data.csv",
           "data/02-analysis_data/cleaned_germany_data.parquet")

# Italy
clean_data("data/01-raw_data/raw_market_value_data/raw_italy_market_value_data.csv", 
           "data/01-raw_data/raw_performance_data/raw_italy_performance_data.csv",
           "data/02-analysis_data/cleaned_italy_data.parquet")

# Spain
clean_data("data/01-raw_data/raw_market_value_data/raw_spain_market_value_data.csv", 
           "data/01-raw_data/raw_performance_data/raw_spain_performance_data.csv",
           "data/02-analysis_data/cleaned_spain_data.parquet")

# France
clean_data("data/01-raw_data/raw_market_value_data/raw_france_market_value_data.csv", 
           "data/01-raw_data/raw_performance_data/raw_france_performance_data.csv",
           "data/02-analysis_data/cleaned_france_data.parquet")