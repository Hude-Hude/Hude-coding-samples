import rasterio
import dask.array as da

# This program takes about 3-5 min and generates legacy_coverage.tif.

# Replace these paths with the actual paths to your TIFF files
tif_1985_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1985.tif"
tif_1986_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1986.tif"

# Output file path for the result
output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"

# Define the color codes corresponding to "forest"
forest_color_codes = [1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13]

# Open the TIFF files for 1985 and 1986
with rasterio.open(tif_1985_path) as src_1985, rasterio.open(tif_1986_path) as src_1986:
    # Read the entire images into Dask arrays
    image_1985 = da.from_array(src_1985.read(1), chunks='auto')
    image_1986 = da.from_array(src_1986.read(1), chunks='auto')

    # Set conditions for classification
    is_forest_1985 = da.isin(image_1985, forest_color_codes)
    is_forest_1986 = da.isin(image_1986, forest_color_codes)

    # Combine the conditions to find pixels classified as "forest" in both years
    initial_forest_stock = da.logical_and(is_forest_1985, is_forest_1986)

    # Write the entire output dataset to the output TIFF file
    with rasterio.open(output_tif_path, 'w', **src_1985.profile) as dest:
        dest.write(initial_forest_stock.astype('uint8'), 1)

