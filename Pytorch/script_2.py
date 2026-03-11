import torch
import numpy as np
import logging


# ===================================== Performing logging operations =====================================

path_to_file = "logs/print.log"


pytorch_logger = logging.getLogger(name = 'PyTorch Learning')

pytorch_logger.setLevel(level = logging.DEBUG)

terminal = logging.StreamHandler()

terminal.setLevel(
    level = logging.INFO
)

terminal.setFormatter(
    fmt = logging.Formatter(
        fmt = "%(message)s"
    )
)


file = logging.FileHandler(
    filename = path_to_file,
    mode = 'w'
)

file.setLevel(
    level = logging.DEBUG
)

file.setFormatter(
    fmt = logging.Formatter(
        fmt = "{asctime} ::: {name} ::: {levelname} ::: [{filename}: line {lineno}]\n{message}\n\n",

        datefmt = "%Y/%m/%d, %I:%M %p",

        style = '{' # options are '%', '$' or '{' (check things to note)
    )
)

# adding the two handlers to our logger...

handlers = [terminal, file]

for handler in range(len(handlers)):

    pytorch_logger.addHandler(hdlr = handlers[handler])



def print(item):

    return pytorch_logger.info(item)



# ===================================== SEGMENT 1.1: TENSORS vs. NUMPY ARRAYS (DEVICE MANAGEMENT) =====================================

device_to_use = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


pytorch_logger.debug(device_to_use)


# creating a numpy array. An array only lives in the CPU

the_numpy_array = np.array([1.1, -0.3, 4.5, 0.009], dtype = np.int16)

pytorch_logger.debug(f'''
NumPy Array: {the_numpy_array}

Array Type: {type(the_numpy_array)}
''')



# torch.tensor() is the primary way to create a tensor from known data.
# A Rank-0 tensor holds a SINGLE number, like a loss value at end of training.

rank_0_tensor = torch.tensor(data = 1.1)
# .ndim tells us the rank. Shape should be empty (0 dimensions)

pytorch_logger.debug(f'''
Scalar...

Rank-0 Scalar: {rank_0_tensor}

Scalar .ndim: {rank_0_tensor.ndim}

Scalar .shape: {rank_0_tensor.shape}
''')


# RANK-1 TENSOR: a 1D list of numbers

rank_1_tensor = torch.tensor(data = [1.2, 3.4, 5.0, 0.1, -0.012029])

pytorch_logger.debug(f'''
Vector...
      
Rank-1 Vector: {rank_1_tensor}

Vector .ndim: {rank_1_tensor.ndim}

Vector .shape: {rank_1_tensor.shape}
''')


euclidean_magnitude = torch.norm(input = rank_1_tensor)

pytorch_logger.debug(f"Euclidean Magnitude of Rank-1 Tensor: {rank_1_tensor} is {euclidean_magnitude:.4f}")




# RANK-2 TENSOR: a 2D grid

rank_2_tensor = torch.tensor(
    data = [
        [1.0, 2.1, 3.2],
        [2, 1.1, -0.84]
    ]
)



pytorch_logger.debug(f'''
Matrix...
      
Rank-2 Matrix: {rank_2_tensor}

Matrix .ndim: {rank_2_tensor.ndim}

Matrix .shape: {rank_2_tensor.shape}
''')



# DEVICE MANAGEMENT: Sending the Tensor to GPU

moved_tensor = rank_2_tensor.to(device = device_to_use)

pytorch_logger.debug(f'''
Moving Tensor to another device...

Matrix on {device_to_use}: {moved_tensor}

Tensor .device: {moved_tensor.device}
''')


# Converting from NumPy to Pytorch and vice versa...

numpy_to_tensor = torch.from_numpy(the_numpy_array)

tensor_to_numpy = rank_2_tensor.numpy()


pytorch_logger.debug(f'''
Converting from NumPy to Pytorch...
      
Tensor to NumPy: {tensor_to_numpy}

NumPy to Tensor: {numpy_to_tensor}
''')



# Configures the root logger, establishing the baseline behavior for how all subsequent log messages will be structured and filtered.
logging.basicConfig(
    # Sets the string format for log outputs: starts with a newline, displays the executing line number (%(lineno)s), and then the actual message.
    format = '\nNo %(lineno)s => %(message)s',
    # Sets the minimum logging threshold to INFO, ensuring that all info-level messages (and anything more severe) are printed to the console.
    level = logging.INFO
# Closes the basicConfig function call.
)


# ===================================== SEGMENT 1.2: TENSOR CONSTRUCTION & TYPES =====================================


# Initializes a new tensor named 't_float32' where every element is pre-filled with the exact value of 1.
t_float32 = torch.ones(
    # Defines the dimensions of the tensor as a 2D matrix consisting of 4 rows and 2 columns.
    size = (4, 2),
    # Explicitly assigns the 32-bit floating-point data type to the tensor, which is PyTorch's default float type.
    dtype = torch.float32
# Closes the torch.ones function call.
)

# Calls the element_size() method to retrieve the memory consumption (in bytes) of a single element in this float32 tensor (which is 4 bytes).
element_mem = t_float32.element_size()

# Calls the nelement() method to calculate the total count of individual scalar numbers inside the tensor (4 rows * 2 columns = 8 elements).
num_elements = t_float32.nelement()

# Multiplies the byte size of a single element by the total number of elements to calculate the complete memory footprint of the tensor.
mem_float32 = element_mem * num_elements



# Starts a multi-line formatted logging statement (using an f-string) to visually present the tensor and its memory profile.
logging.info(f"""Tensor:
{t_float32}

Memory per element: {element_mem}

Total number of elements: {num_elements}

Total memory of float32 Matrix: {mem_float32}""")






# Initializes another tensor, 't_float16', filling it with random numbers sampled from a standard normal distribution (mean 0, variance 1).
t_float16 = torch.randn(
    # Sets the shape of this random tensor to have 6 rows and 3 columns.
    size = (6, 3),
    # Explicitly assigns a 16-bit floating-point data type (half precision), which uses less memory than float32 but has lower numerical precision.
    dtype = torch.float16
# Closes the torch.randn function call.
)




# Reassigns the 'element_mem' variable to the byte size of a single float16 element (which takes up 2 bytes).
element_mem = t_float16.element_size()

# Reassigns the 'num_elements' variable to the total count of items in this new 6x3 tensor (6 * 3 = 18 elements).
num_elements = t_float16.nelement()

# Calculates the total memory of the float16 tensor by multiplying its specific element size by its total elements.
mem_float16 = element_mem * num_elements



# Starts another multi-line logging statement to display the properties of the randomly generated float16 tensor.
logging.info(f"""Tensor:
{t_float16}

Memory per element: {element_mem}

Total number of elements: {num_elements}

Total memory of float32 Matrix: {mem_float16}""")






# Creates a 1D tensor (a vector) named 't_int64' by directly converting a standard Python list of integers.
t_int64 = torch.tensor(
    # Provides the raw Python list [1, 2, 3, 4, 5] that will be transformed into PyTorch's underlying C++ tensor structure.
    data = [1, 2, 3, 4, 5],
    # Explicitly forces these integers to be stored as 64-bit integers (Long type), useful for tasks like array indexing or classification labels.
    dtype = torch.int64
# Closes the torch.tensor function call.
)


# Logs the newly created integer tensor alongside its associated data type to verify correct construction.
logging.info(f"""Int64 Labels: {t_int64}

Int64 dtype: {t_int64.dtype}""")



# let's see how data types can save memory...

# Defines a tuple representing the shape of a much larger matrix (2000 rows by 2000 columns) to simulate a heavier, realistic memory workload.
matrix_size = (2000, 2000)



# Creates a standard Python list containing three distinct PyTorch floating-point data types (16-bit, 32-bit, and 64-bit) to loop through and compare.
dtypes = [torch.float16, torch.float32, torch.float64]


# Initiates a for-loop that will iterate over the sequence of numerical indices generated by the length of the 'dtypes' list.
for x in range(len(dtypes)):

    # Generates a new tensor filled with random numbers from a uniform distribution [0, 1) during the current loop iteration.
    tensor = torch.rand(
        # Applies the large 2000x2000 dimension previously defined to ensure the memory footprint is substantial enough to compare meaningfully.
        size = matrix_size,
        # Assigns the specific data type corresponding to the current loop index (e.g., float16 on the first pass, float32 on the next).
        dtype = dtypes[x]
    # Closes the torch.rand function call.
    )

    # Calculates the total memory of this large matrix in bytes by retrieving the element size of the generated tensor and multiplying by its element count.
    mat_mem = tensor.element_size() * tensor.nelement()


    # Logs the calculated memory for the current data type, converting the raw bytes to Megabytes (dividing by 1024 squared) and formatting it to 2 decimal places.
    logging.info(f"Total memory of {dtypes[x]} Matrix: {(mat_mem / (1024**2)):.2f}MB")



# Random initialization...


# Generates a new tensor filled with random values drawn from a uniform continuous distribution within the interval [0, 1).
random_uniform_tensor = torch.rand(
    # Sets the structural shape of the tensor to 4 rows and 3 columns.
    size = (4, 3),
    # Sets the data type to 16-bit floating point.
    dtype = torch.float16
# Closes the torch.rand function call.
)


# Generates another tensor, this time filled with random values drawn from a standard normal distribution (Gaussian, with mean 0 and variance 1).
random_normal_tensor = torch.randn(
    # Sets the structural shape to a 3x3 square matrix.
    size = (3, 3),
    # Sets the data type to 64-bit floating point (double precision), maximizing numerical accuracy at the cost of higher memory usage.
    dtype = torch.float64
# Closes the torch.randn function call.
)


# Logs both the uniform and normal distribution tensors to allow visual comparison of how the two different random initialization algorithms populate values.
logging.info(f"""Random Uniform Distribution: {random_uniform_tensor}

Random Normal Distribution: {random_normal_tensor}""")




# type casting...

# Initializes a new integer tensor by manually passing a hardcoded Python list of integers.
tensorAsInteger = torch.tensor(
    # Provides the raw data points [4, 6, 7, 11] to form a simple 1D vector.
    data = [4, 6, 7, 11],
    # Explicitly sets the internal storage format to 64-bit integer.
    dtype = torch.int64
# Closes the torch.tensor function call.
)

# Uses the built-in '.to()' method to perform type casting, creating a brand new copy of 'tensorAsInteger' where the underlying data is converted to 64-bit floats.
tensorAsFloat = tensorAsInteger.to(dtype = torch.float64)

# Logs a comparison showing the exact state of the tensor data before and after the type casting operation.
logging.info(f"""Before casting:
{tensorAsInteger}

dtype = {tensorAsInteger.dtype}

After casting:
{tensorAsFloat}

dtype = {tensorAsFloat.dtype}
""")












# ===================================== SEGMENT 1.3: TENSOR MATH & LINEAR ALGEBRA =====================================


# Creates a 2D tensor specifically constructed to act as the first matrix ('A') in an upcoming linear algebra matrix multiplication.
matrix_A = torch.tensor(
    # Defines the nested list structure: an outer list containing two inner lists, establishing a matrix with 2 rows.
    data = [
        # shape = (2, 3)
        # Defines the first row containing exactly 3 columns of floating-point numbers.
        [1.0, 2.0, 3.0],
        # Defines the second row, also with 3 columns, completing the 2x3 rectangular matrix structure.
        [4.0, 5.0, 6.0]
    # Closes the primary data list structure.
    ],

    # Sets the data type to float16 to conserve memory during these standard mathematical calculations.
    dtype = torch.float16
# Closes the torch.tensor initialization for Matrix A.
)

# Creates a second 2D tensor, 'Matrix B', structurally compatible to be multiplied by Matrix A (because its row count matches A's column count).
matrix_B = torch.tensor(
    # Defines the nested list structure for a 3x2 matrix.
    data = [
        # shape = (3, 2)
        # Defines the first row with 2 columns.
        [7.0,  8.0],
        # Defines the second row with 2 columns.
        [9.0,  10.0],
        # Defines the third row with 2 columns, perfectly matching the 3 columns of Matrix A to satisfy multiplication rules.
        [11.0, 12.0]
    # Closes the primary data list structure.
    ],

    # Sets the data type to float16 to safely match Matrix A, ensuring strict computational compatibility.
    dtype = torch.float16
# Closes the torch.tensor initialization for Matrix B.
)


# Logs the structural shapes of both matrices to verify their exact dimensions before attempting multiplication.
logging.info(f"""Shape of Matrix A: {matrix_A.shape}

Shape of Matrix B: {matrix_B.shape}
""")

# Executes a formal matrix multiplication (dot product of rows to columns) between matrix_A and matrix_B using PyTorch's explicit built-in function.
matrix_C = torch.matmul(
    # Provides Matrix A as the left-hand operator.
    input = matrix_A,
    # Provides Matrix B as the right-hand operator.
    other = matrix_B
# Closes the torch.matmul function call.
)

# Executes the exact same matrix multiplication but instead uses the '@' operator, which is Python's highly readable syntactic sugar for calling torch.matmul().
matrix_C_shortcut = matrix_A @ matrix_B


# confirm that matrix_C = matrix_C_shortcut

# Uses the torch.equal() function to perform a strict element-by-element comparison to ensure both multiplication methods yielded completely identical matrices.
confirmation = torch.equal(
    # The result outputted from the explicit torch.matmul call.
    input = matrix_C,
    # The result outputted from the '@' shortcut operator.
    other = matrix_C_shortcut
# Closes the torch.equal function call.
)


# Logs the final output of the matrix multiplication alongside the boolean confirmation of the shortcut equivalence.
logging.info(f"""Matrix multiplication of Matrix A & B:
{matrix_C}

shape = {matrix_C.shape}

Is matrix_C = matrix_C_shortcut? {confirmation}
""")




# dot product


# Initializes a 1D vector named 'dot_1' specifically to be used in a pure vector dot product calculation.
dot_1 = torch.tensor(
    # Provides three arbitrary float values representing the spatial coordinates of the first vector.
    data=[-2.40, 4.03, 3.0],
    # Explicitly types the vector as a standard 32-bit float.
    dtype=torch.float32
# Closes the tensor initialization for dot_1.
)

# Initializes a second 1D vector named 'dot_2' ensuring it has the exact same length (3 items) as dot_1 to allow for a mathematically valid dot product.
dot_2 = torch.tensor(
    # Provides three float values representing the coordinates of the second vector.
    data=[4.0, -0.012, 1.007],
    # Explicitly types the vector as a 32-bit float, fully matching dot_1.
    dtype=torch.float32
# Closes the tensor initialization for dot_2.
)



# Calculates the mathematical dot product of the two 1D tensors (sum of their corresponding element-wise products), returning a single scalar tensor.
dot_product = torch.dot(dot_1, dot_2)


# Logs the final computed scalar dot product, explicitly formatting the output string to display exactly 3 decimal places for clean readability.
logging.info(f"Dot product of dot_1 & dot_2: {dot_product:.3f}")




# element-wise operations...



# Initializes a standard 2x2 square matrix named 'tensor_1' to serve as the base for demonstrating element-by-element arithmetic.
tensor_1 = torch.tensor(
    # Defines the rows and columns with basic incremental float values.
    data=[
        # First row.
        [1.0, 2.0],
        # Second row.
        [3.0, 4.0]
    # Closes the internal data list.
    ],

    # Casts the tensor to 32-bit floating point.
    dtype=torch.float32
# Closes the tensor initialization for tensor_1.
)


# Initializes another 2x2 square matrix named 'tensor_2', structurally shaped identically to tensor_1 so they can be smoothly operated on element-wise.
tensor_2 = torch.tensor(
    # Defines the rows and columns using larger multiples of 10 for contrast.
    data=[
        # First row.
        [10.0, 20.0],
        # Second row.
        [30.0, 40.0]
        # Closes the internal data list.
        ],

    # Casts the tensor to 32-bit floating point.
    dtype=torch.float32
# Closes the tensor initialization for tensor_2.
)



# Performs true element-wise addition, where each individual number in tensor_1 is added directly to the number at the exact same coordinate position in tensor_2.
add_elements = tensor_1 + tensor_2

# Performs element-wise multiplication (Hadamard product), which strictly multiplies matching coordinates (unlike row-to-column matrix multiplication).
multiply_elements = tensor_1 * tensor_2

# Performs element-wise division, dividing the values in tensor_1 directly by the values in the corresponding positions of tensor_2.
divide_elements = tensor_1 / tensor_2



# Logs the resulting outputs of all three computed element-wise operations.
logging.info(f"""Element-Wise Addition: {add_elements}

Element-Wise Multiplication: {multiply_elements}

Element-Wise Division: {divide_elements}""")



# What happens with incompatible matmul shapes?


# Begins a Python try-except exception handling block to gracefully catch and inspect an anticipated mathematical error without crashing the script.
try:

    # Purposely attempts to perform matrix multiplication on two tensors known to have mathematically incompatible dimensions.
    torch.matmul(
        # Left operand: tensor_1 is a 2x2 matrix.
        input = tensor_1,

        # Right operand: t_float32 is a 4x2 matrix. A 2x2 matrix cannot be matrix-multiplied with a 4x2 matrix because inner dimensions (2 and 4) do not match.
        other = t_float32
    # Closes the torch.matmul function call (note: execution will instantly jump to the except block here).
    )

# Catches the specific 'RuntimeError' that PyTorch actively throws when core tensor operations fail, storing the detailed error string in the 'error' variable.
except RuntimeError as error:

    # Logs a custom readable error header right alongside the exact exception message provided by PyTorch, demonstrating how to handle dimension mismatches effectively.
    logging.info(f""""Shape Mismatch Error!
{error}
""")









