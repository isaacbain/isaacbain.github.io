# libraries ---------------------------------------------------------------
library(rayshader) 
library(rayvista)
library(sf)
library(terra)
library(gifski)

# pre-processing ----------------------------------------------------------

r <- rast("data/GEBCO_10_Aug_2024_8ceb2074bd31/gebco_2024_n-40.5121_s-42.294_w173.4459_e175.7843.tif")

# Reproject the raster to NZTM2000 (EPSG:2193)
r <- project(r, "EPSG:2193")

# Convert to a matrix suitable for rayshader
elevation_matrix <- raster_to_matrix(r)

# rayshader ---------------------------------------------------------------

# Create rayshader plot
elevation_matrix |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  add_shadow(ray_shade(elevation_matrix), 0.5) |> # adds shadow
  add_shadow(ambient_shade(elevation_matrix), 0) |> # adds ambient light (looks nice but very slow)
  plot_3d(elevation_matrix,
          zscale = 100,
          water = TRUE,
          wateralpha = 0.5,
          watercolor = "#4F42B5",
          waterlinecolor = NULL,
          waterdepth = 0,
          windowsize = c(1300, 1000),
          zoom = 0.7
          )

# animate -----------------------------------------------------------------

# Function to create each frame with varying water depth
create_frame <- function(waterdepth) {
  elevation_matrix |> 
    sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
    add_shadow(ray_shade(elevation_matrix), 0.5) |> # adds shadow
    add_shadow(ambient_shade(elevation_matrix, multicore = TRUE), 0) |> # adds ambient light (looks nice but very slow)
    plot_3d(elevation_matrix,
            zscale = 100,
            water = TRUE,
            wateralpha = 0.5,
            watercolor = "#4F42B5",
            waterlinecolor = NULL,
            waterdepth = waterdepth,
            windowsize = c(1300, 1000),
            zoom = 0.7
    )
  
  # Save the current frame
  render_snapshot(paste0("frames/frame_", sprintf("%03d", abs(waterdepth)), ".png"))
}

# Create frames for depths from 0 to -1000 in steps of -50
depths <- seq(0, -270, by = -2)
lapply(depths, create_frame)

# Combine frames into a GIF
gifski(png_files = sprintf("frames/frame_%03d.png", abs(depths)), gif_file = "water_depth_animation.gif", delay = 0.08)

# Or combine frames into a video
av::av_encode_video(input = sprintf("frames/frame_%03d.png", abs(depths)), output = "water_depth_animation.mp4", framerate = 10)

# Clean up: remove individual frame files after creating the animation
# file.remove(sprintf("frames/frame_%03d.png", abs(depths)))

# scenario 1 --------------------------------------------------------------

# Create rayshader plot
elevation_matrix |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  add_shadow(ray_shade(elevation_matrix), 0.5) |> # adds shadow
  add_shadow(ambient_shade(elevation_matrix, multicore = TRUE), 0) |> # adds ambient light (looks nice but very slow)
  plot_3d(elevation_matrix,
          zscale = 100,
          water = TRUE,
          wateralpha = 0.5,
          watercolor = "#4F42B5",
          waterlinecolor = NULL,
          waterdepth = -140,
          windowsize = c(1300, 1000),
          zoom = 0.7,
          phi = 89.9,
          theta = -0.7
  )

render_snapshot("scenario_1.png")

# scenario 2 --------------------------------------------------------------

# Create rayshader plot
elevation_matrix |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  add_shadow(ray_shade(elevation_matrix), 0.5) |> # adds shadow
  add_shadow(ambient_shade(elevation_matrix, multicore = TRUE), 0) |> # adds ambient light (looks nice but very slow)
  plot_3d(elevation_matrix,
          zscale = 100,
          water = TRUE,
          wateralpha = 0.5,
          watercolor = "#4F42B5",
          waterlinecolor = NULL,
          waterdepth = -200,
          windowsize = c(1300, 1000),
          zoom = 0.7,
          phi = 89.9,
          theta = -0.7
  )

render_snapshot("scenario_2.png")

