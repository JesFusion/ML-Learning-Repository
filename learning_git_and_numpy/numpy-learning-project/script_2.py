import numpy as np
import time
import pandas as pd
from jesse_custom_code.pandas_file import database_path as d_path
from sqlalchemy import create_engine

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
































































'''
Vectorization is what makes numpy lists faster than traditional python lists. Here's why:

1. The computer performs the operation on every element at once
2. It is written in C, which is blazing fast compared to python
3. All the element data types are the same, so there's no need for type checking, which saves time and makes processing faster
'''

# ============================= testing addition of corresponding elements in manual python lists =============================

f_list = list(range(1_000_000))

s_list = list(range(1_000_000))

result_l = []

# get start time, loop and get end time
start_time = time.time()

for x in range(len(f_list)):

    result_l.append(f_list[x] + s_list[x])

end_time = time.time()

python_duration = end_time - start_time

print(f'''
First Five results: {result_l[:5]}


Python Loop Time: {python_duration:.6f} seconds
''')


# ============================= trying the same operation with Numpy =============================


array_1 = np.arange(1_000_000)

array_2 = np.arange(1_000_000)


N_start_time = time.time()

N_result = array_1 + array_2

N_end_time = time.time()

numpy_duration = N_end_time - N_start_time


print(f'''
Numpy Vectorization Time: {numpy_duration:.6f}


Python Time is {python_duration:.6f} while Numpy time is {numpy_duration:.6f}
''')

# Vectorization applies to all math operations, not just addition

an_array = np.arange(4)

print(f'''
Original Array: {an_array}

Array multiplied by 3: {an_array * 3}

Sine of Array: {np.sin(an_array)}
''')






















































# Columns: [ProductID, CategoryID, Price, Rating, Stock]
# ProductID is the same as the row index
products = np.array([
    [0, 1, 59.99, 4.5, 50],   # Product 0
    [1, 2, 120.50, 4.0, 10],  # Product 1
    [2, 1, 25.00, 3.5, 200],  # Product 2
    [3, 3, 750.00, 4.8, 5],   # Product 3
    [4, 2, 29.99, 4.1, 150],  # Product 4
    [5, 1, 42.75, 4.6, 20],   # Product 5
    [6, 3, 1500.00, 4.9, 2],  # Product 6
    [7, 2, 85.00, 3.8, 0],    # Product 7
    [8, 1, 19.99, 3.0, 0],    # Product 8
    [9, 3, 199.99, 4.7, 30]   # Product 9
])



sale_prices = (products[:, 2]) * (90 / 100)

high_value_products = products[(products[:, 3] >= 4.5) & (products[:, 4] > 0)]

urgent_action_products = products[(products[:, 4] <= 10) | (products[:, 4] > 0)]


featured_products = products[[5, 1, 8]]



print(f'''
============================= Original Dataset =============================

{products}


============================= Sale Prices =============================

{sale_prices}


============================= High Value Products =============================

{high_value_products}


============================= Urgent Action Products =============================

{urgent_action_products}


============================= Featured Products =============================

{featured_products}
''')

print(products > 50)











































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









































a_array = np.linspace(-10, 11, 20).round(2)

print(f'''
============================= Original Array =============================
      
{a_array}


============================= Abslute Value of a_array =============================

{np.abs(a_array)}


============================= Square Root of a_array =============================

{np.sqrt(a_array)}
''')
# Notice that numpy places nan where the element was a negative number

# let's make everything positive by using the absolut function

print(f'''
============================= Square Root of Absolute a_array =============================

{np.sqrt(np.abs(a_array)).round(2)}
''')


# ============================= let's practice on Exponential and Logarithm Universal Functions (UFuncs) =============================


b_array = np.linspace(1, 9, 23).round(2)

print(f'''
============================= Original Array =============================

{b_array}
''')

# np.exp() for finding the exponential of each element; very useful for an Ml engineer. It is also used in the "softmax" activation function

print(f'''
============================= Exponential of b_array =============================

{np.exp(b_array).round(2)}
''')

# np.log() is used in "log loss"/cross-entropy

print(f'''
============================= Natural Log of b_array =============================

{np.log(b_array).round(2)}
''')

# let's check if we'll get back the array by finding the logarithm of it's exponential

print(f'''
============================= Logarithm of Exponential of b_array =============================

{np.log(np.exp(b_array))}
''') # check out that it worked!



# ============================= How to Round UFuncs =============================

c_array = np.linspace(10, 13, 27)

print(f'''
============================= Original Array =============================

{c_array}
''')

# np.floor() rounds down
# e.g:
# np.floor(4.1) = 4
# np.floor(3.7) = 3

print(f'''
============================= Foor of c_array =============================
      
{np.floor(c_array)}
''')


# np.ceil() rounds up
# e.g:
# np.floor(4.1) = 5
# np.floor(3.7) = 4

print(f'''
============================= Ceiling of c_array =============================
      
{np.ceil(c_array)}
''')

# np.round() rounds normally

print(f'''
============================= Round of c_array =============================

{np.round(c_array)}


============================= Rounding to 2 decimal places =============================

{np.round(c_array, 2)}
''')












































np.random.seed(19)

array_a = np.random.randint(32, 54, size = (3, 4))

broadcast_scalar = 0.41

array_b = array_a + broadcast_scalar # the scalar is broadcasted across the matrix, like spraying paint on a wall

print(f'''
============================= BroadCasting a Scalar =============================

      
============================= Original Array (array_a) =============================
      
{array_a}

Shape: {array_a.shape}


============================= BroadCasting 0.41 to array_a =============================

{array_b}

Shape: {array_b.shape}
''')


# ============================= Broadcasting 1D array to 2D array =============================

array_c = np.linspace(3, 4, 9).reshape(3, 3).round(2)

array_d = np.linspace(4, 8, 3)

print(f'''
============================= BroadCasting a 1D Row Vector on a Matrix =============================

============================= Original Matrix (Shape: {array_c.shape}) =============================

{array_c}


============================= Original Vector (Shape: {array_d.shape}) =============================

{array_d}


============================= array_c + array_d (Shape: {(array_c + array_d).shape}) =============================

{array_c + array_d} 
''')

# ============================= Broadcasting a 2D Column Vector to a 2d array =============================

# np.arange() creates an array of vales from a start to a stop
array_e = np.arange(1, 4).reshape(3, 1)


# np.linspace() creates an array with a number of specified elements between a start and a stop

array_f = np.linspace(1, 9, 9).reshape(3, 3)

print(f'''
============================= Broadcasting a 2d column vector (Matrix + Vector) =============================

============================= Original Vector (Shape: {array_e.shape}) =============================

{array_e}


============================= Original Matrix (Shape: {array_f.shape}) =============================

{array_f}


============================= array_e + array_f =============================

{array_e + array_f}

Shape: {(array_e + array_f).shape}
''')
















































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


























np.random.seed(19)
np.set_printoptions(suppress = True)


# extracting our dataset from an SQL database with sqlalchemy...

the_engine = create_engine(f"sqlite:///{d_path}")


# the features we'll be making use of for this practice is the Age, Salary and Children features

the_dataset = pd.read_sql(
    '''
    SELECT Age, Salary, Children
    FROM Employees
    LIMIT 967
    ''',

    the_engine
)


print(f'''
============================= Original Dataset =============================

{the_dataset.head().to_markdown()}
''')


# converting the dataframe to a numpy array for processing 

the_dataset = the_dataset.to_numpy()


print(f'''
============================= DataFrame converted to Numpy array =============================

{the_dataset[:6]}

Shape: {the_dataset.shape}
''')

# let's broadcast the "age" column by adding a scalar

the_dataset[:, 2] = the_dataset[:, 2] + 1901.34


print(f'''
============================= Numpy array after Broadcasting the 3rd column =============================

{the_dataset[:6]}

Shape: {the_dataset.shape}
''')


# finding the mean and standard deviation of each feature. the result will be a row where each column contains the mean or standard deviation of each column in the array



features_mean = the_dataset.mean(axis = 0)

features_std = the_dataset.std(axis = 0)

print(f'''
============================= Parameters =============================

Mean of each feature: {features_mean}

Shape: {features_mean.shape}

Standard Deviation of each feature: {features_std}

Shape: {features_std.shape}
''')

# now let's practice broadcasting
# we'll normalize the dataset by subracting the mean and dividing by the standard deviation

NM_dataset = (the_dataset - features_mean) / features_std


print(f'''
============================= Normalized Dataset =============================
      
{NM_dataset.round(2)}

New Mean: {NM_dataset.mean(axis = 0).round(2)}
''')



targets = np.random.randn(6, 4)


# the bias is a vector that is added to the target to shift the activation function left or right, enabling flexibility
bias_array = np.linspace(-0.11, 0.32, 4)


print(f'''
      
============================= Adding a Bias Vector =============================
      
============================= Target (Shape: {targets.shape}) =============================

{targets.round(2)}


============================= Biases (Shape: {bias_array.shape}) =============================

{bias_array}
''')

# let's broadcast...
# targets (6, 4) + bias_array (4,)
targets = targets + bias_array

print(f'''
============================= Final Output (targets + Biases) =============================

{targets.round(2)}
''')
























































np.random.seed(19)


# let's create a vector and a matrix...

matrix_A = np.random.randint(34, 77, size = (5, 4))

vector_B = np.linspace(34, 77, 5, dtype = np.int32)


print(f'''
Maxtix A [Shape: {matrix_A.shape}]:
{matrix_A}


Vector B [Shape: {vector_B.shape}]: {vector_B}
''')


# broadcasting the vector will fail
# (5, 4) + (5, ) = (5, 4) + (, 5)
# analyzing from right to left:
# 4 vs. 5  = INCOMPATIBLE!!
# this operation CANNOT be performed and will result to a ValueError

try:

    matrix_A + vector_B

except ValueError as e:

    print(f'I told you this would result to a ValueError: "{e}"')



# the solution to this is to make the vector "vector_B" a column vector using np.newaxis

col_vector_B = vector_B[:, np.newaxis]


print(f'''
Original vector_B:
{vector_B}

Original shape: {vector_B.shape}

New vector_B:
{col_vector_B}

New shape (using np.newaxis): {col_vector_B.shape}
''')


# let's try broadcasting again
# it should work this time...

# (5, 4) + (5, 1)

# analyzing from right to left:
# 4 vs. 1 = COMPATIBLE!! (Rule 2)
# 5 vs. 5 = COMPATIBLE!! (Rule 2)


try:
    print(f'''
    Result of matrix_A and new vector_B:
{matrix_A + col_vector_B}
    ''')

except ValueError as bummer:

    print(f"Damn! It was supposed to work. Try checking the error out:\n{bummer}")

































































np.random.seed(19)



matrix_A = np.random.randint(2, 19, size = (4, 4))

vector_B = np.linspace(2, 19, 4).round(0)

print(f'''
Original Matrix:
{matrix_A}

Shape: {matrix_A.shape}


Original Vector:
{vector_B}

Shape: {vector_B.shape}
''')


sv_eqn = np.linalg.solve(matrix_A, vector_B).round(2)

print(f"Solution to the equation: {sv_eqn}")


try:

    v_broadcast = matrix_A + vector_B

    print(f"\nResult of matrix and vector addition: {v_broadcast}") # Surprisingly, the addition worked, contrary to the assignment's claims

except ValueError as an_error:

    print(f"Oops! We have an error: {an_error}")


# since the addition worked, let's try modifiying matrix_A

matrix_A = np.random.randint(2, 19, size = (4, 5))

# the addition won't work this time...

try:

    v_broadcast = matrix_A + vector_B

    print(f"\nResult of matrix and vector addition: {v_broadcast}")

except ValueError as an_error:

    print(f'''
Oops! We have an error: {an_error}
    ''') # addition didn't work, so error statement was printed


# now let's use np.newaxis to solve the error

vector_B = vector_B[:, np.newaxis]


try:

    v_broadcast = matrix_A + vector_B

    print(f'''
Result of matrix and vector addition:
{v_broadcast}
    ''') # it worked!

except ValueError as an_error:

    print(f'''
Oops! We have an error: {an_error}
    ''')





























































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






















































































# Joining and Splitting Arrays
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












































































np.random.seed(19)

a_matrix = np.random.randint(9, 19, size = (4, 3))

transposed_matrix = a_matrix.T


print(f'''
============================= Original Matrix =============================
      
{a_matrix}


============================= Transposed Matrix =============================

{transposed_matrix}
''')


# we normally use transpose to make dot products work


b_matrix = a_matrix.copy()

dot_product = None

try:

    dot_product = np.dot(a_matrix, b_matrix) # here we use b_matrix normally

    print(f'''
Dot Product of Matrix A and B worked and we didn't need to transpose!
          
Result:
{dot_product}
    ''')

except Exception:

    dot_product = np.dot(a_matrix, b_matrix.T) # here we transpose b_matrix

    print(f'''
Dot Product of Matrix A and B didn't work and we needed to transpose!

Result:
{dot_product}
    ''')





























































































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


