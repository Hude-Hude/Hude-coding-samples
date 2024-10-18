import fiona
import rasterio
from rasterio.mask import mask

def create_mask_from_shapefile(shapefile_filepath, input_filepath, output_filepath):
    # open shapefile
    with fiona.open(shapefile_filepath, 'r') as shapefile:
        shapes = [feature['geometry'] for feature in shapefile]

    with rasterio.open(input_filepath, 'r') as src:
        out_image, out_transform = mask(src, shapes,
                                        crop=True)  # setting all pixels outside of the feature zone to zero
        out_meta = src.meta

    out_meta.update({
        "driver": "GTiff",
        "height": out_image.shape[1],
        "width": out_image.shape[2],
        "transform": out_transform
    })

    with rasterio.open(output_filepath, "w", **out_meta) as dest:
        dest.write(out_image)


# usage by changing input path and output path
input_raster_path = r'C:\RA_Projects\RA_CodingTest\coverage_brazil\brasil_coverage_1999.tif'
input_shapefile_path = r'C:\RA_Projects\RA_CodingTest\Shapefile\AmazonBasinLimits-master\amazon_sensulatissimo_gmm_v1.shp'
output_raster_path = r'C:\RA_Projects\RA_CodingTest\coverage_amazon\amazon_coverage_1999.tif'

create_mask_from_shapefile(input_shapefile_path, input_raster_path, output_raster_path)
