from build_database import create_and_populate_table
import sqlite3
from jesse_custom_code.pandas_file import database_path as d_path
import os

DB_FILE = d_path


# --- This script prepares our database for Cycle 2, Segment 3 ---

# --- 1. Create a fresh database file ---
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)
    print(f"Removed old database. Creating {DB_FILE}...")

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

# --- 2. Create the 'Sales' table ---
# This table is for our advanced WHERE clause practice.
create_and_populate_table(
    conn=conn,
    table_name="Sales",
    primary_key="Order ID",
    column_names={
        "Order ID": ["INTEGER", "serial"],
        "Store": ["TEXT", "rand_ch"],
        "Product": ["TEXT", "rand_ch"],
        "Sales": ["REAL", "rand_intg"],
        "Sale Date": ["DATE", "date"]
    },
    group={
        "Store": ['Store_A', 'Store_B', 'Store_C', 'Store_X'],
        "Product": ['Apples', 'Oranges', 'Bananas', 'Milk'],
        "Sales": ["f", 5, 500],
        "Sale Date": []
    },
    num_entries = 1000
)

# CRITICAL STEP: Manually add NULL values for our lesson
# We will make 10% of the 'Product' entries NULL
cursor.execute("""
    UPDATE Sales
    SET Product = NULL
    WHERE "Order ID" % 10 = 0;
""")
conn.commit()


# --- 3. Create the 'Employees' table ---
# This will be our "LEFT" table for joining.
# Note: It has a normal 0-9 index from pandas.
create_and_populate_table(
    conn=conn, 
    table_name="Employees",
    primary_key="employee_id",
    column_names={
        "employee_id": ["INTEGER", "serial"], # 1-10
        "Name": ["TEXT NOT NULL", "rand_name"]
    },
    group={"Name": "f"},
    num_entries = 785
)

# --- 4. Create the 'Employee_Details' table ---
# This will be our "RIGHT" table.
# We will *intentionally* set the 'emp_id' to be 5-14.
# This makes the indices different from the 'Employees' table.
create_and_populate_table(
    conn=conn,
    table_name="Employee_Details",
    primary_key="emp_id",
    column_names={
        "emp_id": ["INTEGER", "serial"],
        "Salary": ["REAL", "rand_intg"]
    },
    group={"Salary": ["f", 50000, 120000]},
    num_entries = 623
)


# Manually update emp_id to be 5-14
# cursor.execute("""
#     UPDATE Employee_Details
#     SET emp_id = emp_id + 4;
# """)
# conn.commit()


conn.close()
print(f"\n--- Database {DB_FILE} is ready! (Sales, Employees, Employee_Details) ---")