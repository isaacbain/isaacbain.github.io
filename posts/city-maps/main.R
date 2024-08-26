library(rcityviews)
library(sf)
library(dplyr)

# read cities
cities <- st_read("posts/city-maps/cities.shp") |>
  mutate(
    Longitude = st_coordinates(geometry)[, 1],
    Latitude = st_coordinates(geometry)[, 2]
  ) |> 
  st_drop_geometry() |>
  dplyr::arrange(desc(Population))

city <- new_city(name = "Hokitika", country = "New Zealand", lat = -42.717507, long = 170.973959)

p <- cityview(name = city, license = FALSE, border = "circle", theme = myTheme)

ggplot2::ggsave(filename = "posts/city-maps/output/Hokitika.jpg",
                plot = p,
                height = 500,
                width = 500,
                units = "mm",
                dpi = 300)

myTheme <- list(
  colors = list(
    background = "#ffffff",
    water = "#9ddffb",
    landuse = c("#f2f4cb", "#d0f1bf", "#64b96a"),
    contours = "#eeefc9",
    streets = "#2f3737",
    rails = c("#2f3737", "#eeefc9"),
    buildings = c("#8e76a4", "#a193b1", "#db9b33", "#e8c51e", "#ed6c2e"),
    text = "#2f3737",
    waterlines = "#9ddffb"
  ),
  font = list(
    "family" = "Imbue",
    "face" = "plain",
    "scale" = 3,
    append = "\u2014"
  ),
  size = list(
    borders = list(
      contours = 0.15,
      water = 0.4,
      canal = 0.5,
      river = 0.6
    ),
    streets = list(
      path = 0.2,
      residential = 0.3,
      structure = 0.35,
      tertiary = 0.4,
      secondary = 0.5,
      primary = 0.6,
      motorway = 0.8,
      rails = 0.65,
      runway = 3
    )
  )
)

# Loop through each city in the data frame
for (i in 111:nrow(cities)) {
  
  # Extract city details
  city_name <- cities$Urban.Area[i]
  city_lat <- cities$Latitude[i]
  city_long <- cities$Longitude[i]
  
  # Create a new city object
  city <- new_city(name = city_name, country = "New Zealand", lat = city_lat, long = city_long)
  
  # Generate a filename for the output
  output_filename <- paste0("posts/city-maps/output/", city_name, ".jpg")
  
  # Produce the cityview
  p <- cityview(name = city, license = FALSE, border = "circle", 
                theme = myTheme) # replace myTheme with "vintage" or another
  
  ggplot2::ggsave(filename = output_filename,
                  plot = p,
                  height = 500,
                  width = 500,
                  units = "mm",
                  dpi = 300)
}
