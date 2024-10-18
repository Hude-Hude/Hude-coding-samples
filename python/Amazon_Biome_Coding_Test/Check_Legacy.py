import numpy as np
import rasterio
import random

def check_random_forest_classification(classified_raster_path, forest_value, num_samples):
    # Open the classified raster
    with rasterio.open(classified_raster_path) as classified_raster:
        # Read the entire dataset into a NumPy array
        classified_data = classified_raster.read(1)

        # Get the dimensions of the raster
        rows, cols = classified_data.shape

        # Randomly sample pixels and check the forest classification
        for _ in range(num_samples):
            random_row = random.randint(0, rows - 1)
            random_col = random.randint(0, cols - 1)

            pixel_value = classified_data[random_row, random_col]

            # Check if the pixel is classified as forest
            is_forest = pixel_value == forest_value

            # Print the result
            print(f"Pixel at ({random_row}, {random_col}): Classified as Forest - {is_forest}")

# the function get_forest_pixel_sample retrieves the coordinates of all pixels classified as forest
# and then randomly samples a specified number (sample_size) from those coordinates.

legacy_coverage_path = "coverage_amazon/legacy_coverage.tif"
tif_1986_path = "coverage_amazon/amazon_coverage_1986.tif"
tif_1985_path = "coverage_amazon/amazon_coverage_1985.tif"
forest_value = 1  # Adjust if your forest classification value is different
num_samples = 5  # Adjust the number of random samples as needed

check_random_forest_classification(legacy_coverage_path, forest_value, num_samples)

# An attempt made by running check_for_forest_pixels (see the end of this code)
# It took very long time to run.
# The goal is to check if there is pixels being actually assigned to Forest
# The previous experiment by running check_random_forest_classification gives me a list of False.
# The odds may or may not be reasonable, since I am unable to visualize the output.
# Hence, a stupid way is to manually locate a pixel with code in the forest_code list
# Here is a result from Check_clip:
# Coordinates: (55785, 28536), Pixel Value: 3
with rasterio.open(legacy_coverage_path) as src_legacy, rasterio.open(tif_1986_path) as src_1986, rasterio.open(tif_1985_path) as src_1985:
    # Read the image data into a 2D NumPy array
    legacy_bands = src_legacy.count
    # Print the number of bands
    print("Number of Bands (Legacy):", legacy_bands)
    x = 55785
    y = 28536
    dataset_legacy = src_legacy.read(1)
    pixel_value_legacy = dataset_legacy[x, y]
    dataset_1986 = src_1986.read(1)
    pixel_value_1986 = dataset_1986[x, y]
    dataset_1985 = src_1985.read(1)
    pixel_value_1985 = dataset_1985[x, y]
    print(f"Coordinates: ({x}, {y}), Legacy Pixel Value: {pixel_value_legacy}")
    print(f"Coordinates: ({x}, {y}), 1986 Pixel Value: {pixel_value_1986}")
    print(f"Coordinates: ({x}, {y}), 1985 Pixel Value: {pixel_value_1985}")

# def check_for_forest_pixels(classified_raster_path, forest_value):
#     # Open the classified raster
#     with rasterio.open(classified_raster_path) as classified_raster:
#         # Read the entire dataset into a NumPy array
#         classified_data = classified_raster.read(1)
#
#         # Check for forest pixels
#         forest_pixels_found = False
#
#         for row in range(classified_data.shape[0]):
#             for col in range(classified_data.shape[1]):
#                 pixel_value = classified_data[row, col]
#
#                 # Check if the pixel is classified as forest
#                 if pixel_value == forest_value:
#                     print(f"Found a Forest Pixel at Coordinates: ({row}, {col})")
#                     forest_pixels_found = True
#
#         # Print a message if no forest pixels are found
#         if not forest_pixels_found:
#             print("No Forest Pixels Found in the Classified Raster")
