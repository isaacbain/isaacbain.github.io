library(sf)
library(elevatr)
library(geodata)
library(rayshader)
library(dplyr)
library(mapview)

kakanui <- st_read("/Users/isaacbain/working/estuary-mapping/data/kakanui_combined/kakanui_catchment.shp")

kakanui_elev <- get_elev_raster(kakanui, z = 11, clip = "location", prj = st_crs(kakanui)$proj4string)

# set level of smoothing (must be odd number)
kakanui_elev_smooth = kakanui_elev
#kakanui_elev_smooth <- raster::focal(kakanui_elev, w=matrix(1, 5, 5), mean, na.rm = T)

# convert to matrix
kakanui_mat <- raster_to_matrix(kakanui_elev_smooth)

# Create rayshader plot
kakanui_mat |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |>
  add_shadow(ray_shade(kakanui_mat), 0.5) |>
  add_shadow(ambient_shade(kakanui_mat), 0) %>%
  plot_3d(kakanui_mat, zscale = 12, zoom = 0.6, theta = 50, phi = 20, windowsize = c(1080, 1080))

# Create spinning animation
render_camera(theta = seq(0, 360, length.out = 360), phi = 30, zoom = 0.6)
render_movie("kakanui_spinning.mp4", fps = 24, frames = 360, zoom = 0.6)
