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

# --- 2. Create the 'sales' table ---
# This table is perfect for sorting and date analysis.
create_and_populate_table(
    conn=conn,
    table_name="sales",
    primary_key="Order ID",
    column_names={
        "Order ID": ["INTEGER", "serial"],
        "Store": ["TEXT", "rand_ch"],
        "Product": ["TEXT", "rand_ch"],
        "Sales": ["REAL", "rand_intg"],
        "Sale Date": ["TEXT", "date"] # Note: 'TEXT' is the type
    },
    group={
        "Store": ['Store_A', 'Store_B', 'Store_C'],
        "Product": ['Apples', 'Oranges', 'Bananas'],
        "Sales": ["f", 5, 500],
        "Sale Date": [] # 'date' type doesn't need a group
    },

    num_entries = 593
)

conn.close()
print(f"\n--- Database {DB_FILE} is ready! ---")