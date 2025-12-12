import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sklearn.datasets import load_iris
from jesse_custom_code.pandas_file import postgre_connect, PDataset_save_path as psp
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OrdinalEncoder, OneHotEncoder


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













































































# ===================================== Extracting Dataset =====================================

database_engine = create_engine(postgre_connect)

with database_engine.connect() as database_connection:

    user_credit_dataset = pd.read_sql(
        "SELECT age, credit_score FROM user_credit_logs",
        database_connection
    )



print(f'''
======================================== Extracted Dataset (Pre-Cleaning) ========================================
      
{user_credit_dataset.head().to_markdown()}
''')


# we'll use SimpleImputer to fill the missing values

'''
SimpleImputer is a class in sklearn that helps us fill missing values with the:

1. Mean: Good for normal data.

2. Median: Good for data with outliers (billionaires don't skew the median income, but they ruin the mean).

3. Mode (Most Frequent): Good for categorical data (fill missing color with "Red" if "Red" is most common).
'''


sk_imputer = SimpleImputer(missing_values = np.nan, strategy = "mean")

cleaned_array = sk_imputer.fit_transform(user_credit_dataset) # .fit_transform returns a Numpy array, not a DataFrame. It strips the column of it's headers before working on it

cleaned_dataset = pd.DataFrame(cleaned_array, columns = ["age", 'credit_score'])


print(f'''
======================================== Cleaned Dataset (Post-Imputation) ========================================
      
{cleaned_dataset.head().to_markdown()}
''')














































































cs_dataset = pd.read_sql(# cs = customer_surveys
    "SELECT satisfaction, country, loyalty_years FROM customer_surveys",

    create_engine(postgre_connect)
)
print(f'''
======================================== Extracted Raw Dataset (Strings) ========================================
      
{cs_dataset.head().to_markdown()}
''')

# ===================================== ORDINAL ENCODING =====================================

# oridinal encoding is used on ordinal data, which is data with order/rank, where values are sequentially greater than each other
# For example, in the "satisfaction" column, we have Low < Medium < High
# This column is perfect for performing ordinal encoding on


# .
cat_order = [["Low", "Medium", "High"]] # we must define the order manually

cs_ord_enc = OrdinalEncoder(categories = cat_order) # instantiang the OrdinalEncoder class/model and passing parameters


# We use "OrdinalEncoder" .fit_transform() method to learn the categories AND change the data at once
cs_dataset["enc_satisfaction"] = cs_ord_enc.fit_transform(cs_dataset[['satisfaction']]) # notice we used cs_dataset[['satisfaction']] and not cs_dataset['satisfaction']
# the .fit_transform() method expects a DataFrame, not a Series


print(f'''
======================================== After Ordinal Encoding (satisfaction) ========================================

{cs_dataset.head().to_markdown()}
''')


# ===================================== ONE-HOT ENCODING =====================================

'''
One-Hot encoding is used on Nominal data, which is data with no rank/order. It creates a new "switch" (column) for every option. e.g: "is_usa", "is_france"

We use Scikit-Learn's OneHotEncoder to perform One-Hot encoding:

- sparse_output = False: forces it to return a numpy array we can see (not a compressed matrix)

- handle_unknown = 'ignore': is CRITICAL for production. If a new country 'Belarus' appears later, the model won't crash; it will just produce all zeros.
'''

cs_oht_enc = OneHotEncoder(
    sparse_output = False,
    handle_unknown = "ignore"
)

enc_country_column = cs_oht_enc.fit_transform(cs_dataset[["country"]])

# OneHotEncoder returns a numpy array with no column names. To retrieve the column names, we use the .get_feature_names_out() method

con_ft_names = cs_oht_enc.get_feature_names_out(['country'])

# converting the numpy array and column names to a new DataFrame...
cy_dframe = pd.DataFrame(enc_country_column, columns = con_ft_names)

# join it back to the original DataFrame

oh_final_dset = pd.concat([cs_dataset, cy_dframe], axis = 1)

print(f'''
======================================== After One-Hot Encoding (country) ========================================
      
{oh_final_dset.head().to_markdown()}
''')


# let's drop the categorical columns and save our final processed dataset

# dropping categorical columns...
cs_dataset = oh_final_dset.drop(['satisfaction', 'country'], axis = 1)

save_path = f"{psp}customer_survey_dataset.parquet"

# saving as a parquet file...
# cs_dataset.to_parquet(save_path, index = False)

print("\nDataset saved as parquet file!\n")
print(save_path)








