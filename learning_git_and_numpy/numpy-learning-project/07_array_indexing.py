import numpy as np

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
