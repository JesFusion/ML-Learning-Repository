import numpy as np
np.random.seed(19)



# The following code demonstrates the broadcasting rules

'''
There are 3 simple rules in Broadcasting. NumPy compares the shapes of your two arrays (e.g., A and B) from right to left.

--> Rule 1:
    Align shapes from the right.

    A: (4, 3, 2)

    B: ( , 3, 2) (If B's shape is (3, 2))

    A: (4, 3, 2)

    B: ( , 2) (If B's shape is (2,))

--> Rule 2:
    Check if dimensions are compatible.

    Starting from the right, each pair of dimensions must be compatible. A pair is "compatible" if:

    The dimensions are equal (e.g., 2 vs 2), OR

    One of the dimensions is 1.

--> Rule 3:
    "Stretch" (broadcast) the dimension of size 1.

    If a pair is compatible because one of them is 1, NumPy "stretches" that 1 to match the other dimension.
'''

array_1 = np.ones(shape = (3, 3))
v_a = np.array([4.5])

# 3 x 3 vs. 1 x 1 (remember that Numpy replaces empty dimensions with 1)

# The result will be a SUCCESS because of the "1" (Rule 2)

print(f'''
Result of {array_1.shape} + {v_a.shape}:

{array_1 + v_a}
''')


array_2 = np.random.randint(3, 11, size = (3, 3))

array_3 = np.random.randn(3, 1).round(2)

# validating from right to left:
# 3 vs. 1 --> Compatible (Rule 2)
# 3 vs. 3 --> Compatible (Rule 2)
# array_3 will be strected to become a (3, 3) array

print(f'''
Result of {array_2.shape} + {array_3.shape}:

{array_3 + array_2}
''')


array_4 = np.random.rand(3)
array_5 = np.random.randint(14, 23, size = (3, 3))

# (3 x 3)  vs. (3, )
# Numpy automatically converts (3, ) to (, 3) when broadcasting

# (3 x 3)  vs. ( , 3)
# validating from right to left:
# 3 vs. 3 --> Compatible (Rule 2)
# 3 vs. 1 --> Compatible (Rule 2)

# the (1, 3) array will be stretched to a (3, 3) and used for operations

print(f'''
Result of {array_4.shape} + {array_5.shape}:

{(array_4 + array_5).round(2)}
''')



array_6 = np.random.rand(3, 4)
array_7 = np.random.randn(3)

# (3 x 4)  vs. (3, )
# Numpy automatically converts (3, ) to (, 3) when broadcasting

# (3 x 4)  vs. ( , 3)
# validating from right to left:
# 4 vs. 3 --> INCOMPATIBLE! (Rule 2)
# 3 vs. 3 --> Compatible (Rule 2)

# Performing an operation on these two will result in a ValueError!

try:
    print(f'''
    Result of {array_6.shape} + {array_7.shape}:

    {array_6 + array_7}
    ''')

except ValueError:

    print("Like I said, this would result to a ValueError")


