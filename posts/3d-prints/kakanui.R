# libraries ---------------------------------------------------------------
library(sf)
library(elevatr)
library(geodata)
library(rayshader)
library(dplyr)
library(mapview)

# pre-processing ----------------------------------------------------------

# import catchment boundary
kakanui <- st_read("/Users/isaacbain/working/estuary-mapping/data/kakanui_combined/kakanui_catchment.shp")

# get elevation data using elevatr package, from global dataset
kakanui_elev <- get_elev_raster(kakanui, # location of interest
                                z = 11, # zoom level (detail)
                                clip = "location", # clip to catchment boundary
                                prj = st_crs(kakanui)$proj4string) # inherit projection from catchment boundary

# convert to matrix
kakanui_mat <- raster_to_matrix(kakanui_elev)

# rayshader ---------------------------------------------------------------

# Create rayshader plot
kakanui_mat |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  add_shadow(ray_shade(kakanui_mat), 0.5) |> # adds shadow
  add_shadow(ambient_shade(kakanui_mat), 0) |>  # adds ambient light (looks nice but very slow)
  plot_3d(kakanui_mat, zscale = 12, zoom = 0.6, theta = 50, phi = 20, windowsize = c(1080, 1080)) # define plot parameters

# Create spinning animation
render_camera(theta = seq(0, 360, length.out = 360), phi = 30, zoom = 0.6) # define camera parameters, spin around y-axis
render_movie("kakanui_spinning.mp4", fps = 24, frames = 360, zoom = 0.6) # create spinning animation
