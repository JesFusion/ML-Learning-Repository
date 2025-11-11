import numpy as np

np.random.seed(19)

# ============================= operations with 1 array (broadcasting) =============================

array_1 = np.arange(33, 47).reshape(7, 2)

print(f'''
============================= Original Array (array_1) =============================

{array_1}


============================= array_1 + 89 =============================

{array_1 + 89}


============================= array_1 * -0.81 =============================

{array_1 * -0.81}


============================= array_1 to the power of 1.73 =============================

{(array_1 ** 1.73).round(2)}
''')


# ============================= operations with 2 arrays =============================

array_2 = np.linspace(0.03, 1.23, 15).reshape(3, 5).round(2)

print(f'''
============================= Original Array (array_2) =============================

{array_2}


============================= array_1 + array_2 (Element-wise) =============================
''')



array_2 = array_2.flatten()[:-1].reshape(7, 2)



print(f'''
{array_1 + array_2}


============================= array_1 * array_2 (Element-wise) =============================

{array_1 * array_2}


============================= array_1 / array_2 (Element-wise) =============================

{(array_1 / array_2).round(2)}
''')

