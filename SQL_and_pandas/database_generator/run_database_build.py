from build_database import create_and_populate_table
import sqlite3
from jesse_custom_code.pandas_file import database_path as d_path
import os
# import random

DB_FILE = d_path




# --- 1. Create a fresh database file ---
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)
    print(f"Removed old database. Creating {DB_FILE}...")

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

# --- 2. Create the 'Employees' table ---
# Our main employee list (50 employees)
create_and_populate_table(
    conn=conn, 
    table_name="Employees",
    primary_key="emp_id",
    column_names={
        "emp_id": ["INTEGER", "serial"], # 1-50
        "name": ["TEXT NOT NULL", "rand_name"],
        "dept_code": ["INTEGER", "rand_intg"]
    },
    group={"name": "f", "dept_code": [101, 104]}, # Depts 101-104
    num_entries=50
)

# --- 3. Create the 'Contractors' table ---
# Our separate contractor list (25 contractors)
# Note the different column names!
create_and_populate_table(
    conn=conn,
    table_name="Contractors",
    primary_key="contractor_id",
    column_names={
        "contractor_id": ["INTEGER", "serial"], # 1-25
        "full_name": ["TEXT NOT NULL", "rand_name"],
        "dept_code": ["INTEGER", "rand_intg"]
    },
    group={"full_name": "f", "dept_code": [103, 106]}, # Depts 103-106
    num_entries=25
)

# --- 4. Create the 'Departments' table ---
# This is our "lookup" table for department names.
create_and_populate_table(
    conn=conn,
    table_name="Departments",
    primary_key="department_id",
    column_names={
        "department_id": ["INTEGER", "serial"], # 1-5
        "department_name": ["TEXT", "rand_ch"]
    },
    group={"department_name": ['Engineering', 'Marketing', 'Sales', 'Operations', 'Finance']},
    num_entries=5
)
# Manually set the department IDs to match 101-105
cursor.execute("UPDATE Departments SET department_id = department_id + 100;")
conn.commit()

# --- 5. Create the 'Bonuses' table ---
# This table is *DESIGNED* to be joined on its index.
# It matches the main 'Employees' table (IDs 1-50)
create_and_populate_table(
    conn=conn,
    table_name="Bonuses",
    primary_key="employee_id", # The key is the employee_id
    column_names={
        "employee_id": ["INTEGER", "serial"], # 1-50
        "annual_bonus": ["REAL", "rand_intg"]
    },
    group={"annual_bonus": ["f", 500, 5000]},
    num_entries=50
)

# --- 6. Create the 'Work_Logs' table ---
# A big log of 500 activities
create_and_populate_table(
    conn=conn,
    table_name="Work_Logs",
    primary_key="log_id",
    column_names={
        "log_id": ["INTEGER", "serial"],
        "person_id": ["INTEGER", "rand_intg"], # Will match some Employees/Contractors
        "project_name": ["TEXT", "rand_ch"],
        "task_code": ["TEXT", "rand_ch"],
        "duration_hours": ["REAL", "rand_intg"],
        "status": ["TEXT", "rand_ch"]
    },
    group={
        "person_id": [1, 75], # Covers both emp_ids and contractor_ids
        "project_name": ['Project_A_Alpha', 'Project_A_Beta', 'Project_B_Gamma', 'Project_C_Delta'],
        "task_code": ['T-10', 'T-20', 'T-30', 'T-40', 'T-50'],
        "duration_hours": ["f", 1, 10],
        "status": ['Complete', 'Pending', 'High']
    },
    num_entries=500
)
# Manually make some task_codes NULL
cursor.execute("""
    UPDATE Work_Logs
    SET task_code = NULL
    WHERE log_id % 10 = 0;
""")
conn.commit()

conn.close()
print(f"\n--- Database {DB_FILE} is ready! (5 tables) ---")