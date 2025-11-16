import numpy as np
import pandas as pd
from jesse_custom_code.pandas_file import database_path as d_path
from sqlalchemy import create_engine
np.random.seed(19)
np.set_printoptions(suppress = True)


# extracting our dataset from an SQL database with sqlalchemy...

the_engine = create_engine(f"sqlite:///{d_path}")


# the features we'll be making use of for this practice is the Age, Salary and Children features

the_dataset = pd.read_sql(
    '''
    SELECT Age, Salary, Children
    FROM Employees
    LIMIT 967
    ''',

    the_engine
)


print(f'''
============================= Original Dataset =============================

{the_dataset.head().to_markdown()}
''')


# converting the dataframe to a numpy array for processing 

the_dataset = the_dataset.to_numpy()


print(f'''
============================= DataFrame converted to Numpy array =============================

{the_dataset[:6]}

Shape: {the_dataset.shape}
''')

# let's broadcast the "age" column by adding a scalar

the_dataset[:, 2] = the_dataset[:, 2] + 1901.34


print(f'''
============================= Numpy array after Broadcasting the 3rd column =============================

{the_dataset[:6]}

Shape: {the_dataset.shape}
''')


# finding the mean and standard deviation of each feature. the result will be a row where each column contains the mean or standard deviation of each column in the array



features_mean = the_dataset.mean(axis = 0)

features_std = the_dataset.std(axis = 0)

print(f'''
============================= Parameters =============================

Mean of each feature: {features_mean}

Shape: {features_mean.shape}

Standard Deviation of each feature: {features_std}

Shape: {features_std.shape}
''')

# now let's practice broadcasting
# we'll normalize the dataset by subracting the mean and dividing by the standard deviation

NM_dataset = (the_dataset - features_mean) / features_std


print(f'''
============================= Normalized Dataset =============================
      
{NM_dataset.round(2)}

New Mean: {NM_dataset.mean(axis = 0).round(2)}
''')

# let's create fake data for targets...
# we'll use a random normal distribution creator to create the data

targets = np.random.randn(6, 4)


# the bias is a vector that is added to the target to shift the activation function left or right, enabling flexibility
bias_array = np.linspace(-0.11, 0.32, 4)


print(f'''
      
============================= Adding a Bias Vector =============================
      
============================= Target (Shape: {targets.shape}) =============================

{targets.round(2)}


============================= Biases (Shape: {bias_array.shape}) =============================

{bias_array}
''')

# let's broadcast...
# targets (6, 4) + bias_array (4,)
targets = targets + bias_array

print(f'''
============================= Final Output (targets + Biases) =============================

{targets.round(2)}
''')