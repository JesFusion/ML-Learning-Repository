import numpy as np


np.random.seed(19)


the_array = np.random.rand(3, 3) * 10

print(f'''
============================= Original Data =============================

{the_array}
''')


n_g_4 = (the_array > 4) # n_g_4 stands for numbers greater than 4

print(f'''
============================= Boolean Mask (all values > 4) =============================

{n_g_4}


============================= Filtered Data (only values > 4) =============================

{the_array[n_g_4]}
''')


array_2 = np.random.randint(14, 89, size = (6, 5))

n_g_20_l_55 = (array_2 > 20) & (array_2 < 55)

print(f'''
============================= New Integer Array =============================

{array_2}

      
============================= Boolean Mask (values > 20 AND < 55) =============================

{n_g_20_l_55}


============================= Filtered Data (> 20 AND < 55) =============================

{array_2[n_g_20_l_55]}
''')

# numpy creates a 1D array containing only the elements where the corresponding mask value was True

OR_mask = (array_2 < 40) | (array_2 > 80)

print(f'''
============================= Boolean Mask (values < 40 OR > 80) =============================
      
{OR_mask}


============================= Filtered Data (< 40 OR > 80) =============================

{array_2[OR_mask]}



============================= Use Case of Boolean Masks: Cleaning Data =============================
''')

data_set = np.random.randn(3, 5) * 15

print(f'''
============================= Original Data =============================
      
{data_set}
''')

data_set[data_set < 0] = 0


print(f'''
============================= Replacing all elements less than 0 with 0 =============================

{data_set}
''')