import numpy as np
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


