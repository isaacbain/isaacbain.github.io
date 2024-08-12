
lake <- st_read("data/lds-nz-lake-polygons-topo-150k-SHP/nz-lake-polygons-topo-150k.shp") |>
  dplyr::filter(name == "Lake Forsyth (Lake Wairewa)")

# elevation_clipped_smooth

lake_raster <- rasterize(lake, elevation_clipped_smooth)

land_raster <- mask(elevation_clipped_smooth, lake_raster, inverse = TRUE)

water_raster <- mask(elevation_clipped_smooth, lake_raster, inverse = FALSE)

# convert to matrix
land_mat <- raster_to_matrix(land_raster[[1]])

water_mat <- raster_to_matrix(water_raster[[1]])

catchment_mat <- raster_to_matrix(elevation_clipped_smooth[[1]])

# rayshader
land_mat |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  plot_3d(land_mat, zscale = 1) # define plot parameters

# export
save_3dprint("data/test/land.stl",
             maxwidth = 200,
             rotate = TRUE)

water_mat |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  plot_3d(water_mat, soliddepth = -20, zscale = 1) # define plot parameters

# export
save_3dprint("data/test/water.stl",
             maxwidth = 200,
             rotate = TRUE)

catchment_mat |> 
  sphere_shade(texture = "imhof1", sunangle = 45) |> # creates colour gradient
  plot_3d(catchment_mat, zscale = 1) # define plot parameters

# export
save_3dprint("data/test/catchment.stl",
             maxwidth = 200,
             rotate = TRUE)
