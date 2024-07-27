# libraries ---------------------------------------------------------------
library(rayshader) 
library(rayvista)
library(sf)
library(terra)

# pre-processing ----------------------------------------------------------

tif_folder <- "/Users/isaacbain/working/estuary-mapping/data/lds-hawkes-bay-lidar-1m-dem-2023-GTiff/"
tif_files <- list.files(path = tif_folder, pattern = "\\.tif$", full.names = TRUE)

# Read all tif files into a SpatRaster list
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

#downsampled_raster2 <- raster::focal(downsampled_raster, w=matrix(1, 11, 11), mean, na.rm = T)

# Convert to a matrix suitable for rayshader
elevation_matrix <- raster_to_matrix(downsampled_raster)

# rayvista ----------------------------------------------------------------

ahuriri <- plot_3d_vista(dem = downsampled_raster2,
                         phi=30,
                         outlier_filter=0.001,
                         fill_holes = TRUE,
                         zscale = 3, #5
                         overlay_detail = 14)

#render_depth(focus=0.4, focallength = 16, clear=TRUE)

render_highquality(
  filename = "test.png",
  preview = T, 
  light = T,
  lightdirection = 225,
  lightintensity = 1200,
  lightaltitude = 60,
  parallel = T,
  interactive = F,
  width = 2000,
  height = 2000
)

# rayshader ---------------------------------------------------------------

# 2d
ahuriri_2d <- elevation_matrix |> 
  sphere_shade(texture = "imhof1") |>
  add_shadow(ray_shade(elevation_matrix), 0.5) |> 
  add_shadow(ambient_shade(elevation_matrix), 0) #|> # this step takes long time
  #plot_map()

# Save the plot with a transparent background
png("ahuriri_2d.png", bg = "transparent")
plot_map(ahuriri_2d)
dev.off()

# 3d
elevation_matrix |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |>
  add_shadow(ray_shade(elevation_matrix), 0.5) |>
  add_shadow(ambient_shade(elevation_matrix), 0) %>%
  plot_3d(elevation_matrix, zscale = 2, zoom = 0.7, theta = 50, phi = 20, windowsize = c(1080, 1080))

# Create spinning animation
render_camera(theta = seq(0, 360, length.out = 360), phi = 30, zoom = 0.7)
render_movie("ahuriri_spinning.mp4", fps = 24, frames = 360, zoom = 0.7)
