library(tidyverse)
library(readxl)
library(usethis)

# 1909 - 2001
# Source: https://www2.census.gov/library/publications/2004/compendia/statab/123ed/hist/02HS0013.xls
if (!file.exists("data-raw/02HS0013.xls")) {
  download.file(
    "https://www2.census.gov/library/publications/2004/compendia/statab/123ed/hist/02HS0013.xls",
    "data-raw/02HS0013.xls"
  )
}

raw <- readxl::read_excel(
  'data-raw/02HS0013.xls',
  range = "A16:B117",
  col_names = FALSE,
  na = "(NA)"
)
births <- raw |>
  transmute(
    year = parse_integer(`...1`),
    births = `...2` * 1e3
  ) |>
  filter(!is.na(births))


# Alternative source: 1959-2022 available from humanfertility.org
# Before 1959, these data exclude Alaska and Hawaii, so previous source used.
# From 1959, the two data sets match closely
# Data: https://www.humanfertility.org/File/GetDocument/Files/USA/20250130/USAtotbirthsRR.txt
# Documentation: https://www.humanfertility.org/File/GetDocumentFree/Docs/USA/USAcom.pdf
# (Free account needed for download)

births2 <- readr::read_table("data-raw/USAtotbirthsRR.txt", skip = 2) |>
  select(year = Year, births = Total)

births <- bind_rows(
  births |> filter(year <= 1958),
  births2 |> filter(year >= 1959)
) |>
  mutate(
    year = as.integer(year),
    births = as.integer(births)
  )

write_csv(births, "data-raw/births.csv")
usethis::use_data(births, overwrite = TRUE, compress = 'xz')
