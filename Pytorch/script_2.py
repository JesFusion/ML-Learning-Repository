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












