import numpy as np


np.random.seed(19)


print(f'''
============================= 4 x 5 Uniform array (between 0.0 & 1.0) =============================
      
{np.random.rand(4, 5)}


============================= 2 x 4 Normal Array (Bell Curve) =============================

{np.random.randn(2, 4)}

Mean of the array sould be close to zero: {np.random.randn(2, 4).mean().round(3)}


============================= 6 x 3 Integer Array =============================

{np.random.randint(14, 59, size = (6, 3))}




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