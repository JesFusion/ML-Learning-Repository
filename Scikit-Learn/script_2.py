import pandas as pd
from sqlalchemy import create_engine
from sklearn.datasets import load_iris
from jesse_custom_code.pandas_file import postgre_connect


# ===================================== Sourcing Data =====================================

iris_dset = load_iris()

print(f'''
======================================== iris .data (Features) ========================================

{iris_dset.data[:2]}


======================================== iris .target (Labels) ========================================

{iris_dset.target[:2]}


======================================== iris .feature_names (The Metadata (The Context)) ========================================

{iris_dset.feature_names}

Feature Size: {iris_dset.data.shape}
''')


iris_dataset = pd.DataFrame(data = iris_dset.data, columns = iris_dset.feature_names)

iris_dataset['target'] = iris_dset.target

iris_name = {
    0: "setosa",
    1: "versicolor",
    2: "virginica"
}

iris_dataset["iris_species_name"] = iris_dataset["target"].map(iris_name)

print(f'''
======================================== Data Extracted! Shape: ({iris_dataset.shape}) ========================================

{iris_dataset.sample(6).to_markdown()}
''')



# ===================================== Ingesting Data to PostgreSQL DataBase =====================================


database_engine = create_engine(postgre_connect)

iris_dataset.to_sql(
    name = "Scikit-Learn Iris",

    con = database_engine,

    if_exists = "replace",

    index = False,
)

print("\nDatabase Uploaded successfully!\n")



# ===================================== Extracting Data for Modeling =====================================

the_dataset = pd.read_sql(
    'SELECT * FROM "Scikit-Learn Iris"',

    database_engine
)

# viewing the dataset...

print(f'''
======================================== Extracted Dataset ========================================
      
{the_dataset.head().to_markdown()}
''')






















































































d_engine = create_engine(postgre_connect)

the_dataset = pd.read_sql(
    "SELECT * FROM car_prices_raw",

    d_engine
)

print(f'''
======================================== Extracted Dataset ========================================
      
{the_dataset.head().to_markdown()}
''')

# ===================================== Defining Concepts in Scikit-Learn and Data Science in General =====================================

# Target/Labels (y): This is what we want to predict (usually a single pandas Series/Column)

target_y = the_dataset["Price"]

print(f'''
======================================== Target (y), Shape: {target_y.shape} ========================================

{target_y.head().to_markdown()}

It is a Vector (ID)
''')

# Features (X): this is what the model tries to learn in order to see it's pattern with the targets

feature_x = the_dataset.drop(["Price"], axis = 1)

print(f'''
======================================== Features (X), Shape: {feature_x.shape} ========================================

{feature_x.head().to_markdown()}

It is a Matrix (2D)
''')

"""
WHY PREPROCESSING?

If we were to run this line below, Scikit-learn would CRASH:
```model.fit(feature_x, target_y)

WHY THIS WOULD FAIL:

1. Look at 'Fuel_Type': It contains strings like 'Electric'.

You cannot do: 'Electric' * 0.5 + 2. The math explodes.

Solution: We need Encoding

2. Look at 'Odometer_KM' vs 'Age_Years':
Max Odometer: {feature_x['Odometer_KM'].max()}
Max Age: {feature_x['Age_Years'].max()}

The model will think Odometer is 25,000x more important than Age just because the number is bigger.
Solution: We need Scaling
"""








