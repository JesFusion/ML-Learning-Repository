import numpy as np
np.random.seed(19)

# original numpy array...
array_1D = np.random.randint(23, 67, size = (1, 72))

print(f"Original ID array [Shape: {array_1D.shape}] (First 10 Columns):\n{array_1D[:, :10]}")


# .reshape() is used to change the array's dimensions without changing it's values
array_2D = array_1D.reshape((8, 9))

print(f"\nReshaping array_1D (Shape: {array_2D.shape}) to a 2D array: \n{array_2D}")

# let's reshape it to a 3D array...

array_3D = array_1D.reshape((3, 6, 4)) # 3 stacks of 6 x 4 matrices

print(f"\nReshaping array_1D to 3D array (Shape: {array_3D.shape}):\n{array_3D}")



# we use -1 when we don't want to do the math of converting 1d to 2d array

# instead of:
# np.arange(15).reshape((3, 5))
# we use:
# np.arange(15).reshape((3, -1))


t_array = np.random.randint(45, 99, size = (45,))


# let's use -1 to reshape
# i know 45 = 9 * x
# but i don't want to do the math to find what x is
# so i just do this...

t_array_r = t_array.reshape((9, -1)) # NumPy does the math, and finds out it's 5


print(f'''
Original Array (Shape: {t_array.shape}):
{t_array}

Array reshaped with -1 (Shape: {t_array_r.shape}):
{t_array_r}

What value did NumPy calculate? {t_array_r.shape[1]}
''')


# ============================= .ravel() vs. .flatten() =============================

# let's use a 5 x 6 matrix to practice this

the_matrix = np.random.randint(23, 67, size = (5, 6))

flat_matrix = the_matrix.flatten()

print(f'''
Original Matrix:
{the_matrix}

Flattened Copy:
{flat_matrix}
''')

# let's change 1 element in flat_matrix

flat_matrix[-1] = -3.45

print(f'''
Changed flat_matrix:
{flat_matrix}

Original Matrix:
{the_matrix}
''') # notice that the original matrix remained unchanged


# unlike .flatten(), .ravel() mods the original matrix

# let's use a new matrix

the_matrix2 = np.arange(20).reshape(5, 4)

# let's use ravel to flatten it and then try to modify...
ravel_copy = the_matrix2.ravel()


print(f'''
Original Matrix:
{the_matrix2}

Raveled Copy:
{ravel_copy}
''')

ravel_copy[-1] = 99 # last item changed to 99

print(f'''
Changed Raveled Copy:
{ravel_copy}

Original Matrix:
{the_matrix2}
''') # notice that the last value in the original matrix changed too





