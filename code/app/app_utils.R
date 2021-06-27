library(tidyverse)

#load preprocessed data
connection = url("https://www.dropbox.com/s/v687btnftb7xb80/preprocessed.rda?raw=1")
print(load(connection))
close(connection)

#define clinical data lists
age_list <- c(
  "Adult", 
  "Pediatric"
)

location_list <- c(
  "BHC",
  "BJH",
  "BSP",
  "CH",
  "MBC",
  "PWH",
  "SLCH"
)

setting_list <- c(
  "ED", 
  "Inpatient", 
  "Outpatient"
)

#define pathogen lists
bacteria_list <- c(
  "B. pertussis",
  "B. parapertussis",
  "C. pneumoniae",
  "M. pneumoniae"
)

pathogen_list <- list(
  "Respiratory" = c(
    "Adenovirus",
    "Coronavirus 229E",
    "Coronavirus HKU1",
    "Coronavirus NL63",
    "Coronavirus OC43",
    "COVID-19",
    "Human Metapneumovirus",
    "Influenza A",
    "Influenza A (2009)",
    "Influenza A H1",
    "Influenza A H3",
    "Influenza B",
    "Parainfluenza 1",
    "Parainfluenza 2",
    "Parainfluenza 3",
    "Parainfluenza 4",
    "Rhinovirus/Enterovirus",
    "RSV",
    "B. pertussis",
    "B. parapertussis",
    "C. pneumoniae",
    "M. pneumoniae"
  ),
  "GI" = c(
    "Norovirus",
    "Rotavirus"
  ),
  "CNS" = c(
    "Enterovirus",
    "Parechovirus"
  ),
  "Other" = c("Ehrlichia / Anaplasma")
)

#define time periods
month_list <- 
  unique(
    lubridate::floor_date(
      seq(
        lubridate::floor_date(as.Date("2016-01-01"), unit = "week"),
        lubridate::floor_date(as.Date("2021-04-11"), unit = "week"),
        by = "1 week"
      ),
      unit = "month"
    )
  )

date_list <- seq(
  as.Date("2016-01-01"),
  lubridate::ceiling_date(as.Date("2021-04-11"), unit = "halfyear"),
  by = "6 month"
)

week_list <- 
  seq(
    lubridate::floor_date(as.Date("2016-01-01"), unit = "week"),
    lubridate::floor_date(as.Date("2021-04-11"), unit = "week"),
    by = "1 week"
  )

year_list <- 
  unique(
    lubridate::floor_date(
      seq(
        lubridate::floor_date(as.Date("2016-01-01"), unit = "week"),
        lubridate::floor_date(as.Date("2021-04-11"), unit = "week"),
        by = "1 week"
      ),
      unit = "year"
    )
  )

season_list <- 
  if (lubridate::month(lubridate::ceiling_date(as.Date("2021-04-11"), unit = "halfyear")) == 1){
    paste(
      lubridate::year(year_list), 
      lubridate::year(year_list) + 1, 
      sep = "-"
    )
  } else {
    paste(
      head(lubridate::year(year_list), -1),
      head(lubridate::year(year_list), -1) + 1,
      sep = "-"
    )
  }

#set table colors
scale <- colorRampPalette(c("#4285F4", "#FFFFFF", "#DB4437"))(9)
