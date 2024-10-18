import rasterio
import numpy as np

# Doesn't work
# Tried to handle the memory via window, but it still triggered Memory Error

tif_1985_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1985.tif"
tif_1986_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1986.tif"

# Color codes corresponding to "forest"
forest_color_codes = [1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13]

output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"

def classify_forest_chunk(chunk_data):
    forest_mask_chunk = np.isin(chunk_data, forest_color_codes)
    return forest_mask_chunk

with rasterio.open(tif_1985_path) as src_1985, rasterio.open(tif_1986_path) as src_1986:
    # Iterate over the image in chunks
    # The block_windows(1) method is used to iterate over the dataset in blocks or windows,
    # where the parameter 1 indicates the band number (in case the raster dataset has multiple bands).
    for _, window in src_1985.block_windows(1):
        chunk_data_1985 = src_1985.read(1, window=window)
        chunk_data_1986 = src_1986.read(1, window=window)

        forest_mask_chunk_1985 = classify_forest_chunk(chunk_data_1985)
        forest_mask_chunk_1986 = classify_forest_chunk(chunk_data_1986)

        initial_forest_stock_chunk = np.logical_and(forest_mask_chunk_1985, forest_mask_chunk_1986)

        # Write the result chunk to the output TIFF file
        with rasterio.open(output_tif_path, 'w', **src_1985.meta) as dest:
            dest.write(initial_forest_stock_chunk.astype('uint8'), 1, window=window)