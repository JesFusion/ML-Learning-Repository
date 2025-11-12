# Review of last few modules

import numpy as np

np.random.seed(19) # jesse is 19 years old

array_a = np.random.rand(3, 5).round(2)

print(f'''
============================= Original array_a =============================

{array_a}

============================= array_a * 5.1 =============================

{(array_a * 5.1).round(2)}


============================= array_a / 0.119 =============================

{(array_a / 0.119).round(2)}


============================= array_a + 3.9 =============================

{(array_a + 3.9)}


============================= array_a - 0.14 =============================

{array_a - 0.14}


============================= Square Root of array_a =============================

{np.sqrt(array_a)}


============================= Exponential of array_a =============================

{np.exp(array_a)}


============================= Natural Log of array_a =============================

{np.log(array_a)}


============================= Ceil of array_a =============================

{np.ceil(array_a * 10.5134)}


============================= Floor of array_a =============================

{np.floor(array_a * 15.2571)}
''')


# ============================= BroadCasting =============================

d1_array = np.linspace(3, 4, 5)

d2_array = np.random.randint(1, 25, size = (5, 5))

print(f'''
============================= BroadCasting =============================
      

d1_array: {d1_array}

Shape: {d1_array.shape}

d2_array:
{d2_array}

Shape: {d2_array.shape}

BroadCasting d1_array to d2_array, we have:

{d2_array + d1_array}
''')