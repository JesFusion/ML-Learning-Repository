# --- Image Processor v1.0 ---
import numpy as np

np.random.seed(19)

base_image = np.random.randint(0, 255, size = (8, 8))

print(f'''
============================= Base Image =============================

{base_image}


============================= Center 4x4 =============================

{base_image[2:-2, 2:-2]}

============================= Pixel at row 0, Column 0 =============================

{base_image[0, 0]}


============================= "Even" Rows =============================

{base_image[::2, :]}
''')