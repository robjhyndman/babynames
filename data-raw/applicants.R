# Number of applicants -------------------------

library(dplyr, warn.conflicts = FALSE)
library(rvest)
library(tidyr)
library(readr)
library(usethis)

page <- read_html("https://www.ssa.gov/oact/babynames/numberUSbirths.html")

ssa <- page |>
  html_nodes("table") |>
  html_table() |>
  _[[1]] |>
  tibble::as_tibble()
names(ssa) <- c("year", "M", "F", "total")
ssa$total <- NULL

ssa$M <- parse_number(ssa$M)
ssa$F <- parse_number(ssa$F)

applicants <- ssa |>
  gather(sex, n_all, M:F) |>
  arrange(year, sex) |>
  mutate(n_all = as.integer(n_all)) |>
  arrange(year, sex)

write_csv(applicants, "data-raw/applicants.csv")
usethis::use_data(applicants, overwrite = TRUE)
