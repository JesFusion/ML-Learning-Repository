import numpy as np

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