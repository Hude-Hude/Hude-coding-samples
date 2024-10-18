import rasterio
import numpy as np
import dask.array as da

#   This variation is aim to differentiate between pixels that are outside the boundary and
#   pixels that are assigned as not forest.
#   Unexpected result. This program should handle the memory issue, but it still occurs.
    # numpy.core._exceptions._ArrayMemoryError:
    # Unable to allocate 128. MiB for an array with shape (11585, 11585) and data type int8

# Replace these paths with the actual paths to your TIFF files
tif_1985_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1985.tif"
tif_1986_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1986.tif"

# Output file path for the result
output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage2.tif"

# Define the color codes corresponding to "forest"
forest_color_codes = [1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13]

# Open the TIFF files for 1985 and 1986
with rasterio.open(tif_1985_path) as src_1985, rasterio.open(tif_1986_path) as src_1986:
    # Read the entire images into Dask arrays
    image_1985 = da.from_array(src_1985.read(1), chunks='auto')
    image_1986 = da.from_array(src_1986.read(1), chunks='auto')

    # Create masks to exclude pixels with value 0
    mask_1985 = image_1985 != 0
    mask_1986 = image_1986 != 0

    # Check if pixels are classified as "forest" in both years, excluding value 0 pixels
    is_forest_1985 = da.isin(image_1985, forest_color_codes) & mask_1985
    is_forest_1986 = da.isin(image_1986, forest_color_codes) & mask_1986

    # Create an array to represent excluded pixels with value -1
    excluded_pixels = da.logical_not(mask_1985) & da.logical_not(mask_1986)

    # Combine the conditions to find pixels classified as "forest" in both years
    initial_forest_stock = da.logical_and(is_forest_1985, is_forest_1986)

    # Assign values to the output dataset: -1 for excluded pixels, 0 for "not forest," and 1 for "forest"
    output_data = da.where(excluded_pixels, -1, da.where(initial_forest_stock, 1, 0))

    # Write the entire output dataset to the output TIFF file
    with rasterio.open(output_tif_path, 'w', **src_1985.profile) as dest:
        dest.write(output_data.astype('int8'), 1)
