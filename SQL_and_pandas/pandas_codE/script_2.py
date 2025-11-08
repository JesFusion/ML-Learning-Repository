import pandas as pd
import io
import numpy as np
from jesse_custom_code.pandas_file import random_missing_fill as rmf
import sqlite3
import time
from jesse_custom_code.pandas_file import database_path as d_path


a_series = pd.Series([-1, 3, 3.4, "erre", True, None, 6, 0])


print(f"Simple Series --> \n{a_series}")


series_with_label = pd.Series([1, 2, 4], index = ["Jesse", "Favour", "Goodness"])

print(F"\nSeries with labels --> \n{series_with_label}\n")

dict_ = {

    "12": "Jesse",

    "13": "Kelly",

    "14": "Nelly"
}


the_dict = pd.Series(dict_)

print(
    f"{the_dict} --> {len(the_dict)}"
)



data__ = {
    "Name": ["Jesse", "F", "G", "LF"],

    "ID": [2983910, 392838984, 389292849, 92392823],

    "L.G": ["Isu", "Nsukka", "Ohafia", "Isuzor"]
}


dataset_ = pd.DataFrame(data__)

print(f"\n{dataset_}\n")





























initial_inventory_data = {
    "Product Name": ["Apple", "Banana", "Milk"],

    "Product Category": ["Fruit", "Fruit", "Dairy"],
    
    "Price per item": [0.50, 0.25, 2.99],

    "Quantity in Stock": [150, 200, 80]

}

initial_inventory = pd.DataFrame(initial_inventory_data)

new_shipment = {
    'Product Name': ['Banana', 'Apple', 'Orange', 'Bread'],
    'Quantity Received': [100, 50, 120, 60]
}

new_shipment_table = pd.DataFrame(new_shipment)


supplier_information = """Product Name,Supplier,Cost Price
Apple,FreshFarms,0.30
Banana,TropicCo,0.15
Milk,HappyCow,2.10
Bread,BakeWell,1.50"""


supplier_information = io.StringIO(supplier_information)

supplier_information_table = pd.read_csv(supplier_information)



print(f"\nInitial Inventory:\n{initial_inventory}\n\nNew Shipment Log:\n{new_shipment_table}\n\nSupplier Information:\n{supplier_information_table}")































d_ = {
    'EmployeeID': [101, 102, 103, 104, 105, 106, np.nan],
    'Name': [np.nan, 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace'],
    'Department': ['HR', 'Engineering', "Management", 'Marketing', 'HR', 'Engineering', 'Marketing'],
    'Salary': [70000, 80000, 95000, 65000, np.nan, 120000, 68000],
    'YearsWithCompany': [5, 3, 7, 11, 4, 9, 3]
}


practice_dataset = pd.DataFrame(d_)


print("============================= original dataset =============================")


print(practice_dataset)


print("============================= .head() =============================")

print(practice_dataset.head())


print("============================= .tail() =============================")


print(practice_dataset.tail())

print("============================= .sample() =============================")

print(practice_dataset.sample(n = 3))



print("============================= .info() =============================")

practice_dataset.info()




print("============================= .describe() =============================")


print("\n", practice_dataset.describe())




print("============================= .shape =============================")


print("\n", practice_dataset.shape)



print("============================= .dtypes =============================")



print("\n", practice_dataset.dtypes)































the_data = """# Sales data for the week
# Data extracted on 2025-10-16
transaction_id;dates;item_code;quantity;unit_price
tx-001;15-10-2025;A101;5;10.50
tx-002;15-10-2025;B204;2;25.00
tx-003;16-10-2025;A101;--;10.50
tx-004;16-10-2025;C300;1;150.75
"""



print("============================= reading without modifying dataset =============================\n")



try:

    dataset_without_modifying = pd.read_csv(io.StringIO(the_data))

    print(dataset_without_modifying)

except Exception as an_err:

    print(F"Yo! We've got an error --> {an_err}")


print("\n============================= reading with modifying datset =============================\n")



dataset_with_modifying = pd.read_csv(
    io.StringIO(the_data),

    sep = ";",

    header = 2,

    index_col = "transaction_id",

    parse_dates = ["dates"],

    na_values = ["--"]
)



print("\n", dataset_with_modifying)

print("\n\n============================= .info() of the modified dataset =============================")

dataset_with_modifying.info()

































practice_data = pd.read_csv(r"C:\Users\USER\Documents\My Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\data_sets\pulse_and_calorie_data.csv", parse_dates = ["Date"])



practice_data = practice_data.set_index("Name")


print(f"\n============================= DataFrame with \"Name\" as index =============================\n\n{practice_data.head(5)}")



print("\n============================= selecting a single column (Maxpulse) =============================\n")

print(practice_data["Maxpulse"].head(4))


print("\n============================= Selecting multiple columns =============================\n")


print(practice_data[["Date", "Calories"]].head(5))




print("\n============================= selecting a single row with .loc() =============================\n")



print(practice_data.loc["MZGZBI"])


print("\n============================= using .loc() to select a slice of rows =============================\n")


print(practice_data.loc["PJWKCC":"AJLVHZ"])





print("\n============================= using .loc() to select a single cell, using index (row selector) and column name (column selector) =============================\n")


print(f"ECIPJK's Maxpulse is {practice_data.loc['ECIPJK', 'Maxpulse']}")




print("\n============================= selecting with .iloc() =============================\n")


print("\n============================= selecting a single row =============================\n")


print(practice_data.iloc[3])


print("\n============================= selecting a slice of rows =============================\n")



print(practice_data.iloc[3:6])



print("\n============================= applying conditional selecttion to column \"Calories\" to obtain patients with less than 250 calories =============================\n")


print("\n============================= 5 rows of Columns of people with less than 250 calories =============================\n")


print(practice_data[practice_data["Calories"] < 250].head(5))


print("\n============================= selecting patients with a \"60\" duration and pulse less than 111 =============================\n")


print(practice_data[(practice_data["Duration"] == 60) & (practice_data["Pulse"] < 111)].head(5))


print("\n============================= The following is just practice and testing =============================\n")

print(f"Pulse for JTLGAP using .loc() is --> {practice_data.loc['JTLGAP', 'Pulse']}")

print(f"\nPulse for JTLGAP using .iloc() is --> {practice_data.iloc[1, 2]}")



print("\n============================= Selecting the 10th, 20th and 30th row =============================\n")


print(practice_data.iloc[[10, 20, 30]])









































practice_dataset = pd.read_csv(r"C:\Users\USER\Documents\My Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\data_sets\pulse_and_calorie_data.csv")


practice_dataset = practice_dataset.set_index("Name")


print(f'''
============================= original Dataframe =============================
      
{practice_dataset.head(5)}
''')


practice_dataset["Calories Standardization"] = (practice_dataset["Calories"] - practice_dataset["Calories"].mean()) / practice_dataset["Calories"].std()


print(f'''
============================= after adding "Calories Standardization" column =============================

{practice_dataset.head(4)}
''')


practice_dataset = practice_dataset.drop("VIRSOZ") # axis is 0 (meaning row) by default, so no need to specify it

print(f'''
=============================  after dropping row "VIRSOZ" =============================
      
{practice_dataset.head(4)}
''')


practice_dataset = practice_dataset.drop("Date", axis = 1) # we're deleting a column this time, so we specify that axis = 1, meaning column



print(f'''
============================= after dropping "Date" column =============================

{practice_dataset.head(4)}
''')


practice_dataset = practice_dataset.rename(
    columns = {
        "Duration": "Period",

        "Calories Standardization": "<-- C Scaling",
    }
)


print(f'''
============================= after renaming columns =============================

{practice_dataset.head(4)}
''')










































employee_data = {
    'Employee ID': ['E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107'],
    'Full Name': ['Alice Johnson', 'Bob Williams', 'Charlie Garcia', 'David Lee', 'Eve Martinez', 'Frank Rodriguez', 'Grace Hernandez'],
    'Department': ['Marketing', 'Engineering', 'HR', 'Engineering', 'Marketing', 'Engineering', 'HR'],
    'Start Date': ['2022-01-15', '2021-09-01', '2023-03-12', '2020-05-20', '2022-11-01', '2019-07-10', '2023-01-05'],
    'Salary': [65000, 92000, 58000, 115000, 68000, 130000, 61000],
    'Last Performance Rating': [4, 5, 3, 4, 5, 5, 4]
}



employee_information = pd.DataFrame(employee_data).set_index("Employee ID")


print(f'''
============================= first few rows of data =============================

{employee_information.head(n = 4)}
''')

print("============================= concise summary of dataset =============================\n")

employee_information.info()


print(f'''
============================= statistical overview of numerical columns =============================

{employee_information.describe()}

============================= Filter for Active, High-Performing Employees =============================

{employee_information[employee_information["Last Performance Rating"] > 3].head(3)}
''')


employee_information = employee_information.drop("E104")


print(f'''
============================= Removing David Lee's Record (ID E104)  =============================
      
{employee_information.head(4)}
''')


high_performers = employee_information[((employee_information["Department"] == "Marketing") | (employee_information["Department"] == "Engineering")) & (employee_information["Last Performance Rating"] >= 4)].copy()


high_performers["Bonus"] = high_performers["Salary"] * 0.1


high_performers = high_performers.rename(
    columns = {
        "Last Performance Rating": "Perf. Score",
    }
).drop("Start Date", axis = 1)


print(f'''
============================= high-performing employees who will be receiving a bonus =============================

{high_performers}
''')




























































simple_student_data = {
    'student_id': range(1, 16),

    'math_score': [85, 92, 78, np.nan, 65, 71, 95, 88, 76, 83, np.nan, 90, 68, 75, 99],

    'english_score': [91, 88, 94, 82, 79, np.nan, 87, np.nan, 85, 90, 75, 81, np.nan, 93, 89],

    'science_score': [80, 85, np.nan, 77, 70, 82, 90, 88, 79, np.nan, 84, 91, 72, 86, 95],

    'study_group': ['A', 'B', 'A', 'B', 'C', 'A', np.nan, 'B', 'C', 'D', 'A', 'B', 'D', 'C', np.nan],

    'hours_studied': [5.5, 7.0, 4.5, 6.0, 3.0, np.nan, 8.0, 5.0, 4.0, 6.5, 5.0, 7.5, 3.5, np.nan, 9.0],

    'honor_student': [True, True, False, False, False, True, True, True, False, True, False, True, False, False, True]
}


practice_dataset = pd.DataFrame(simple_student_data).set_index("student_id")


print(f'''
============================= original dataframe with missing values =============================
      
{practice_dataset.head(8)}
''')


print(f'''
============================= count of missing values per column =============================
      
{practice_dataset.isnull().sum()}
''')


practice_dataset_dropped = practice_dataset.dropna()


print(f'''
============================= Dataframe after dropping rows with any NaN =============================
      
{practice_dataset_dropped}

''')

practice_dataset_dropped.info()



practice_dataset_filled = practice_dataset.copy()



__math_mean_ = practice_dataset_filled["math_score"].mean()

practice_dataset_filled.fillna({"math_score": __math_mean_}, inplace = True)



practice_dataset_filled.fillna({"english_score": practice_dataset_filled["english_score"].median()}, inplace = True)


practice_dataset_filled.fillna({"study_group": practice_dataset_filled["study_group"].mode()[0]}, inplace = True)


print(f'''
============================= dataframe after filling missing values =============================
      
{practice_dataset_filled}


============================= check for missing values in the filled Dataframe =============================

{practice_dataset_filled.isnull().sum()}
''')


practice_dataset__ = practice_dataset.copy()


practice_dataset__ = rmf(practice_dataset__, ["math_score", "english_score", "science_score", "hours_studied"], seed_ = 20)

practice_dataset__.fillna(
    {
        "study_group": practice_dataset__["study_group"].mode()[0]
    }, inplace = True
)




print(f'''
============================= practice dataset after applying custom algorithm =============================
      
{practice_dataset__}
''')












































sample_student_data = {
    'student_id': range(1, 16),

    'math_score': [85, 92, 78, np.nan, 65, 71, 95, 88, 76, 83, np.nan, 90, 68, 75, 99],

    'english_score': [91, 88, 94, 82, 79, np.nan, 87, np.nan, 85, 90, 75, 81, np.nan, 93, 89],

    'science_score': [80, 85, np.nan, 77, 70, 82, 90, 88, 79, np.nan, 84, 91, 72, 86, 95],

    'study_group': ['A', 'B', 'A', 'B', 'C', 'A', np.nan, 'B', 'C', 'D', 'A', 'B', 'D', 'C', np.nan],

    'hours_studied': [5.5, 7.0, 4.5, 6.0, 3.0, np.nan, 8.0, 5.0, 4.0, 6.5, 5.0, 7.5, 3.5, np.nan, 9.0],

    'honor_student': [True, True, False, False, False, True, True, True, False, True, False, True, False, False, True]
}



practice_dataset = pd.DataFrame(sample_student_data).set_index("student_id")


print(f'''
============================= original Dataframe =============================
      
{practice_dataset}


============================= .notnull() output =============================

{practice_dataset.notnull()}


============================= count of non-missing values per column =============================

{practice_dataset.notnull().sum()}


============================= filtering Dataframe for non-mising english scores =============================

{practice_dataset[practice_dataset["english_score"].notnull()]}
''')








































the_messy_data = {
    'order_id': ['A101', 'A102', 'A103', 'A104'],
    'order_date': ['2025-10-01', '2025-10-02', '2025-10-02', '2025-10-03'],
    'product_name': ['  Laptop  ', ' MOUSE', 'keyboard ', '  Monitor  '],
    'price': ['$1,200.50', '$25.00', '$79.99', '$350.00']
}



the_dataset = pd.DataFrame(the_messy_data)

the_dataset = the_dataset.set_index("order_id")

print(f'''
============================= original messy Dataframe =============================
      
{the_dataset}


============================= original Data types =============================
''')

the_dataset.info()


the_dataset["product_name"] = the_dataset["product_name"].str.strip().str.title()

print(f'''

============================= result after cleaning "product_name" column =============================
      
{the_dataset}
''')


# we use .str to apply python string formatting to every object row in a column, and .astype() to change the datatype of the column

the_dataset["price"] = the_dataset["price"].str.replace("$", "").str.replace(",", "").astype(float)



the_dataset["order_date"] = pd.to_datetime(the_dataset["order_date"])


print(f'''
============================= after converting "price" and "order_date" =============================

{the_dataset}


============================= new data types =============================
''')

the_dataset.info()


the_dataset["price_label"] = the_dataset["price"].apply(
    lambda a_row: "High" if a_row > 300 else "Low"
)


print(f'''
============================= after adding "price_label" with .apply() =============================
      
{the_dataset}
''')







































sample_user_data = {
    'user_id': [101, 102, 103, 101, 104, 105],
    'name': ['Alice', 'Bob', 'Charlie', 'Alice', 'Bob', 'Denise'],
    'email': ['alice@email.com', 'bob@email.com', 'charlie@email.com', 'alice@email.com', 'bob@email.com', 'denise@email.com']
}



p_dataset = pd.DataFrame(sample_user_data).set_index("user_id")



print(f'''
============================= original dataframe with duplicates =============================
      
{p_dataset}


============================= identifying duplicates (default --> keep = "first") =============================
      
{p_dataset.duplicated()}


============================= showing only the duplicate rows =============================

{p_dataset[p_dataset.duplicated()]}


============================= Dataframe after dropping full duplicates =============================

{p_dataset.drop_duplicates()}


============================= identifying duplicates based on "email" column =============================

{p_dataset[p_dataset.duplicated(subset = ["email"])]}


============================= dataframe with unique emails =============================

{p_dataset.drop_duplicates(subset = ["email"], keep = "first")}
''')


# for .duplicated(), keep = "first" by default












































dirty_product_data = {
    'product_sku': ['SKU101', 'SKU102', 'SKU103', 'SKU102', 'SKU104', 'SKU105', 'SKU106', 'SKU107', 'SKU108', 'SKU101'],
    'product_name': ['  laptop  ', ' MOUSE', 'keyboard ', ' MOUSE', '  monitor ', 'usb-c cable', ' headphones ', 'webcam', '  laptop  ', '  laptop  '],
    'category': ['Electronics', 'electronics', 'Computers', 'electronics', 'Monitors', 'computers', 'Audio', 'electronics', 'Electronics', 'Electronics'],
    'price': ['$1200.00', '$25.50', '$79.99', '$25.50', '$350.00', '$15.00', pd.NaT, '$45.00', '$1350.00', '$1200.00'],
    'date_added': ['2024-01-05', '2024-01-10', '2024-01-12', '2024-01-10', '2024-02-01', '2024-02-05', '2024-02-15', '2024-03-01', '2024-03-10', '2024-01-05']
}


practice_dataset = pd.DataFrame(dirty_product_data)


print(f'''
============================= original datset =============================
      
{practice_dataset}


============================= summary of 'before' state of dataset =============================
''')

practice_dataset.info()


# ============================= handling duplicates =============================

practice_dataset = practice_dataset.drop_duplicates(keep = "first")

practice_dataset = practice_dataset.drop_duplicates(subset = ["product_sku"], keep = "first")


# ============================= handling missing data =============================


practice_dataset = practice_dataset[(practice_dataset["price"].notnull()) & (practice_dataset["product_sku"].notnull())]


'''

i don't know how to do this:

For any products with a missing category, fill the NaN value with the string "Unknown"

'''



# ============================= correcting and transforming data =============================


# ============================= had to do a bit of research to perform this for loop =============================

for x in list(practice_dataset.columns)[1:]:

    if practice_dataset[x].str.startswith("$").all():

        practice_dataset[x] = practice_dataset[x].str.replace("$", "").str.replace(",", "").astype(float)

    elif practice_dataset[x].astype(str).str.startswith("2024").all():

        practice_dataset[x] = pd.to_datetime(practice_dataset[x])

    else:
        practice_dataset[x] = practice_dataset[x].str.title().str.strip()
    


# ============================= preparing final report =============================


print()
practice_dataset.info()

print(f'''
============================= cleaned dataset =============================
      
{practice_dataset.head(4)}
''')














































p_dataset = pd.read_csv(r"C:\Users\USER\Documents\My_Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\data_sets\California_Housing_Dataset - Extract.csv")

print(f'''
============================= original dataframe =============================
      
{p_dataset.head(4)}
''')

p_dataset = p_dataset.dropna()

# p_dataset.info()

dG_OP = p_dataset.groupby("ocean_proximity")

print(f'''
============================= sum by ocean proximity =============================
      
{dG_OP.sum()}


============================= average by ocean proximity =============================

{dG_OP.mean()}


============================= count of entries by ocean proximity =============================

{dG_OP.count()}
''')


agg_algo = dG_OP.agg(

    Total_Population = (
        "population", "sum"
    ),

    Average_Households = (
        "households", "mean"
    )
)

print(f'''
============================= custom aggreagtion (.agg) =============================
      
{agg_algo}


============================= group by ocean_proximity and households (sum) =============================

{p_dataset.groupby([
    "ocean_proximity", "households"
]).mean().sample(5)}
''')










































the_d_set = {
    'Name': ['Alice', 'Bob', 'Carol', 'David', 'Emily'],
    'Age': [25, 30, np.nan, 22, 35],
    'Salary': [50000, 65000, 70000, np.nan, 90000]
}

p_dataset = pd.DataFrame(data = the_d_set)

print(f'''
============================= original dataset =============================
      
{p_dataset}
''')


mean_age = p_dataset["Age"].mean()


p_dataset["Age"], p_dataset["Salary"] = p_dataset["Age"].fillna(mean_age), p_dataset["Salary"].fillna(0)

print(f'''
============================= new, cleaned DataFrame =============================

{p_dataset}
''')









































data = {
    'Employee': ['John', 'Mary', 'Peter', 'Jane', 'Tom', 'Lisa'],
    'Department': ['Sales', 'Engineering', 'Sales', 'Engineering', 'Marketing', 'Marketing'],
    'Status': ['Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time'],
    'Salary': [90000, 80000, 95000, 110000, 60000, 75000],
    'Projects': [5, 3, 7, 6, 4, 5]
}



d_set = pd.DataFrame(data = data)


print(f'''
============================= original dataset =============================
      
{d_set}


============================= average salary for each department =============================

{d_set.groupby("Department").mean(numeric_only = True).drop("Projects", axis = 1)}


============================= employees per Status =============================

{d_set.groupby("Status").sum()}
''')


agg_algorithm = d_set.groupby("Department").agg(

    Total_Projects = (
        "Projects", "sum"
    ),

    Max_Salary = (
        "Salary", "max"
    )
)


print(f'''
============================= finding total number of projects and maximum salary, grouped by Department =============================
      
{agg_algorithm}
''')

















































raw_data = {
    "Employee": ["John", "Mary", "Peter", "Jane", "Tom", "Lisa"],
    "Department": [
        "Sales",
        "Engineering",
        "Sales",
        "Engineering",
        "Marketing",
        "Marketing",
    ],
    "Status": [
        "Full-Time",
        "Part-Time",
        "Full-Time",
        "Full-Time",
        "Part-Time",
        "Full-Time",
    ],
    "Salary": [90000, 80000, 95000, 110000, 60000, 75000],
    "Projects": [5, 3, 7, 6, 4, 5],
}


pra_dataset = pd.DataFrame(raw_data)


print(f"""
============================= Original DataFrame =============================
      
{pra_dataset}


============================= Multi-level GroupBy (Average Salary and Projects) =============================

{pra_dataset.groupby(["Department", "Status"]).mean(numeric_only=True)}
""")


pivot_average_sal = pd.pivot_table(
    data=pra_dataset,
    index="Department",
    columns="Status",
    values="Salary",
    aggfunc="mean",
)


print(f"""
============================= Pivot Table (Average Salary) =============================
      
{pivot_average_sal}


============================= More Complex Pivot Table (Sum of Projects) =============================

{
    pd.pivot_table(
        data=pra_dataset,
        index="Department",
        columns="Status",
        values="Projects",
        aggfunc="sum",
    )
}
""")


pv_mul_table = pd.pivot_table(
    data=pra_dataset,
    index="Department",
    columns="Status",
    # Using a dictionary for aggfunc allows specifying different aggregation functions for each column.
    aggfunc={"Salary": "mean", "Projects": "sum"},
)

print(f"""
============================= pivot table with Multiple Values =============================
      
{pv_mul_table}
""")









































































practice_emp_Dset = {
    'Employee': [
        'Rhonda Williams', 'James Miller', 'Kevin Smith', 'David Jones', 'Heidi Lewis', 
        'Michael Johnson', 'Anthony Taylor', 'David Miller', 'Daniel Williams', 'Scott Anderson', 
        'David Jones', 'Robert Garcia', 'Jason Brown', 'William Smith', 'Melissa Smith', 
        'Nicole Smith', 'Joseph Rodriguez', 'Thomas Smith', 'James Smith', 'Thomas Allen', 
        'Robert Smith', 'Michelle Jones', 'Michael Williams', 'John Miller', 'John Smith', 
        'Jennifer Smith', 'Mary Johnson', 'David Johnson', 'Mark Williams', 'Mary Williams', 
        'Mary Miller', 'Robert Williams', 'Michael Smith', 'Michael Johnson', 'William Williams', 
        'Mark Smith', 'Mary Smith', 'Linda Jones', 'Jennifer Williams', 'Robert Brown', 
        'Robert Johnson', 'William Johnson', 'Michael Davis', 'James Williams', 'Michael Brown', 
        'Patricia Johnson', 'James Johnson', 'Richard Johnson', 'Richard Williams', 'David Smith', 
        'William Jones', 'Elizabeth Johnson', 'Barbara Johnson', 'Linda Smith', 'Patricia Smith', 
        'Linda Williams', 'Susan Smith', 'Robert Jones', 'Jennifer Brown', 'Patricia Jones', 
        'Elizabeth Smith', 'Barbara Williams', 'Mary Brown', 'Barbara Smith', 'Elizabeth Jones', 
        'Elizabeth Miller', 'Susan Johnson', 'Maria Smith', 'Linda Johnson', 'Linda Brown', 
        'Jennifer Jones', 'Mary Jones', 'Susan Williams', 'Susan Jones', 'Barbara Brown', 
        'Maria Williams', 'Sarah Johnson', 'Elizabeth Williams', 'Maria Garcia', 'Maria Rodriguez', 
        'Maria Jones', 'Karen Williams', 'Karen Johnson', 'Sarah Williams', 
        'Maria Martinez', 'Sarah Jones', 'Jessica Smith', 'Karen Jones', 'Nancy Smith', 
        'Jessica Johnson', 'Nancy Williams', 'Jessica Williams', 'Sarah Miller', 
        'Lisa Smith', 'Betty Smith', 'Lisa Williams', 'Betty Williams', 'Nancy Johnson', 
        'Lisa Jones', 'Betty Johnson', 'Helen Williams', 'Sandra Smith', 'Dorothy Smith', 
        'Helen Smith', 'Sandra Johnson', 'Dorothy Johnson', 'Sandra Williams', 'Helen Johnson', 
        'Dorothy Williams', 'Lisa Johnson', 'Sandra Jones', 'Helen Jones', 'Betty Jones', 
        'Dorothy Jones', 'Ashley Smith', 'Margaret Williams', 'Kimberly Smith', 
        'Ashley Williams', 'Emily Smith', 'Margaret Johnson', 'Kimberly Williams', 'Ashley Johnson', 
        'Emily Williams', 'Kimberly Johnson', 'Margaret Jones', 'Emily Johnson', 'Ashley Jones', 
        'Amanda Smith', 'Kimberly Jones', 'Melissa Smith', 'Emily Jones', 'Amanda Williams', 
        'Melissa Williams', 'Deborah Smith', 'Melissa Johnson', 'Amanda Jones', 
        'Carol Smith', 'Deborah Williams', 'Michelle Smith', 'Melissa Jones', 'Carol Williams'
    ],


    'Department': [
        'Sales', 'Support', 'Engineering', 'Marketing', 'Engineering', 'Engineering', 
        'Sales', 'Sales', 'Sales', 'Engineering', 'Support', 'Engineering', 
        'Support', 'Engineering', 'Support', 'Support', 'Support', 'Sales', 
        'Engineering', 'Sales', 'Engineering', 'IT', 'Sales', 'Sales', 
        'Engineering', 'Marketing', 'Sales', 'IT', 'Finance', 'Engineering', 
        'Support', 'Sales', 'Support', 'Support', 'Sales', 'Engineering', 
        'Support', 'Engineering', 'Marketing', 'Engineering', 'Engineering', 'Engineering', 
        'IT', 'Marketing', 'Sales', 'Engineering', 'Support', 'Engineering', 
        'Engineering', 'Engineering', 'Engineering', 'IT', 'Engineering', 'Sales', 
        'Sales', 'Sales', 'Engineering', 'Sales', 'Sales', 'Engineering', 
        'Sales', 'Support', 'Marketing', 'Sales', 'Engineering', 'Engineering', 
        'Engineering', 'Support', 'Support', 'Engineering', 'Marketing', 'Engineering', 
        'Marketing', 'Sales', 'Sales', 'Engineering', 'Engineering', 'Engineering', 
        'Engineering', 'Marketing', 'Sales', 'IT', 'Engineering', 'Engineering', 
        'Support', 'Sales', 'Sales', 'Engineering', 'Support', 'Marketing', 
        'Sales', 'Support', 'Sales', 'Engineering', 'Support', 'IT', 
        'Engineering', 'Marketing', 'Engineering', 'Support', 'Sales', 'Engineering', 
        'Engineering', 'IT', 'Sales', 'IT', 'Finance', 'Sales', 
        'Sales', 'Sales', 'Support', 'Engineering', 'IT', 'Sales', 
        'Support', 'Marketing', 'Engineering', 'Support', 'Sales', 'IT', 
        'Engineering', 'Support', 'Sales', 'HR', 'Support', 'Support', 
        'Engineering', 'Sales', 'Support', 'IT', 'Sales', 'Engineering', 
        'IT', 'Marketing', 'Sales', 'Support', 'Support', 'HR', 
        'Finance', 'Engineering', 'Engineering'
    ],


    'Status': [
        'Full-Time', 'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Part-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time',  'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Part-Time', 'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Part-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Part-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 'Full-Time', 
        'Full-Time', 'Full-Time', 'Full-Time'
    ],


    'Salary': [
        86700, 71500, 114600, 37200, 115100, 107600, 101100, 89300, 68700, 
        110600, 56300, 110900, 60800, 116600, 31000, 51300, 75500, 110600, 
        116100, 58100, 120500, 89000, 93500, 35000, 142400, 46100, 77500, 
        88200, 91500, 112100, 65600, 105900, 27300, 56900, 114900, 108300, 
        57600, 114700, 84300, 102200, 122200, 128400, 98900, 84000, 112300, 
        134200, 28100, 129700, 114900, 137400, 147500, 83100, 69600, 89100, 
        100900, 149300, 77300, 115300, 109700, 105600, 137200, 84000, 100400, 
        113000, 60400, 139500, 47700, 60800, 88200, 43900, 124200, 136200, 
        99600, 122200, 25200, 128100, 73100, 106000, 106200, 127600, 108800, 
        105200, 92400, 112200, 37400, 123800, 107600, 104500, 140200, 65500, 
        30600, 120500, 76200, 71500, 80800, 61500, 26900, 100700, 60800, 
        90200, 73600, 107300, 41200, 124300, 71900, 113300, 102000, 115200, 
        103800, 99600, 95900, 68000, 83900, 32300, 120600, 87400, 103200, 
        75800, 45100, 105800, 107100, 86800, 26600, 108800, 66300, 65800, 
        64600, 68000, 76200, 60900, 50600, 90700, 109800, 40100, 68600, 
        74400, 77400, 57100, 91500, 64200, 131700
    ],


    'Projects': [
        3, 3, 5, 2, 8, 4, 3, 3, 4, 7, 2, 7, 2, 5, 1, 3, 1, 4, 6, 2, 7, 5, 5, 2, 
        7, 3, 5, 4, 3, 7, 2, 5, 1, 2, 6, 8, 1, 5, 6, 4, 5, 7, 1, 7, 
        7, 6, 7, 6, 3, 4, 3, 5, 4, 7, 7, 5, 4, 5, 6, 4, 7, 2, 5, 4, 1, 7, 8, 
        5, 5, 1, 6, 2, 6, 4, 6, 5, 8, 6, 6, 2, 7, 5, 5, 5, 3, 2, 5, 3, 5, 5, 2, 
        1, 4, 2, 4, 3, 5, 2, 8, 3, 8, 4, 6, 6, 5, 6, 3, 4, 1, 6, 4, 4, 2, 2, 6, 
        6, 5, 1, 5, 1, 2, 3, 1, 3, 3, 2, 6, 2, 3, 2, 6, 3, 2, 5, 5, 1, 3, 2, 
        3, 7, 5
    ]
}
















































practice_dataset = pd.DataFrame(practice_emp_Dset)

print(f'''
============================= Original dataset =============================

{practice_dataset.sample(6)}


============================= dataset info =============================
''')

practice_dataset.info()


practice_dataset["Avg_team_Sal"] = (practice_dataset.groupby("Department")["Salary"].transform("mean")).round(2)


print(f'''
============================= using .transform() to add "Avg_Team_Sal" =============================
      
{practice_dataset.sample(10)}
''')

practice_dataset["Sal difference"] = practice_dataset["Salary"] - practice_dataset["Avg_team_Sal"]

print(f'''
============================= Comapring Employee Salary with average salary =============================
      
{practice_dataset.sample(7)}
''')



print(f'''
============================= using .filter() to find high-Earning departments =============================
      
{practice_dataset.groupby("Department").filter(
    lambda the_dataframe: the_dataframe["Salary"].mean() > 83000
).sample(7)}
''')



















































dataset1 = pd.DataFrame({
    'Employee': ['Alice', 'Bob', 'Carol'],
    'Sales': [100, 150, 50]
}, index = [1, 2, 3])

print(f'''
============================= dataset 1 =============================
      
{dataset1}
''')


dataset2 = pd.DataFrame({
    'Employee': ['David', 'Emily'],
    'Sales': [200, 120]
}, index = [4, 5])


print(f'''
============================= dataset2 =============================
      
{dataset2}


============================= Vertically Stacked (default) =============================

{pd.concat([dataset1, dataset2])}
''')


clean_v_stack = pd.concat([dataset1, dataset2], ignore_index = True)

print(f'''
============================= Vertically Stacked with ignore_index = True =============================
      
{clean_v_stack}
''')

dataset3_l = pd.DataFrame({
    'Location': ['New York', 'London', 'Tokyo', 'Paris', 'Sydney']
}, index = [0, 1, 2, 3, 4])


print(f'''
============================= Location data =============================

{dataset3_l}


============================= Horizontally Stacked (axis = 1) =============================

{pd.concat([clean_v_stack, dataset3_l], axis = 1)}
''')











































emp_data = pd.DataFrame(
    {
        "emp_id": [101, 102, 103, 104],
        "Name": ["Alice", "Bob", "Carol", "David"],
        "Department": ["Sales", "Engineering", "Sales", "Marketing"],
    }
)

dept_data = pd.DataFrame(
    {"Department": ["Sales", "Marketing", "HR"], "Manager": ["Chris", "Emily", "Frank"]}
)


print(f"""
============================= Employee table =============================
      
{emp_data}


============================= Department table =============================

{dept_data}


============================= Inner join Result  =============================

{pd.merge(emp_data, dept_data, on="Department", how="inner")}

The above is the "inner" join. Notice how bob is gone because "Engineering" isn't the Department DataFrame


============================= Left join Result (All employees, bob has NaN)  =============================

{pd.merge(
    emp_data, dept_data,
    on = "Department", how = "left"
)}


============================= Outer Join Result (Everyone is here, lots of NaN)  =============================

{pd.merge(
    emp_data,
    dept_data,
    on = "Department",
    how = "outer"
)}


============================= Right join Result (All employees, bob has NaN)  =============================

{pd.merge(
    emp_data,
    dept_data,
    on = "Department",
    how = "right"
)}
""")








































# Dataset 1: Sales for Jan
sales_jan = {
    'product_id': ['P101', 'P102', 'P103'],
    'units_sold': [50, 80, 120]
}
df_jan = pd.DataFrame(sales_jan)

# Dataset 2: Sales for Feb
sales_feb = {
    'product_id': ['P101', 'P103', 'P104'],
    'units_sold': [55, 130, 20]
}
df_feb = pd.DataFrame(sales_feb)

# Dataset 3: Product Details
product_details = {
    'product_id': ['P101', 'P102', 'P103', 'P104'],
    'name': ['Widget A', 'Widget B', 'Gadget C', 'Gizmo D'],
    'category': ['Widgets', 'Widgets', 'Gadgets', 'Gizmos']
}
df_products = pd.DataFrame(product_details)



print(f'''
============================= Original  DataFrames =============================


============================= DataFrame for January =============================

{df_jan}

============================= DataFrame for February =============================

{df_feb}

============================= Product Details =============================

{df_products}
''')



all_sales = pd.concat([df_jan, df_feb], ignore_index = True)

print(f'''
============================= All Sales =============================
      
{all_sales}
''')

total_sales = all_sales.groupby("product_id")["units_sold"].sum()

final_report = pd.merge(
    total_sales, df_products,
    on = "product_id", how = "left"
)



print(f'''
============================= Total Sales =============================
      
{total_sales}


============================= Final report =============================

{final_report}
''')


total_for_each_category = final_report.groupby("category")["units_sold"].transform("sum")
total_for_each_category.name = "Cat_T_Sales"


final_report["Category Total Sales"] = total_for_each_category


final_report['percent_of_category_sales'] = (final_report["units_sold"] / total_for_each_category).mul(100).round(2).map("{}%".format)

high_performers = final_report.groupby("category").filter(
    lambda x: x["units_sold"].sum() > 150
)



print(f'''
============================= Final Report with "percent_of_category_sales" =============================
      
{final_report}


============================= High Perfromers =============================

{high_performers}
''')



















































emp_data = pd.DataFrame(
    {
    'Name': ['Alice', 'Bob', 'Carol', 'David'],
    'Department': ['Sales', 'Engineering', 'Sales', 'Engineering']
    }, index=['e101', 'e102', 'e103', 'e104']
)

perf_data = pd.DataFrame(
    {
    'Performance_Score': [8.5, 9.0, 7.8],
    'Projects': [5, 3, 6]
    }, index=['e101', 'e102', 'e105']
)

emp_data.index.name, perf_data.index.name = "Employee ID", "Employee ID"

print(f'''
============================= Employee table (Index is Employee ID) =============================
      
{emp_data}


============================= Performance table (Index is Employee ID) =============================

{perf_data}
''')

joined_data = emp_data.join(perf_data)


print(f'''
============================= .join() Result (Left join on Index) =============================

{joined_data}
''')


joined_data["Performance_Score"] = joined_data["Performance_Score"].fillna(2.6)

dept_avg_score = joined_data.groupby("Department")["Performance_Score"].transform("mean")

joined_data["Dept. Total Score"] = joined_data.groupby("Department")["Performance_Score"].transform("sum")

joined_data["Avg. Score [D]"] = dept_avg_score

joined_data["Score vs. Dept."] = joined_data["Performance_Score"] - joined_data["Avg. Score [D]"]

print(f'''
============================= using .transform() to find Department total and average score =============================

{joined_data}
''')



joined_data['Projects'] = joined_data["Projects"].fillna(joined_data["Projects"].mean())

joined_data = joined_data.drop(list(joined_data.columns)[4:], axis = 1)

joined_data["Dept. Total Projects"] = joined_data.groupby("Department")["Projects"].transform("sum")

joined_data["Avg. Proj. [D]"] = joined_data.groupby("Department")["Projects"].transform("mean")

joined_data["Proj. vs.  Dept."] = joined_data["Projects"] - joined_data["Avg. Proj. [D]"]


print(f'''
============================= using .transform() to find Department total and average Projects =============================

{joined_data}
''')


high_perfromers_data = joined_data.groupby("Department").filter(
    lambda Dept: Dept["Projects"].mean() < 3.6
)

print(f'''
============================= Using .filter() to find "high-performing" Departments =============================
      
{high_perfromers_data}
''')





















































the_data = {
    'Store': ['Store_A', 'Store_B', 'Store_A', 'Store_C', 'Store_B', 'Store_A'],


    'Product': ['Apples', 'Oranges', 'Bananas', 'Apples', 'Bananas', 'Oranges'],


    'Sales': [150, 200, 75, 300, 120, 90],


    'Quantity': [10, 15, 5, 20, 8, 6]
}

practice_dataset = pd.DataFrame(the_data)

print(f'''
============================= Original DataFrame =============================

{practice_dataset}
''')

st_grp = practice_dataset.groupby("Store")


print(f'''
============================= The groupby Object (The "Plan") =============================
      
{st_grp}


============================= total sales per store (.sum()) =============================

{practice_dataset.groupby("Store")["Sales"].sum()}


============================= Average sales per store =============================

{practice_dataset.groupby("Store")["Sales"].mean()}


============================= Count of sales per store =============================

{practice_dataset.groupby("Store")["Sales"].count()}


============================= Maximum Sale per store =============================

{practice_dataset.groupby("Store")["Sales"].max()}


============================= Converting to a DataFrame =============================

{practice_dataset.groupby("Store")["Sales"].sum().reset_index()}


============================= renaming column =============================

{practice_dataset.groupby("Store")["Sales"].count().reset_index().rename(columns = {"Sales": "Number of Sales"})}
''')













































print("Connecting to DataBase...\n")
time.sleep(0.7)

con_ect = sqlite3.connect(d_path)

Query = "SELECT * FROM `Sales Table` LIMIT 50"


the_dataset = pd.read_sql(Query, con_ect)

con_ect.close()

print(f'''
============================= Original Dataframe (from "my_database.db") =============================
      
{the_dataset.sample(6)}


============================= using .agg on the sales column ["sum", "mean", "std"] =============================

{
    the_dataset.groupby("Store")["Sales"].agg(["sum", "mean", "std"]).reset_index().sample(5)
}


============================= using .agg() with a dictionary to perform different operations to multiple columns =============================

{
    the_dataset.groupby("Store").agg({
        "Sales": "sum",

        "Quantity": "mean"
    }).sample(6)
}
''')

the_dataset["Store Avg. Sales"] = the_dataset.groupby("Store")["Sales"].transform("mean")


print(f'''
============================= using .transform(). DataFrame does not collapse =============================
      
{the_dataset.sample(6)}
''')


the_dataset["Sales vs. Avg. Sales"] = the_dataset["Sales"] - the_dataset["Store Avg. Sales"]

print(f'''
============================= Comapring each sale to Store Average sale =============================
      
{the_dataset.sample(6)}


============================= filtering Stores to find those whose sum of sales is greater than 300 =============================

{
    the_dataset.assign(sum_of_store_sales = the_dataset.groupby("Store")["Sales"].transform("sum")).groupby("Store").filter(lambda group: group["Sales"].sum() > 1000).sample()
}
''')



































print("Connecting to database...")
time.sleep(2)

connection = sqlite3.connect(d_path)

employee_dataset = pd.read_sql(
    "SELECT * FROM Employees",
    
    connection
)

sales_dataset = pd.read_sql(
    "SELECT * FROM Sales LIMIT 119",
    
    connection
)

connection.close()

print(f'''
============================= Employees DataFrame =============================
      
{employee_dataset.sample(5)}


============================= Sales DataFrame =============================

{sales_dataset.sample(5)}


============================= Pivot Table: Avg. Salary by Dept/Position =============================

{pd.pivot_table(
    employee_dataset,

    index = "Department",

    columns = "Position",

    values = "Salary",

    aggfunc = "mean"
).round(2)}


============================= Crosstab: Employee COUNT by Dept/Position =============================

{
    pd.crosstab(
        employee_dataset["Department"],

        employee_dataset["Position"]
    )
}
''')









































"""
    In Part 1, you built a pivot table in SQL. In Part 2, you could have done the same thing using pandas. What is the main advantage of building the pivot table in SQL before the data ever gets to pandas?

    Ans: Honestly, i don't know the real answer. But i think it's to see how the pivot table is in SQL, before doing it in pandas. If you do it in both SQL and pandas, you can confirm that they are the same and that it's accurate
"""

print("Connecting to Database...")
time.sleep(2)


con_nect = sqlite3.connect(d_path)


employee_DSET = pd.read_sql(
    "SELECT * FROM Employees",

    con_nect
)

sales_DSET = pd.read_sql(
    "SELECT * FROM sales LIMIT 300",

    con_nect
)

con_nect.close()





print(f'''
============================= Sales Table =============================
      
{sales_DSET.head(6)}


============================= Employee Table =============================

{employee_DSET.head(6)}


============================= Pivot Table for summary =============================

{
    sales_DSET.groupby("Store").agg(
        total_sales = ("Sales", "sum"),

        average_sale = ("Sales", "mean"),

        no_transactions = ("Sales", "count")
    ).reset_index().round(2)
}


============================= Employee Analysis =============================

{
    pd.crosstab(
        employee_DSET["Department"],

        employee_DSET["Position"]
    )
}


============================= Table with performance column =============================
''')



sales_DSET["avg_store_sale"] = sales_DSET.groupby("Store")["Sales"].transform("mean")



sales_DSET["sale_vs_store_avg"] = sales_DSET["Sales"] - sales_DSET["avg_store_sale"]


print(sales_DSET.head(5).round(2))



high_performing_departments = employee_DSET.groupby("Department").filter(
    lambda group: group["Salary"].mean() > 75000
)


print(f'''
============================= High-Performing Departments =============================

{high_performing_departments[["Department", "Salary"]].sample(6)}
''')

















































































print("Connecting to DataBase...")
time.sleep(2)


con_nect_ion = sqlite3.connect(d_path)

dataset_Q3 = pd.read_sql(
    "SELECT * FROM sales_q3 LIMIT 293",
    
    con_nect_ion
)

dataset_Q4 = pd.read_sql(
    "SELECT * FROM sales_q4 LIMIT 293",

    con_nect_ion
)

emp_dataset = pd.read_sql(
    "SELECT * FROM Employees",

    con_nect_ion
)


con_nect_ion.close()


print(f'''
============================= Q3 Sales =============================

{dataset_Q3.head(6)}

Shape: {dataset_Q3.shape}


============================= Q4 Sales =============================

{dataset_Q4.head(6)}

Shape: {dataset_Q4.shape}


============================= Employees =============================

{emp_dataset.head(6)}

Shape: {emp_dataset.shape}


============================= Vertical Concatenation (axis = 0) =============================

{pd.concat([dataset_Q3, dataset_Q4]).tail(6)}


============================= Cleaning the index =============================

{
    pd.concat(
        [
            dataset_Q3, dataset_Q4
        ],

        ignore_index = True
    ).sample(6)
}

Shape: {pd.concat([dataset_Q3, dataset_Q4], ignore_index = True).shape}

Notice that the index is much more than 293, meaning the concatenation was successful


============================= Horizontal Concatenation =============================
''')

pers_inf_dset = emp_dataset[list(emp_dataset.columns)[:2]]

wk_inf_dset = emp_dataset[list(emp_dataset.columns)[2:]]


print(f'''
============================= Split (Personal Info) =============================
      
{pers_inf_dset.head(6)}

Shape: {pers_inf_dset.shape}


============================= Split (Work Info) =============================

{wk_inf_dset.head(6)}

Shape: {wk_inf_dset.shape}


============================= After Horizontal Concatenation =============================

{
    pd.concat([pers_inf_dset, wk_inf_dset], axis = 1).head(n = 6)
}

Shape: {pd.concat([pers_inf_dset, wk_inf_dset], axis = 1).shape}
''')

# Note that we specified that axis = 1, when concatenating horizontally

# .concat() is one of the methods where axis = 1 refers to rows and not columns, unlike methods like .drop()



# And as usual, Jesse remains cool!














































print('Connecting to DataBase...')
time.sleep(2)

connection = sqlite3.connect(d_path)

emp_dset = pd.read_sql(
    "SELECT * FROM Employees LIMIT 569",

    connection
)

sal_dset = pd.read_sql(
    "SELECT * FROM Employee_Salary LIMIT 569",

    connection
)
connection.close()


print(f'''
============================= Employees DataFrame =============================
      
{emp_dset.head(6)}

Shape: {emp_dset.shape}


============================= Salary DataFrame =============================

{sal_dset.head(6)}

Shape: {sal_dset.shape}
''')

inner_join_mg = pd.merge(
    left = emp_dset,

    right = sal_dset,

    how = "inner",

    left_on = "employee_id",

    right_on = "emp_id"
)


print(f'''
============================= Inner Join =============================
      
{inner_join_mg.sample(6)}

Shape: {inner_join_mg.shape}
''')

left_join_mg = pd.merge(
    left = emp_dset,

    right = sal_dset,

    how = 'left',

    right_on = 'emp_id',

    left_on = 'employee_id'
) # in left joining, the left is the priority
# if anything is in the right but not in the left, remove it. If in the left but not in the right, keep it 

right_join_mg = pd.merge(
    how = 'right',

    left = emp_dset,
    
    left_on = 'employee_id',

    right = sal_dset,

    right_on = 'emp_id'
) # in right joining, the right is the priority
# if anything is in the right but not in the left, keep it. If in the left but not in the right, remove it 

print(f'''
============================= Left Join =============================

{left_join_mg.sample(6)}

Shape: {left_join_mg.shape}


============================= Right Join =============================
      
{right_join_mg.sample(6)}

Shape: {right_join_mg.shape}
''')

outer_join_mg = pd.merge(
    left = emp_dset,

    right = sal_dset,

    left_on = 'employee_id',

    right_on = 'emp_id',

    how = 'outer'
)



print(f'''
============================= Outer Join =============================

{outer_join_mg.sample(6)}

Shape: {outer_join_mg.shape}
''')




# ============================= Merging on multiple keys =============================

dset1 =  pd.DataFrame({
    'key1': [
        'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 
        'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 
        'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 
        'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 
        'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 
        'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 
        'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 
        'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 
        'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 'K1', 'K2', 'K0', 'K0', 
        'K1', 'K2', 'K0' # Last 3 elements
    ],
    'key2': [
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 'K0', 'K1', 
        'K0', 'K1', 'K0' # Last 3 elements
    ],
    'A': [
        'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 
        'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 
        'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 
        'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 
        'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 
        'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 
        'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 
        'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 
        'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 'A2', 'A3', 'A0', 'A1', 
        'A2', 'A3', 'A0' # Last 3 elements
    ],
    'B': [
        'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 
        'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 
        'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 
        'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 
        'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 
        'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 
        'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 
        'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 
        'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 'B2', 'B3', 'B0', 'B1', 
        'B2', 'B3', 'B0' # Last 3 elements
    ]
})


dset2 = pd.DataFrame({
    'key1': [
        'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1',
        'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2',
        'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1',
        'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2',
        'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1',
        'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2',
        'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1',
        'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2',
        'K0', 'K1', 'K1', 'K2', 'K0', 'K1', 'K1', 'K2', 'K0', 'K1',
        'K1', 'K2', 'K0' # Last 3 elements
    ],
    'key2': [
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0', 'K0',
        'K0', 'K0', 'K0' # Last 3 elements
    ],
    # For C and D columns, it is faster to generate sequential data programmatically 
    # to ensure all 93 elements are present and distinct.
    'C': [f"C{i+1:02d}" for i in range(93)],
    'D': [f"D{i+1:02d}" for i in range(93)]
})


print(f'''
      
============================= Performing Merging on Multiple Keys  =============================
      

============================= DataFrame 1 =============================
      
{dset1.head()}


============================= DataFrame 2 =============================
      
{dset2.head()}
''')


merg_on_keys = pd.merge(
    dset1, dset2,
    on = ['key1', 'key2']
) # This performs an inner join by default, only keeping rows where 
# the combination of 'key1' and 'key2' exists in both DataFrames.

print(f'''
============================= Merged DataFrame (Inner Join) =============================

{merg_on_keys.sample(9)}

Shape: {merg_on_keys.shape}
''')






















































print('Connecting to DataBase...')
time.sleep(2)


connection = sqlite3.connect(d_path)

emp_dset = pd.read_sql(
    "SELECT * FROM Employees LIMIT 413",

    connection
)

emp_details_dset = pd.read_sql(
    "SELECT * FROM Employee_Details LIMIT 413",

    connection
)

connection.close()

print(f'''
============================= Employees DataFrame =============================

{emp_dset.head(6)}


============================= Employee Details DataFrame =============================

{emp_details_dset.head(6)}
''')


mg_dframe = pd.merge(
    left = emp_dset,

    right = emp_details_dset,

    left_on = 'employee_id',

    right_on = 'emp_id',

    how = 'inner'
).drop(['emp_id'], axis = 1)


print(f'''
============================= Testing .merge() =============================

{mg_dframe.head(8)}
''')

# mg_dframe.to_csv('mg_dframe.csv', index = False)


try:

    basic_joining = emp_dset.join(emp_details_dset, lsuffix = '_emp', rsuffix = '_detail')

    print(f'''
    ============================= Basic .join() (matches index to index) =============================
          
    {basic_joining.sample(4)}
    ''')

except Exception as an_error:

    print(f"asic join failed --> {an_error}")


# setting employee_id as the index for the employee dataframe
emp_dset = emp_dset.set_index('employee_id')

# setting emp_id as the index for the employee details dataframe
emp_details_dset = emp_details_dset.set_index('emp_id')

print(f'''
============================= Indexed Employee DataFrame =============================

{emp_dset.head()}


============================= Indexed Employee Details DataFrame =============================

{emp_details_dset.head()}


============================= Final .join() result on aligned indexes =============================

{emp_dset.join(emp_details_dset).head()}
''')


# pd.merge() is more explicit and flexible for column-based joins.


# .join() is a shortcut for when your indices are already aligned.














































































































































































































































































































































































































































































































































































































































































