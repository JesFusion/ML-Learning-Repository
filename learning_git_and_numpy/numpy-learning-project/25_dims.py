import numpy as np

an_array = np.arange(10)

print(f'''
Original Array: {an_array}
Shape: {an_array.shape}
''')

# we use np.newaxis to add a dimension of "1" to an array
col_arr = an_array[:, np.newaxis]

row_arr = an_array[np.newaxis, :]


print(f'''
Column Vector: {col_arr}
Shape: {col_arr.shape}


Row Vector: {row_arr}
Shape: {row_arr.shape}
''')


# ============================= np.squeeze() =============================


# let's create a sample 3d vector...
vector_3d = np.random.randint(1, 11, size = (1, 5, 1))

print(f'''
Original 3D Vector:
{vector_3d}
Shape: {vector_3d.shape}
''')

# now we squeeze the 3d vector using np.squeeze()
sqz_vector = np.squeeze(vector_3d)

print(f'''
Squeezed Vector:
{sqz_vector}
Shape: {sqz_vector.shape}
''')

# squeezing only the first dimension
sqz_vector_ax = np.squeeze(vector_3d, axis = 0)


print(f'''
Vector Squeezed at Axis 0:
{sqz_vector_ax}
Shape: {sqz_vector_ax.shape}
''')

