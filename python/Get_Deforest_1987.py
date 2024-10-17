import rasterio
import numpy as np
import dask.array as da

# This program calculate deforest rate in 1987.

legacy_coverage_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"
tif_1987_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1987.tif"

output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\deforestation_result.tif"

legacy_coverage_code = [1]
human_cover_color_codes = [14, 15, 18, 19, 39, 20, 40, 62, 41, 36, 46, 47, 35, 48, 9, 21, 24, 30]
chunk_size = (512, 512)

with rasterio.open(legacy_coverage_path) as src_legacy, rasterio.open(tif_1987_path) as src_1987:

    # Read the entire images into Dask arrays with the specified chunk size
    image_legacy = da.from_array(src_legacy.read(1), chunks=chunk_size)
    image_1987 = da.from_array(src_1987.read(1), chunks=chunk_size)

    # Set conditions for classification
    is_legacy = da.isin(image_legacy, legacy_coverage_code)
    is_deforest_1987 = da.isin(image_1987, human_cover_color_codes)

    # Create a new array with three values: 0 for non-legacy, 1 for remained legacy, and 2 for deforested
    data_1987 = da.full_like(is_legacy, fill_value=0, dtype=np.uint8)
    data_1987 = da.where(is_legacy & ~is_deforest_1987, 1, data_1987)
    data_1987 = da.where(is_legacy & is_deforest_1987, 2, data_1987)

    # Now you can perform operations or computations with the resulting Dask array if needed
    # For example, you can count non-zero values using da.count_nonzero
    remain_forest_pixels = da.count_nonzero(data_1987 == 1).compute()
    deforested_pixels = da.count_nonzero(data_1987 == 2).compute()
    legacy_pixels = deforested_pixels + remain_forest_pixels
    deforest_rate = deforested_pixels / legacy_pixels

    # This works
    # # Calculate areas and deforestation rate
    # forest_area_hectares = remain_forest_pixels * 0.09
    deforest_area_hectares = deforested_pixels * 0.09
    # legacy_area_hectares = forest_area_hectares + deforest_area_hectares
    # deforest_rate = deforest_area_hectares / legacy_area_hectares
    print(f"Total Deforest Area in 1987: {deforest_area_hectares:.2f} hectares")
    # print(f"Total Legacy Forest Area: {legacy_area_hectares:.2f} hectares")
    # print(f"Deforest Rate: {deforest_rate:.2f}")

