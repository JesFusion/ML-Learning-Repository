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






