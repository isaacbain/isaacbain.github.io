# libraries ---------------------------------------------------------------
library(rayshader) 
library(rayvista)
library(sf)
library(terra)

# pre-processing ----------------------------------------------------------

# import elevation data, folder full of tif files to be merged
tif_folder <- "/Users/isaacbain/working/estuary-mapping/data/lds-hawkes-bay-lidar-1m-dem-2023-GTiff/"
tif_files <- list.files(path = tif_folder, pattern = "\\.tif$", full.names = TRUE)

# Read all tif files into list
raster_list <- lapply(tif_files, terra::rast)

# catchment boundary
ahuriri <- st_read("/Users/isaacbain/working/estuary-mapping/data/ahuriri_combined/ahuriri_combined.shp")

# Convert the sf polygon to a SpatVector
polygon_spatvector <- terra::vect(ahuriri)

# Merge the rasters using do.call and terra::mosaic
merged_raster <- do.call(terra::mosaic, raster_list)

# Clip the merged raster
clipped_raster <- terra::crop(merged_raster, polygon_spatvector)
clipped_raster <- terra::mask(clipped_raster, polygon_spatvector)

# Define the aggregation factor (e.g., factor = 2 reduces the resolution by half)
factor <- 8

# Downsample the raster
downsampled_raster <- terra::aggregate(clipped_raster, fact = factor, fun = mean)

# Convert to a matrix suitable for rayshader
elevation_matrix <- raster_to_matrix(downsampled_raster)

# rayshader ---------------------------------------------------------------

# Create rayshader plot
elevation_matrix |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  add_shadow(ray_shade(elevation_matrix), 0.5) |> # adds shadow
  add_shadow(ambient_shade(elevation_matrix), 0) |>  # adds ambient light (looks nice but very slow)
  plot_3d(elevation_matrix, zscale = 2, zoom = 0.7, theta = 50, phi = 20, windowsize = c(1080, 1080)) # define plot parameters

# Create spinning animation
render_camera(theta = seq(0, 360, length.out = 360), phi = 30, zoom = 0.7) # define camera parameters, spin around y-axis
render_movie("ahuriri_spinning.mp4", fps = 24, frames = 360, zoom = 0.7) # create spinning animation
