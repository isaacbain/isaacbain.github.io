library(tidyverse)
library(sf)
library(mapgl)
library(koordinatr)
library(zoo)
library(gganimate)
library(scales)
library(isaacr)
library(pals)
library(magick)
library(billboarder)

options(scipen = 999)

livestock_numbers_raw <- get_table_as_tibble(Sys.getenv("mfe_api_key"), "mfe", "105406") |> select(-gml_id)

get_stock_unit_constant <- function(animal, year, stock_units = stock_units) {
  
  stock_units <- tibble(
    year = c(1980, 1985, 2000, 2017),
    `Sheep` = c(0.95, 0.95, 0.95, 0.95),
    `Beef cattle` = c(5, 5, 5, 5),
    `Dairy cattle` = c(5, 5, 5, 5),
    `Deer` = c(1.6, 1.6, 1.6, 1.6)
  )
  
  year_diff <- abs(stock_units$year - year)
  nearest_year <- stock_units$year[which.min(year_diff)]
  multiplier <- stock_units |>
    dplyr::filter(year == nearest_year) |>
    dplyr::select(all_of(animal)) |>
    dplyr::pull()
  return(multiplier)
}

# Apply the function to the dataset
total_stock_units <- livestock_numbers_raw |> 
  filter(geography_name == "New Zealand") |>
  filter(animal != "Total cattle") |> 
  group_by(animal) |> 
  mutate(count = na.spline(count, na.rm = FALSE)) |> # Interpolate missing values via cubic spline interpolation
  ungroup() |> 
  rowwise() |>
  mutate(stock_unit_equivalent = count * get_stock_unit_constant(animal, year)) |>
  ungroup() |> 
  group_by(year) |> 
  summarise(total_stock_unit_equivalent = sum(stock_unit_equivalent, na.rm = TRUE))

# Create the plot
ggplot(total_stock_units, aes(x = year, y = total_stock_unit_equivalent)) +
  geom_line() +
  #geom_point(size = 2) +
  #geom_text(label = "Total stock units", vjust = -0.5, hjust = 0, size = 4) +
  labs(title = "Total stock unit equivalents for New Zealand",
       subtitle = "Constant stock unit conversion",
       x = "",
       y = "Number of stock units") +
  theme_minimal() +
  expand_limits(x = c(1971, 2019 + 6), y = 0) + # Expand limits on x-axis
  scale_y_continuous(breaks = seq(0, max(total_stock_units$total_stock_unit_equivalent, na.rm = TRUE), by = 5e7),
                     labels = scales::label_number(scale = 1e-6, suffix = "M")) + # Format y-axis labels
  theme(legend.position = "none")
