# Land Cover Change Detection in the Amazon Biome

**Author**: Hude Hude  
**Contact**: hh3024@columbia.edu

## Project Overview

This project analyzes satellite imagery of land cover in the Amazon biome, focusing on deforestation trends from 1985 to 2020. The primary objective is to subset the data for the Amazon biome, classify pixels as "forest" or "non-forest," calculate deforestation rates, and visualize changes in land cover over time.

This project is the result of a coding test with a time constraint of 3 days. I had no prior experience with satellite data or packages like `rasterio`, but I was able to complete 80% of the task from scratch. I believe this test demonstrates my general programming knowledge and ability to quickly learn new tools and adapt to new setups.

### Key Tasks

1. **Subsetting the Data (Task 1)**:
   - **Scripts**: `Get_AmazonBiome_new.py`, `Check_Shapefile.py`, `Check_clip.py`
   - The Amazon biome was extracted from Brazil’s satellite data, using shapefiles to subset the region.
   - **Results**: Subset data and shapefile visualization outputs are stored in the `coverage_amazon` and `Outputs` folders.

2. **Forest Classification (Task 2)**:
   - **Script**: `Get_Legacy.py`
   - Initial forest cover was identified based on the 1985 and 1986 data, generating `legacy_coverage.tif` to represent the legacy forest.
   - **Results**: Legacy forest data is stored in `legacy_coverage.tif`.

3. **Legacy Forest Area Calculation (Task 3)**:
   - **Script**: `Get_LegacyArea.py`
   - Calculated the total legacy forest area in hectares using the generated `legacy_coverage.tif`.
   - **Results**: 
     - Total Pixels: 11.89 billion
     - Legacy Forest Area: 404.5 million hectares

4. **Deforestation Rate Calculation (Task 4)**:
   - **Script**: `Get_Deforest_Nested.py`
   - Calculated annual deforestation rates from 1987 to 1994 based on changes in land cover from "forest" to "human cover."
   - **Results**: Deforestation rates and areas for each year are detailed in the script outputs.

5. **Final Visualization and Task 5**:
   - Ongoing work with some initial ideas but no final output yet due to memory issues in processing.

### Challenges

- **Memory and Performance**: 
  - Significant memory errors were encountered due to the large size of the `.tif` data. Using a 16GB RAM machine required creative solutions to optimize memory usage. Task 5 remains incomplete due to memory limitations.
  - Some programs take considerable time to run (up to an hour for certain scripts).

### Tools Used

- **Programming Languages**: Python (main)
- **Libraries**: `rasterio`, `numpy`, `pandas`, `matplotlib`
- **Hardware**: PC with 16GB RAM

