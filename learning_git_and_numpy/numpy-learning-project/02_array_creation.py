import numpy as np

z_array = np.zeros((7))


print(f'''
============================= 1D Array of Zeros (shape: 7) =============================
      
{z_array}


============================= 2D Array of Ones (Shape: 4, 5) =============================

{np.ones((4, 5))}


============================= 2D Array filled with 5 =============================

{np.full((2, 4), 5)}


============================= 2D Array of Ones (dtype = int) =============================

{np.ones((3, 2), dtype = int)}


Data Type: {np.ones((3, 2), dtype = int).dtype}
''')