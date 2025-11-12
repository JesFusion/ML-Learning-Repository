import numpy as np

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

