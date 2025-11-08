import numpy as np

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