import numpy as np
np.random.seed(19)



matrix_A = np.random.randint(2, 19, size = (4, 4))

vector_B = np.linspace(2, 19, 4).round(0)

print(f'''
Original Matrix:
{matrix_A}

Shape: {matrix_A.shape}


Original Vector:
{vector_B}

Shape: {vector_B.shape}
''')


sv_eqn = np.linalg.solve(matrix_A, vector_B).round(2)

print(f"Solution to the equation: {sv_eqn}")


try:

    v_broadcast = matrix_A + vector_B

    print(f"\nResult of matrix and vector addition: {v_broadcast}") # Surprisingly, the addition worked, contrary to the assignment's claims

except ValueError as an_error:

    print(f"Oops! We have an error: {an_error}")


# since the addition worked, let's try modifiying matrix_A

matrix_A = np.random.randint(2, 19, size = (4, 5))

# the addition won't work this time...

try:

    v_broadcast = matrix_A + vector_B

    print(f"\nResult of matrix and vector addition: {v_broadcast}")

except ValueError as an_error:

    print(f'''
Oops! We have an error: {an_error}
    ''') # addition didn't work, so error statement was printed


# now let's use np.newaxis to solve the error

vector_B = vector_B[:, np.newaxis]


try:

    v_broadcast = matrix_A + vector_B

    print(f'''
Result of matrix and vector addition:
{v_broadcast}
    ''') # it worked!

except ValueError as an_error:

    print(f'''
Oops! We have an error: {an_error}
    ''')


