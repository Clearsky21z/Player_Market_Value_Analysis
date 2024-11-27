#### Preamble ####
# Purpose: Simulates datasets for player data from different countries (England, France, Germany, Italy, Spain) 
#          to test the data cleaning and processing pipeline.
# Author: Your Name
# Date: 25 November 2024
# Contact: your.email@example.com
# License: MIT
# Pre-requisites: The `tidyverse` package must be installed
#                 Ensure simulated datasets match the characteristics of real datasets.

#### Workspace setup ####
library(tidyverse)

# Set a seed for reproducibility
set.seed(12345)

#### Helper Function to Generate Unique Player Names ####
generate_unique_player_names <- function(n, country) {
  name_pool <- list(
    "England" = list(
      first_names = c("James", "John", "William", "George", "Henry", "Edward", "Arthur", 
                      "Michael", "David", "Thomas", "Charles", "Peter", "Andrew", "Richard", 
                      "Harry", "Alfred", "Frederick", "Albert", "Victor", "Joseph", "Samuel", 
                      "Oliver", "Daniel", "Christopher", "Alexander", "Matthew", "Luke", "Jacob"),
      last_names = c("Smith", "Jones", "Taylor", "Brown", "Williams", "Wilson", "Evans", 
                     "Davies", "Roberts", "Walker", "Harris", "Lewis", "Jackson", "Clarke", 
                     "Young", "Green", "Hall", "King", "Wright", "Edwards", "Hughes", "Ward", 
                     "Baker", "Carter", "Phillips", "Turner", "Collins", "Parker", "Campbell")
    ),
    "France" = list(
      first_names = c("Jean", "Pierre", "Michel", "Claude", "Jacques", "Philippe", 
                      "Louis", "Henri", "Émile", "Alain", "Luc", "François", "René", "André", 
                      "Christophe", "Paul", "Olivier", "Marc", "Gérard", "Laurent", "Antoine", 
                      "Julien", "Nicolas", "Sébastien", "Bruno", "Damien", "Pascal", "Thierry"),
      last_names = c("Dubois", "Durand", "Lefebvre", "Moreau", "Laurent", "Simon", 
                     "Michel", "Thomas", "Lemoine", "Martin", "Bernard", "Petit", "Rousseau", 
                     "Blanc", "Fontaine", "Garnier", "Lambert", "Chevalier", "Dufour", 
                     "Perrot", "Renaud", "Chauvin", "Clement", "Guillot", "Marchand", 
                     "Chapel", "Boucher", "Leclerc", "Morin", "Noel")
    ),
    "Germany" = list(
      first_names = c("Hans", "Karl", "Heinrich", "Otto", "Wolfgang", "Jürgen", 
                      "Friedrich", "Stefan", "Klaus", "Werner", "Lothar", "Dirk", 
                      "Matthias", "Andreas", "Peter", "Martin", "Thomas", "Rolf", 
                      "Michael", "Frank", "Manfred", "Uwe", "Helmut", "Sebastian", 
                      "Christian", "Lukas", "Oliver", "Patrick"),
      last_names = c("Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", 
                     "Wagner", "Becker", "Hoffmann", "Schulz", "Koch", "Bauer", "Richter", 
                     "Wolf", "Neumann", "Zimmermann", "Braun", "Krüger", "Hofmann", 
                     "Schröder", "Schwarz", "Krause", "Vogel", "Jung", "Seidel", "Kuhn", 
                     "Voigt", "Dietrich", "Kern", "Lang")
    ),
    "Italy" = list(
      first_names = c("Giuseppe", "Mario", "Luca", "Antonio", "Francesco", "Paolo", 
                      "Giovanni", "Luigi", "Carlo", "Andrea", "Alessandro", "Marco", 
                      "Matteo", "Roberto", "Enrico", "Stefano", "Angelo", "Salvatore", 
                      "Giorgio", "Vincenzo", "Alberto", "Massimo", "Fabio", "Claudio", 
                      "Riccardo", "Emanuele", "Leonardo", "Michele"),
      last_names = c("Rossi", "Russo", "Ferrari", "Esposito", "Bianchi", "Romano", 
                     "Colombo", "Ricci", "Marino", "Greco", "Bruno", "Conti", "De Luca", 
                     "Costa", "Mancini", "Gallo", "Fontana", "Ferri", "Martini", 
                     "Santoro", "Mariani", "Rinaldi", "Longo", "Sartori", "Villa", 
                     "Pellegrini", "Caruso", "Moretti", "Barbieri", "Amato")
    ),
    "Spain" = list(
      first_names = c("José", "Manuel", "Antonio", "Juan", "Francisco", "Carlos", 
                      "Javier", "Pedro", "Luis", "Fernando", "Miguel", "Alejandro", 
                      "Ángel", "Rafael", "Adrián", "Pablo", "Enrique", "Alberto", 
                      "Diego", "Vicente", "Jorge", "Sergio", "Jaime", "David", 
                      "Ismael", "Iván", "Mario", "Rubén"),
      last_names = c("García", "Martínez", "Rodríguez", "Hernández", "López", "González", 
                     "Pérez", "Sánchez", "Ramírez", "Torres", "Díaz", "Vázquez", 
                     "Álvarez", "Moreno", "Romero", "Rubio", "Jiménez", "Ortiz", 
                     "Iglesias", "Gutiérrez", "Castro", "Ramos", "Fernández", 
                     "Domínguez", "Vidal", "Blanco", "Cano", "Prieto", "Reyes", "Delgado")
    )
  )
  
  first_names <- name_pool[[country]]$first_names
  last_names <- name_pool[[country]]$last_names
  
  # Ensure enough combinations to sample
  all_combinations <- expand.grid(first_names, last_names) %>%
    transmute(Name = paste(Var1, Var2))
  
  if (n > nrow(all_combinations)) {
    stop("The pool of unique names is not large enough for the desired sample size.")
  }
  
  unique_names <- sample(all_combinations$Name, size = n, replace = FALSE)
  return(unique_names)
}

#### Simulate Data Function ####
simulate_country_data <- function(country, teams, key_ranking) {
  n <- 500  # Total number of players to simulate
  
  # Generate the data
  data <- tibble(
    Name = generate_unique_player_names(n, country),
    market_value = runif(n, min = 1e5, max = 1e7),  # Market value between €100k and €10m
    age = sample(15:40, n, replace = TRUE),  # Ages between 15 and 40
    national_team_ranking = sample(1:210, n, replace = TRUE, prob = ifelse(1:210 == key_ranking, 0.2, 0.8/209)),  # More players from the key ranking
    club_ranking = sample(teams, n, replace = TRUE),  # Players assigned to country-specific teams
    minutes_played = sample(100:3000, n, replace = TRUE),  # Random minutes between 100 and 3000
    goals = sample(0:30, n, replace = TRUE),  # Random goals between 0 and 30
    assists = sample(0:20, n, replace = TRUE),  # Random assists between 0 and 20
    position = sample(c("MFDF", "FWDF", "FWMF", "DF", "MF", "FW"), n, replace = TRUE)  # Random positions
  )
  
  # Adjust goals and assists to ensure logical constraints
  data <- data %>%
    mutate(
      goals = pmin(goals, minutes_played),  # Goals cannot exceed minutes played
      assists = pmin(assists, minutes_played - goals)  # Assists cannot exceed remaining minutes
    )
  
  return(data)
}

#### Simulate for each country ####
# England
england_teams <- c("4", "38", "96", "98", "91", "316", "21", "40", "77", "72", "7", 
                   "409", "1", "36", "25", "141", "838", "39", "86", "137")
england_data <- simulate_country_data("England", england_teams, key_ranking = 5)

# France
france_teams <- c("70", "479", "414", "75", "46", "400", "66", "71", "568", "37", 
                  "148", "482", "83", "11", "179", "97", "237", "164")
france_data <- simulate_country_data("France", france_teams, key_ranking = 2)

# Germany
germany_teams <- c("180", "12", "264", "750", "8", "65", "118", "155", "117", "93", 
                   "250", "5", "74", "10", "14", "184", "101", "170")
germany_data <- simulate_country_data("Germany", germany_teams, key_ranking = 16)

# Italy
italy_teams <- c("6", "24", "238", "169", "52", "325", "90", "188", "3", "22", "29", 
                 "231", "23", "149", "58", "31", "681", "397", "50", "136")
italy_data <- simulate_country_data("Italy", italy_teams, key_ranking = 10)

# Spain
spain_teams <- c("124", "363", "27", "16", "9", "57", "249", "115", "192", "18", 
                 "464", "312", "130", "126", "200", "2", "42", "111", "121", "33")
spain_data <- simulate_country_data("Spain", spain_teams, key_ranking = 8)

#### Save simulated data ####
# Save each dataset to a CSV file
write_csv(england_data, "data/00-simulated_data/simulated_england_data.csv")
write_csv(france_data, "data/00-simulated_data/simulated_france_data.csv")
write_csv(germany_data, "data/00-simulated_data/simulated_germany_data.csv")
write_csv(italy_data, "data/00-simulated_data/simulated_italy_data.csv")
write_csv(spain_data, "data/00-simulated_data/simulated_spain_data.csv")
