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

# This is a new comment added directly on GitHub because Jesse is cool

print("\nJesse is cool!")
