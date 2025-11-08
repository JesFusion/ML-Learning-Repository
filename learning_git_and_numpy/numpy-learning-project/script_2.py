import numpy as np

a_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]



first_array = np.array(a_list)


print(f'''
============================= My first array =============================
      
{first_array}


============================= The type of this object is =============================

{type(first_array)}


============================= The data type (dtype) of items inside the array is =============================

{first_array.dtype}


============================= The array multiplied by 3 (Vectorization) =============================

{first_array * 3}

============================= The array with 0.5 subtracted (Vectorization) =============================

{first_array - 0.5}
''')































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












































print(f'''
============================= np.arange() (stop) =============================
      
{np.arange(11)}


============================= np.arange(6, 17) (start, stop) =============================

{np.arange(6, 17)}


============================= np.arange() (start, stop, step) =============================

{np.arange(0, 11, 2)}


============================= using floats =============================

{np.arange(11.2, 34.6, 2.2)}



============================= using np.linspace() =============================

np.linspace() includes the stop value, unlike np.arange()

============================= np.linspace() (start, stop, no. of points) =============================

4 evenly spaced values between 1 and 37
{np.linspace(1, 37, 4)}


27 evenly spaced values between 2 and 100
{np.linspace(2, 100, 27).round(2)}
''')



PI = np.pi

x_axis = np.linspace(0, 2 * PI, 121)




print(f'''

============================= Plotting sine waves using linspace =============================
      
121 values for a sine wave (showing first 27)
{x_axis[:27]}


============================= Excluding the endpoint of a linear space =============================

{np.linspace(2, 45, 7, endpoint = False)}
''')









































np.random.seed(19)


print(f'''
============================= 4 x 5 Uniform array (between 0.0 & 1.0) =============================
      
{np.random.rand(4, 5)}


============================= 2 x 4 Normal Array (Bell Curve) =============================

{np.random.randn(2, 4)}

Mean of the array sould be close to zero: {np.random.randn(2, 4).mean().round(3)}


============================= 6 x 3 Integer Array =============================

{np.random.randint(14, 57, size = (6, 3))}




============================= Shuffling an existing array =============================
''')


an_array = np.random.randint(3, 11, size = (3, 3))


print(f'''
============================= Original array =============================

{an_array}
''')



np.random.shuffle(an_array)

print(f'''
============================= Shuffled Array =============================

{an_array}
''')







































np.random.seed(40)

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





















































array_1 = np.arange(43, 55)

print(f'''
============================= 1D Indexing =============================

Full Array: {array_1}

First Element: {array_1[0]}

Last Element: {array_1[-1]}

Second to Last Element: {array_1[-2]}

6th to Last Element: {array_1[5:]}
''')


_2d_array = np.array([
    [-1, 3, .4],

    [6.7, 11, 23],

    [0, -2, 7]
])


print(f'''
============================= 2D Indexing =============================
      
Full Array: {_2d_array}

Row 1, Column 2: {_2d_array[1, 2]}

Row 1, Column 0: {_2d_array[1, 0]}

Row 2, Column 0: {_2d_array[2, 0]}
''')


# Once lived a man whose name was John Doe. This is a comment


print(f'''
First Two Rows: {_2d_array[:2]}

Last Two Columns: {_2d_array[:, 1:]}
''')




















































D2_array = (np.arange(34, 83) * -0.3).reshape((7, 7))


print(f'''
============================= Original 5x5 Array =============================

{D2_array}


============================= First Two Rows and All Columns =============================

{D2_array[:2, :]}


============================= Columns 1 and 2 and All Rows =============================

{D2_array[:, 1:3]}


============================= Rows 1 & 2, Columns 1, 2, 3 =============================

{D2_array[1:3, 1:4]}


============================= Every 2nd Row, Every 2nd Column =============================

{D2_array[::2, ::2]}


============================= Get every 2 rows from row 0 to 4. Get every 2 columns from column 1 to 5 =============================

{D2_array[0:5:2, 1:6:2]}


============================= All rows with reversed columns =============================

{D2_array[::3, ::-1]}
''')































































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






















































np.random.seed(19)

an_array = np.random.randint(23, 78, size = (10,)).reshape(-1)

print(f'''
============================= Original NumPy Array =============================
      
{an_array}

Shape: {an_array.shape}


============================= hand-Picking the 1st, 2nd and Last Element =============================

{an_array[[0, 1, -1]]}


============================= Repeating the Picking of the First and Last Elements =============================

{an_array[[1, -1, 1, -1]]}
''')

array_2 = (np.random.rand(5, 3) * 35).round(2)


print(f'''
============================= Original Data =============================
      
{array_2}


============================= Extracting the 1st, 2nd and Last rows =============================

{array_2[[0, 1, -1]]}
''')

# it's also possible to reorder the entire array

ror_array = array_2[[2, 1, 4, 0, 3]]


print(f'''
============================= Data in re-arranged row order =============================

{ror_array}
''')






















































































































































































































































































































































































































