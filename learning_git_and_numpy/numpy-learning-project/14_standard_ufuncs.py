import numpy as np

a_array = np.linspace(-10, 11, 20).round(2)

print(f'''
============================= Original Array =============================
      
{a_array}


============================= Abslute Value of a_array =============================

{np.abs(a_array)}


============================= Square Root of a_array =============================

{np.sqrt(a_array)}
''')
# Notice that numpy places nan where the element was a negative number

# let's make everything positive by using the absolut function

print(f'''
============================= Square Root of Absolute a_array =============================

{np.sqrt(np.abs(a_array)).round(2)}
''')


# ============================= let's practice on Exponential and Logarithm Universal Functions (UFuncs) =============================


b_array = np.linspace(1, 9, 23).round(2)

print(f'''
============================= Original Array =============================

{b_array}
''')

# np.exp() for finding the exponential of each element; very useful for an Ml engineer. It is also used in the "softmax" activation function

print(f'''
============================= Exponential of b_array =============================

{np.exp(b_array).round(2)}
''')

# np.log() is used in "log loss"/cross-entropy

print(f'''
============================= Natural Log of b_array =============================

{np.log(b_array).round(2)}
''')

# let's check if we'll get back the array by finding the logarithm of it's exponential

print(f'''
============================= Logarithm of Exponential of b_array =============================

{np.log(np.exp(b_array))}
''') # check out that it worked!



# ============================= How to Round UFuncs =============================

c_array = np.linspace(10, 13, 27)

print(f'''
============================= Original Array =============================

{c_array}
''')

# np.floor() rounds down
# e.g:
# np.floor(4.1) = 4
# np.floor(3.7) = 3

print(f'''
============================= Foor of c_array =============================
      
{np.floor(c_array)}
''')


# np.ceil() rounds up
# e.g:
# np.floor(4.1) = 5
# np.floor(3.7) = 4

print(f'''
============================= Ceiling of c_array =============================
      
{np.ceil(c_array)}
''')

# np.round() rounds normally

print(f'''
============================= Round of c_array =============================

{np.round(c_array)}


============================= Rounding to 2 decimal places =============================

{np.round(c_array, 2)}
''')

