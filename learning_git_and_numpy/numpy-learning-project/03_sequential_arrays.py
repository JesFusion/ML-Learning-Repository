import numpy as np



print(f'''
============================= np.arange() (stop) =============================
      
{np.arange(11)}


============================= np.arange(6, 17) (start, stop) =============================

{np.arange(6, 17)}


============================= np.arange() (start, stop, step) =============================

{np.arange(0, 11, 2)}


============================= using floats =============================

{np.arange(11.2, 34.6, 2.2)}



============================= using np.linspace() =============================

np.linspace() includes the stop value, unlike np.arange()

============================= np.linspace() (start, stop, no. of points) =============================

4 evenly spaced values between 1 and 37
{np.linspace(1, 37, 4)}


27 evenly spaced values between 2 and 100
{np.linspace(2, 100, 27).round(2)}
''')



PI = np.pi

x_axis = np.linspace(0, 2 * PI, 121)




print(f'''

============================= Plotting sine waves using linspace =============================
      
121 values for a sine wave (showing first 27)
{x_axis[:27]}


============================= Excluding the endpoint of a linear space =============================

{np.linspace(2, 45, 7, endpoint = False)}
''')