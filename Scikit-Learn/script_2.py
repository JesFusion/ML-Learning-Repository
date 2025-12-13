import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from sklearn.datasets import load_iris
from jesse_custom_code.pandas_file import postgre_connect, PDataset_save_path as psp
from jesse_custom_code.build_database import PSQLDataGenerator
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


















































































# creating synthetic dataset

subscription_logs = PSQLDataGenerator(connection_string = postgre_connect)

subscription_logs.create_and_populate_table(
    primary_key = 'user_id',
    table_name = "subscription_logs",
    column_config = {
        "user_id": ["TEXT", "prefixed_id"],
        "plan_tier": ['TEXT', "rand_ch"],
        "region": ['TEXT', "rand_ch"],
        "monthly_usage_hrs": ["INTEGER", "rand_intg"],
        'support_calls': ["INTEGER", "rand_intg"]
    },

    groups = {
        "user_id": 'log',
        'plan_tier': ["Basic", "Premium", "Enterprise"],
        'region': ['North America', 'Europe', 'Asia'],
        'monthly_usage_hrs': [0, 500],
        'support_calls': [0, 10]
    },

    num_entries = 15992 # mimics real dataset size
)

print("\nTable Uploaded to Database!\n")


# ===================================== Extracting the Data =====================================
Slogs_dset = pd.read_sql(
    "SELECT * FROM subscription_logs LIMIT 9500",

    create_engine(postgre_connect)
)

print(f'''
======================================== Original Dataset ========================================
      
{Slogs_dset.head().to_markdown()}
''')

# injecting nan values into the monthly_usage_hrs column...
def custom_nan_insertion(usage_hrs):

    if (usage_hrs % 7) == 0:
        return np.nan
    
    else:
        return usage_hrs

Slogs_dset["monthly_usage_hrs"] = Slogs_dset['monthly_usage_hrs'].apply(custom_nan_insertion)

Slogs_dset.info(memory_usage = "deep") # we have 8079/9500 non-null under the monthly_usage_hrs column


# imputing data and joining back to original DataFrame...

Slogs_dset["monthly_usage_hrs"] = SimpleImputer(missing_values = np.nan, strategy = "mean").fit_transform(Slogs_dset[["monthly_usage_hrs"]]).flatten() # The .fit_transform() method of SimpleImputer enables it to create a numpy array that fills the missing values in the "monthly_usage_hrs" column of "Slogs_dset" with the mean (as we specified in the "strategy" attribute of SimpleImputer).
# Notice that we passed a DataFrame to the .fit_transform() method using double square brackets instead of a single one, which would have returned a Series (inserting a Series would throw an error).
# The .flatten() method converts the resulting array to a 1 Dimensional Array, which is what pd.Series expects


print(f'''
======================================== Dataset After Imputation ========================================
      
{Slogs_dset.head().to_markdown()}
''')

Slogs_dset.info(memory_usage = "deep")


# ===================================== performing Ordinal Encoding =====================================

Slogs_dset["plan_tier"] = OrdinalEncoder(categories = [['Basic', 'Premium', 'Enterprise']]).fit_transform(Slogs_dset[['plan_tier']]) # Just like SimpleImputer, OrdinalEncoder expects a DataFrame instead of a Series in it's .fit_transform() method, so we use double instead of single square brackets. The "categories" attribute in OridinalEncoder collects a list of lists (i'm not sure if i'm correct by identifying it as a "list of lists") that contains the order/rank of the Ordinal Data


print(f'''
======================================== Dataset After Performing Oridinal Encoding ========================================
      
{Slogs_dset.head().to_markdown()}
''')

# ===================================== performing One-Hot Encoding =====================================

region_OH_encode = OneHotEncoder(
    sparse_output = False,
    handle_unknown = "ignore"
)

reg_encode_data = region_OH_encode.fit_transform(Slogs_dset[["region"]])

Slogs_dset = pd.concat([
    Slogs_dset,

    pd.DataFrame(
        data = reg_encode_data,

        columns = region_OH_encode.get_feature_names_out(["region"]),
    )
],
    axis = 1
).drop(["region", "user_id"], axis = 1)


print(f'''
======================================== Final Dataset After Pre-Processing ========================================
      
{Slogs_dset.head().to_markdown()}
''')


# saving pre-processed dataset as parquet file for training later...
# Slogs_dset.to_parquet(f"{PDataset_save_path}subscription_logs_dataset.parquet", index = False)
print("\nPre-Processed Dataset Saved as parquet file!")













