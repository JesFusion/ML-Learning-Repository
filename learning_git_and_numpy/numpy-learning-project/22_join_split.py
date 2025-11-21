# Joining and Splitting Arrays

import numpy as np
np.random.seed(19)


# let's create two arrays we'll practice with

array_1 = np.random.randint(0, 9, size = (5, 4)) * 0.1193975
array_2 = np.random.randn(3, 4).round(5)


print(f'''
Array 1:
{array_1}

Array 2:
{array_2}
''')

# Vertical Concatenation (axis = 0)

arr_concat_v = np.concatenate((array_1, array_2), axis = 0) # we're joining array 1 & 2 vertically. A RULE is that they must have the same number of columns

print(f'''
============================= Concatenating array_1 & array_2 Vertically =============================

{arr_concat_v.round(2)}
''')


array_1 = np.delete(array_1, -1, axis = 1)

arr_concat_h = np.concatenate((array_1.T, array_2), axis = 1) # A RULE for concatenating horizontally is that the two arrays must have the same number of rows. array_1.T transposes the array. array_1 was originally 5 x 3 but was tranposed to 3 x 5

print(f'''
============================= Concatenating array_1 & array_2 Horizontally =============================

{arr_concat_h.round(2)}
''')


# ============================= using vstack and hstack =============================

array_3 = np.random.randn(3, 4)
array_4 = np.random.rand(3, 4)

print(f'''
============================= Original Arrays =============================
      
{array_3}

{array_4}
''')

arr_v_stack = np.vstack((array_3, array_4)) # stack vertically with np.vstack()

arr_h_stack = np.hstack((array_3, array_4)) # stack horizontally with np.hstack()


print(f'''
============================= Stacking array_3 & array_4 Vertically =============================

{arr_v_stack}


============================= Stacking array_3 & array_4 Horizontally =============================

{arr_h_stack}
''')


# ============================= using np.vsplit() and np.hsplit() =============================


mass_array = np.random.randint(0, 9, size = (8, 24))

print(f'''
Big Array:
{mass_array}
''')

# splitting vertically and Horizontally...

# note that when you split into 2, the number of rows must be a multiple of 2 before Splitting in 2 is possible
upper_split, lower_split = np.vsplit(mass_array, 2)

left_split, right_split = np.hsplit(mass_array, 2)


print(f'''
============================= Splitting mass_array =============================

vsplit (Upper):
{upper_split}

vsplit (Lower):
{lower_split}

hsplit (Left):
{left_split}

hsplit (Right):
{right_split}
''')

