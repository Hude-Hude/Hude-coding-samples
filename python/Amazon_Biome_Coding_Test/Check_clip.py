import rasterio
from rasterio.plot import show
import random

def visualize_random_pixels(dataset_path, window_size, num_samples):
    # Open the TIFF file
    with rasterio.open(dataset_path) as src:
        # Read the image data into a 2D NumPy array
        num_bands = src.count
        # Print the number of bands
        print("Number of Bands:", num_bands)
        dataset = src.read(1)  # Equivalent to read() given that # of band = 1
        subset = src.read(window=window_size)

    # print(dataset) takes a few seconds that prints the entire NumpyArray
    # it looks like full of zeros, which makes sense as points at corners have empty value
    # However, it is safer to check if it is not full of zero
    print("Shape of the single band:", dataset.shape)
    lower_limit1, upper_limit1 = window_size[0]
    lower_limit2, upper_limit2 = window_size[1]

    for i in range(num_samples):
        random_number1 = random.randint(lower_limit1, upper_limit1)
        random_number2 = random.randint(lower_limit2, upper_limit2)
        pixel_value = dataset[random_number1, random_number2]
        print(f"Coordinates: ({random_number1}, {random_number2}), Pixel Value: {pixel_value}")

    show(subset)

dataset_path = r"C:\RA_Projects\RA_CodingTest\coverage_amazon\legacy_coverage.tif"
window_size = ((60000, 90000), (60000, 90000))
num_samples = 20
visualize_random_pixels(dataset_path, window_size, num_samples)
