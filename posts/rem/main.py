
import rasterio
import rasterio.merge
import glob
import os

# Set the directory containing the GeoTIFF files
input_directory = 'data/dem'
output_directory = 'out/'
output_file = os.path.join(output_directory, 'merged_output.tif')

# Ensure the output directory exists
os.makedirs(output_directory, exist_ok=True)

# Find all GeoTIFF files in the directory
geotiff_files = glob.glob(os.path.join(input_directory, '*.tif'))

# Debugging: Print the list of found files
print("Found GeoTIFF files:", geotiff_files)

# Open all the GeoTIFF files and add them to a list
src_files_to_mosaic = []
for fp in geotiff_files:
    src = rasterio.open(fp)
    src_files_to_mosaic.append(src)

# Merge all GeoTIFFs into a single mosaic
if src_files_to_mosaic:
    mosaic, out_trans = rasterio.merge.merge(src_files_to_mosaic)
    
    # Copy the metadata from one of the input files
    out_meta = src.meta.copy()
    
    # Update the metadata to reflect the number of layers and the transform
    out_meta.update({
        "driver": "GTiff",
        "height": mosaic.shape[1],
        "width": mosaic.shape[2],
        "transform": out_trans,
        "count": mosaic.shape[0]  # Number of bands
    })
    
    # Write the merged raster to disk
    with rasterio.open(output_file, "w", **out_meta) as dest:
        dest.write(mosaic)
    
    print(f"Merged GeoTIFF saved to {output_file}")
else:
    print("No GeoTIFF files found in the directory. Please check the directory path and file extensions.")

# Close all the source files
for src in src_files_to_mosaic:
    src.close()

from riverrem.REMMaker import REMMaker
# provide the DEM file path and desired output directory
rem_maker = REMMaker(dem='out/merged_output.tif', out_dir='out/')
# create an REM
rem_maker.make_rem()
# create an REM visualization with the given colormap
rem_maker.make_rem_viz(cmap='mako_r')
