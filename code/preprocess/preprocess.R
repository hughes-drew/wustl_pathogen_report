library(tidyverse)

#aggregate results, add month and week labels
df <- 
  list.files("../../data/raw/", pattern = "results.csv", full = TRUE) %>%
    map(~ read_csv(.)) %>%
    reduce(rbind) %>%
    mutate(
      target = case_when(
        DTA == "Adenovirus DNA" ~ "Adenovirus",
        DTA == "Adenovirus PCR" ~ "Adenovirus",
        DTA == "Bordetella parapertussis DNA" ~ "B. parapertussis",
        DTA == "Bordetella pertussis DNA" ~ "B. pertussis",
        DTA == "Chlamydia pneumoniae DNA" ~ "C. pneumoniae",
        DTA == "COVID-19 Coronavirus RNA" ~ "COVID-19",
        DTA == "Coronavirus 229E RNA" ~ "Coronavirus 229E",
        DTA == "Coronavirus HKU1 RNA" ~ "Coronavirus HKU1",
        DTA == "Coronavirus NL63 RNA" ~ "Coronavirus NL63",
        DTA == "Coronavirus OC43 RNA" ~ "Coronavirus OC43",
        DTA == "Influenza A RNA" ~ "Influenza A",
        DTA == "Influenza A/2009 RNA" ~ "Influenza A (2009)",
        DTA == "Influenza A/H1 RNA" ~ "Influenza A H1",
        DTA == "Influenza A/H3 RNA" ~ "Influenza A H3",
        DTA == "Influenza B RNA" ~ "Influenza B",
        DTA == "Metapneumovirus RNA" ~ "Human Metapneumovirus",
        DTA == "Rhinovirus/Enterovirus RNA" ~ "Rhinovirus/Enterovirus",
        DTA == "RSV RNA" ~ "RSV",
        DTA == "Norovirus GI RNA" ~ "Norovirus",
        DTA == "Enterovirus RNA" ~ "Enterovirus",
        DTA %in% c(
          "Anaplasma phag DNA",
          "Anaplasma phagocytophilum",
          "Ehrlich ewi/can",
          "Ehrlichia Chaf",
          "Ehrlichia muris eauclairensis",
          "Ehrlichia sp DNA"
        ) ~ "Ehrlichia / Anaplasma"
      ),
      result = case_when(
        RESULT %in% c("Positive", "Presumptive Positive", "Detected") ~ "positive",
        RESULT %in% c("Negative", "Presumptive Negative", "Not Detected") ~ "negative",
        TRUE ~ RESULT
      ),
      week = lubridate::floor_date(
        lubridate::parse_date_time(DRAWN, order = "%d %b %y %H:%M:%S"),
        unit = "week"
      ),
      month = lubridate::floor_date(
        lubridate::parse_date_time(DRAWN, order = "%d %b %y %H:%M:%S"),
        unit = "month"
      )
    ) %>%
    rename(
      facility = FACILITY
    ) %>%
    select(
      week,
      month,
      target,
      result,
      facility
    ) %>%
    filter(
      !is.na(target) &
      week != "2021-04-19"
    ) %>%
    as_tibble()

#summarize results by week for each season (July 1 [year] to July 1 [year + 1])
season <- df %>%
  mutate(
    year = lubridate::year(week),
    week_int = case_when(
      lubridate::week(week) > 26 ~ lubridate::week(week) - 26,
      TRUE ~ lubridate::week(week) + 26
    ),
    season = case_when(
      lubridate::month(week) < 7 ~ paste(year - 1, year, sep = "-"),
      TRUE ~ paste(year, year + 1, sep = "-")
    )
  ) %>%
  group_by(target, season, week_int) %>%
  count(result) %>%
  pivot_wider(
    names_from = result,
    values_from = n,
    values_fill = 0
  )

#save tables
save(df, season, file = "~/Dropbox/Public/preprocessed.rda")
