
# Attempt Using Image
# from PIL import Image
# Image.MAX_IMAGE_PIXELS = None
# import numpy
# im = Image.open('coverage_brazil/brasil_coverage_1985.tif')
# imarray = numpy.array(im)
# imarray.shape
# im.size
# #MemoryError

# import rioxarray
# import matplotlib.pyplot as plt
#
# dataset = rioxarray.open_rasterio('coverage_brazil/brasil_coverage_1985.tif')
# plt.figure(figsize=(8,6))
# dataset.plot()
# plt.show()
# # receiving MemoryError: numpy.core._exceptions._ArrayMemoryError:
# # Unable to allocate 22.9 GiB for an array with shape (158459, 155239) and data type bool

# # Try crop the file first and visualize the smaller file
import rasterio
from rasterio.plot import show
from rasterio.mask import mask
import geopandas as gpd
from shapely.geometry import mapping
from shapely.geometry import box
from fiona.crs import from_epsg


#
# # Load the satellite imagery (tif file)
# dataset_path = "coverage_brazil/brasil_coverage_1985.tif"
# output_path = "coverage_brazil/brasil_coverage_1985_clipped.tif"
# dataset = rasterio.open(dataset_path)
# print(dataset.meta)
# width = dataset.width
# height = dataset.height
# print(f"Width: {width}, Height: {height}")
# # show((dataset, 1), cmap='terrain') Again, MemoryError
#
# # Load the Amazon biome shapefile
# amazon_biome_shapefile_path = "Shapefile/AmazonBasinLimits-master/amazon_sensulatissimo_gmm_v1.shp"
# amazon_biome = gpd.read_file(amazon_biome_shapefile_path)
# # Check if the GeoDataFrame is not empty
# if not amazon_biome.empty:
#     print("Shapefile successfully loaded.")
#     print("\nGeoDataFrame Information:")
#     print(amazon_biome.info())
#
#     # Display the first few rows of the attribute table
#     print("\nFirst few rows of the attribute table:")
#     print(amazon_biome.head())
# else:
#     print("Failed to load the Shapefile.")
#
# bounding_box = box(*amazon_biome.total_bounds)
# clipped_geometry = gpd.GeoDataFrame(geometry=[bounding_box], crs=amazon_biome.crs)
#
# # Clip the satellite image to the Amazon biome boundary
# # Extract the geometry of the Amazon biome
# amazon_biome_geometry = amazon_biome.geometry.iloc[0]
#
# # Use the mask function to clip the satellite image based on the Amazon biome geometry
# clipped_image, transform = mask(dataset, [mapping(amazon_biome_geometry)], crop=True)
#
# # Step 4: Get metadata from the original image and update with the new transform
# # This metadata will be used when saving the clipped image
# meta = dataset.meta.copy()
# meta.update({
#     'driver': 'GTiff',  # The driver for GeoTIFF format
#     'height': clipped_image.shape[1],  # Height of the clipped image
#     'width': clipped_image.shape[2],   # Width of the clipped image
#     'transform': transform  # Affine transform for mapping pixel coordinates to geographic coordinates
# })
#
# # Step 5: Write the clipped image to a new file
# output_path = "coverage_brazil/brasil_coverage_1985_clipped.tif"
# with rasterio.open(output_path, 'w', **meta) as dest:
#     dest.write(clipped_image)
#
# # Step 6: Close the datasets to release resources
# dataset.close()
#
# # The clipped satellite image is now saved at the specified output path.



# Get Legacy Part
# Simple Loop version:
# The stupid loop takes forever to finish, but it, in theory, should give me the desire data.
import rasterio
import numpy as np

# Replace these paths with the actual paths to your TIFF files
tif_1985_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1985.tif"
tif_1986_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1986.tif"

# Output file path for the result
output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"

# Define the color codes corresponding to "forest"
forest_color_codes = [1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13]

# Open the TIFF files for 1985 and 1986
with rasterio.open(tif_1985_path) as src_1985, rasterio.open(tif_1986_path) as src_1986:
    # Create a new TIFF file for the output
    profile = src_1985.profile
    output_data = np.zeros((src_1985.height, src_1985.width), dtype=np.uint8)

    # Iterate through each row and column
    for row in range(src_1985.height):
        for col in range(src_1985.width):
            # Read pixel values for both years
            pixel_value_1985 = src_1985.read(1, window=((row, row + 1), (col, col + 1)))
            pixel_value_1986 = src_1986.read(1, window=((row, row + 1), (col, col + 1)))

            # Check if both pixels are classified as "forest"
            is_forest_1985 = pixel_value_1985[0] in forest_color_codes
            is_forest_1986 = pixel_value_1986[0] in forest_color_codes

            # If both pixels are classified as "forest" in both years, assign as "forest"
            if is_forest_1985 and is_forest_1986:
                output_data[row, col] = 1

            # This is not working: InvalidArrayError: Positional argument arr must be an array-like object
            #  if is_forest_1985 and is_forest_1986:
            #       dest.write(1, window=((row, row + 1), (col, col + 1)))
            #  else:
            #       dest.write(0, window=((row, row + 1), (col, col + 1)))

    # Write the entire output dataset to the output TIFF file
    with rasterio.open(output_tif_path, 'w', **profile) as dest:
        dest.write(output_data, 1)


# Very Concise version
# numpy.core._exceptions._ArrayMemoryError:
# Unable to allocate 11.1 GiB for an array with shape (11892635340,) and data type bool
import rasterio
import numpy as np

# Replace these paths with the actual paths to your TIFF files
tif_1985_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1985.tif"
tif_1986_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1986.tif"

# Output file path for the result
output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"

# Define the color codes corresponding to "forest"
forest_color_codes = [1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13]

# Open the TIFF files for 1985 and 1986
with rasterio.open(tif_1985_path) as src_1985, rasterio.open(tif_1986_path) as src_1986:
    # Read the entire images into NumPy arrays
    image_1985 = src_1985.read(1)
    image_1986 = src_1986.read(1)

    # Check if pixels are classified as "forest" in both years
    is_forest_1985 = np.isin(image_1985, forest_color_codes)
    is_forest_1986 = np.isin(image_1986, forest_color_codes)

    # Combine the conditions to find pixels classified as "forest" in both years
    initial_forest_stock = is_forest_1985 & is_forest_1986

    # Write the entire output dataset to the output TIFF file
    with rasterio.open(output_tif_path, 'w', **src_1985.profile) as dest:
        dest.write(initial_forest_stock.astype('uint8'), 1)
