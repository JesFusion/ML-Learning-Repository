import numpy as np

np.random.seed(40) # This is to ensure that the random numbers generated remain the same no matter how many times we run the code

array_1 = np.linspace(12, 33, 9).round(2)

array_2 = np.random.randint(38, 77, size = (4, 3))


print(f'''
============================= Inspecting the 1D array =============================
      
Array: {array_1}

Shape (Dimensions): {array_1.shape}

Number of Dimensions: {array_1.ndim}

Total Elements (Size): {array_1.size}

Data Type: {array_1.dtype}

''')


print(f'''
============================= Inspecting 2D Array =============================
      
Array:
{array_2}

Dimensions: {array_2.shape}

Number of Dimensions: {array_2.ndim}

Total Elements (Size): {array_2.size}

Data Type (dtype): {array_2.dtype}
''')


