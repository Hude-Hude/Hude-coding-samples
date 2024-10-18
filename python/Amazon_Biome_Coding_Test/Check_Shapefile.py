import geopandas as gpd
import matplotlib.pyplot as plt

# Replace "path/to/amazon_biome_shapefile.shp" with the actual path to your shapefile
shapefile_path = r"C:\RA_Projects\RA_CodingTest\Shapefile\AmazonBasinLimits-master\amazon_sensulatissimo_gmm_v1.shp"

# Read the shapefile using geopandas
amazon_biome = gpd.read_file(shapefile_path)

# Plot the shapefile
amazon_biome.plot()
plt.title("Amazon Biome Shapefile")
plt.xlabel("Longitude")
plt.ylabel("Latitude")
plt.show()
