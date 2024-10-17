import numpy as np
import rasterio

# This program calculates the Legacy Area based on legacy_coverage.tif.

# Replace this path with the actual path to your legacy_coverage.tif file
legacy_coverage_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"

# Open the legacy coverage TIFF file
with rasterio.open(legacy_coverage_path) as src:

    # Get the shape of the array
    num_rows, num_cols = src.shape
    # Calculate the total number of pixels
    total_pixels = num_rows * num_cols
    print(f"Number of Rows: {num_rows}")
    print(f"Number of Columns: {num_cols}")
    print(f"Total Number of Pixels: {total_pixels}")
    legacy_coverage = src.read(1)

    forest_pixels2 = np.count_nonzero(legacy_coverage)
    forest_area_hectares2 = forest_pixels2 * 0.09
    print(f"Total Legacy Forest Area: {forest_area_hectares2:.2f} hectares")

    # A reference source for checking calculation result: https://www.maaproject.org/2022/amazon-tipping-point/
    # Quote: "We found that the original Amazon forest covered over 647 million hectares (647,607,020 ha).
    # This is equivalent to 1.6 billion acres."
    # Result obtained via total_forest_pixels2 is about 404 million hectares, which is reasonable.

    #-----------------------------------------------------
    # Here is a method that leads to an unreasonable result. I don't know why it goes wrong.
    # forest_pixels = (legacy_coverage == 1).sum()
    # # Calculate the total area covered by legacy forest in square meters
    # total_forest_area_m2 = forest_pixels * (30.0 * 30.0)  # Use floating-point numbers
    # # Convert the area to hectares
    # total_forest_area_hectares = total_forest_area_m2 * 0.0001
    # print(f"Total Legacy Forest Pixels: {forest_pixels}")
    # print(f"Total Legacy Forest Area: {total_forest_area_hectares:.2f} hectares")
    # # This gives the following result, which is considered to be wrong as it is too small:
    # # Total Legacy Forest Pixels: 199546995
    # # Total Legacy Forest Area: 17959229.55 hectares