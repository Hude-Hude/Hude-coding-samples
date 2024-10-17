import rasterio
import numpy as np
import dask.array as da

# This program calculate deforest rate in 1987 and 1988.
# This is an experiment prepared for generalization, so the structure is inefficient.

legacy_coverage_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"
tif_1987_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1987.tif"
tif_1988_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1988.tif"

output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\deforestation_result.tif"

legacy_coverage_code = [1]
human_cover_color_codes = [14, 15, 18, 19, 39, 20, 40, 62, 41, 36, 46, 47, 35, 48, 9, 21, 24, 30]
chunk_size = (512, 512)

# Open the TIFF files for 1985, 1986, 1987, and 1988 with a fixed chunk size
with rasterio.open(legacy_coverage_path) as src_legacy, \
        rasterio.open(tif_1987_path) as src_1987, \
        rasterio.open(tif_1988_path) as src_1988:

    # Read the entire images into Dask arrays with the specified chunk size
    image_legacy = da.from_array(src_legacy.read(1), chunks=chunk_size)
    image_1987 = da.from_array(src_1987.read(1), chunks=chunk_size)
    image_1988 = da.from_array(src_1988.read(1), chunks=chunk_size)

    # Check if pixels are classified as "forest" in each year
    is_legacy = da.isin(image_legacy, legacy_coverage_code)
    is_deforest_1987 = da.isin(image_1987, human_cover_color_codes)
    is_deforest_1988 = da.isin(image_1988, human_cover_color_codes)

    # Create a new array with three values: 0 for non-legacy, 1 for remained legacy, and 2 for deforested
    data_track = da.full_like(is_legacy, fill_value=0, dtype=np.uint8)
    data_track = da.where(is_legacy & ~is_deforest_1987, 1, data_track)
    data_track = da.where(is_legacy & is_deforest_1987, 2, data_track)

    # Count the number of pixels with values 1 (remained legacy) and 2 (deforested)
    remain_forest_pixels_1987 = da.count_nonzero(data_track == 1).compute()
    deforested_pixels_1987 = da.count_nonzero(data_track == 2).compute()
    legacy_pixels = deforested_pixels_1987 + remain_forest_pixels_1987

    deforest_rate_1987 = deforested_pixels_1987 / legacy_pixels
    deforest_area_hectares_1987 = deforested_pixels_1987 * 0.09
    print(f"Total Deforest Area in 1987: {deforest_area_hectares_1987:.2f} hectares")
    print(f"Deforest Rate in 1987: {deforest_rate_1987:.4%}")

    # Update data_track for the next year (1988)
    data_track = da.where(is_legacy & ~is_deforest_1988, 1, data_track)
    data_track = da.where(is_legacy & is_deforest_1988, 2, data_track)
    # Calculate areas and deforestation rate for 1988
    remain_forest_pixels_1988 = da.count_nonzero(data_track == 1).compute()
    deforested_pixels_1988 = da.count_nonzero(data_track == 2).compute()
    deforest_rate_1988 = deforested_pixels_1988 / legacy_pixels
    print(f"Total Deforest Area in 1988: {deforested_pixels_1988 * 0.09:.2f} hectares")
    print(f"Deforest Rate in 1988: {deforest_rate_1988:.4%}")

    with rasterio.open(output_tif_path, 'w', **src_legacy.profile) as dest:
        dest.write(data_track.astype('uint8'), 1)
