import rasterio
import numpy as np
import dask.array as da

# This program calculate deforest rate for a range of years.
# This program also aims to generate an output file called deforestation_result.tif
# that records the data updated up to the last year.

legacy_coverage_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"
tif_paths = [r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1987.tif",
             r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1988.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1989.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1990.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1991.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1992.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1993.tif",
             # r"C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1994.tif",
             ]

# Output file path for the result
output_tif_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\deforestation_result.tif"

# Define color codes corresponding to human cover
legacy_coverage_code = [1]
human_cover_color_codes = [14, 15, 18, 19, 39, 20, 40, 62, 41, 36, 46, 47, 35, 48, 9, 21, 24, 30]
chunk_size = (512, 512)

# Open the TIFF file for legacy coverage
with rasterio.open(legacy_coverage_path) as src_legacy:
    image_legacy = da.from_array(src_legacy.read(1), chunks=chunk_size)
    is_legacy = da.isin(image_legacy, legacy_coverage_code)

    # Initialize data_track with zeros
    data_1987 = da.full_like(is_legacy, fill_value=0, dtype=np.uint8)

    # Iterate through the years from 1987 to 1999
    for year, tif_path in zip(range(1987, 1989), tif_paths):
        try:
            with rasterio.open(tif_path) as src:
                image_year = da.from_array(src.read(1), chunks=chunk_size)
                is_deforest_year = da.isin(image_year, human_cover_color_codes)

                # Update data_track for the current year
                data_track = da.where(is_legacy & ~is_deforest_year, 1, data_track)
                data_track = da.where(is_legacy & is_deforest_year, 2, data_track)

                # Calculate areas and deforestation rate for the current year
                remain_forest_pixels = da.count_nonzero(data_track == 1).compute()
                deforested_pixels = da.count_nonzero(data_track == 2).compute()
                deforest_area_hectares = deforested_pixels * 0.09  # Assuming 0.09 hectares per pixel
                deforest_rate = deforested_pixels / (deforested_pixels + remain_forest_pixels)
                print(f"Total Deforest Area in {year}: {deforest_area_hectares:.2f} hectares")
                print(f"Deforest Rate in {year}: {deforest_rate:.4%}")
        except FileNotFoundError:
            print(f"File not found: {tif_path}")
        except Exception as e:
            print(f"An error occurred while processing {tif_path}: {e}")

    # Save the final result to a new TIFF file
    with rasterio.open(output_tif_path, 'w', **src_legacy.profile) as dest:
        dest.write(data_track.astype('uint8'), 1)

        # This part is not working at this point.
        # numpy.core._exceptions._ArrayMemoryError:
        # Unable to allocate 11.1 GiB for an array with shape (105405, 112828) and data type uint8
