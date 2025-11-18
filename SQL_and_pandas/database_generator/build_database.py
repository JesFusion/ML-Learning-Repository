import random
from datetime import datetime, timedelta
import string
import names
import sqlite3 # I added this import
import os # I added this to delete the old DB
from jesse_custom_code.pandas_file import database_path as d_path

# --- Helper Functions (No Changes) ---
# These were great, no changes needed.
def random_date(start_year=1991, end_year=2024):
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    delta = end - start
    random_days = random.randint(0, delta.days)
    return (start + timedelta(days=random_days)).strftime('%Y-%m-%d')


def random_string(length):
    characters = string.ascii_letters + string.digits  # a-z, A-Z, 0-9
    return ''.join(random.choices(characters, k=length))

# --- Main Generator Function (Refactored) ---

def create_and_populate_table(
    conn: sqlite3.Connection, # CHANGED: We now pass a live database connection
    primary_key: str,
    group: dict[str, list[str]],
    column_names: dict,
    table_name: str,
    num_entries: int = 29
    ):

    # Get a cursor from the passed-in connection
    cursor = conn.cursor()

    # --- 1. CREATE TABLE Logic ---
    
    # Drop the table if it already exists to start fresh
    cursor.execute(f"DROP TABLE IF EXISTS {table_name}")

    column_definitions = [] # CHANGED: We build a list of column definitions first
    CN_list = [] # CHANGED: We'll use this to build the column name tuple

    if " " in table_name:
        table_name = f"`{table_name}`"

    if primary_key not in column_names.keys():
        print("Error! Primary key not found!")
        return # Exit the function if PK is missing

    # adding column names and types to list
    for column_name, type_and_content in column_names.items():
        type_and_content = list(type_and_content)
        
        # Handle spaces in column names
        safe_column_name = f"`{column_name}`" if " " in column_name else column_name
        CN_list.append(safe_column_name) # Add the safe name for the INSERT tuple

        col_type = type_and_content[0]

        # if the column name was selected as to be the primary key, add "PRIMARY KEY"
        if column_name == primary_key:
            column_definitions.append(
                f"  {safe_column_name} {col_type} PRIMARY KEY"
            )
        else:
            column_definitions.append(
                f"  {safe_column_name} {col_type}"
            )

    # CHANGED: This is the fix for the trailing comma bug.
    # We join the list of definitions with a comma and newline.
    # This *guarantees* there is no comma after the last item.
    new_line = ''',
'''
    create_table_query = f"""
        CREATE TABLE {table_name} (
        {new_line.join(column_definitions)}
        );
    """
    # create_table_query = f"""
    #     CREATE TABLE {table_name} (
    #     {",".join(column_definitions)}
    #     );
    # """

    print("--- Generated CREATE TABLE Query ---")
    print(create_table_query)
    cursor.execute(create_table_query) # Execute the CREATE TABLE query


    # --- 2. INSERT Data Logic ---

    # CHANGED: We create a tuple of column names for the INSERT query
    CN_tuple = str(tuple(CN_list)).replace("'", "")
    
    # CHANGED: We create a list of placeholders (?) for safe insertion.
    # This scales to any number of columns.
    placeholders = ", ".join(["?"] * len(CN_list))
    
    insert_query = f"INSERT INTO {table_name} {CN_tuple} VALUES ({placeholders})"
    
    print("\n--- Generated INSERT Query ---")
    print(insert_query)

    all_rows = [] # CHANGED: We will collect all generated rows in this list

    for _ in range(num_entries): # Changed 'x' to '_' (common Python style)

        row_data = [] # This list will hold the data for a single row

        for col_name, type_and_content in column_names.items():

            type_and_content = list(type_and_content)
            c_type = ""
            amount = 0 # Default amount

            # Parsing logic (mostly unchanged, just cleaned up)
            if " " in str(type_and_content[1]):
                try:
                    amount_str, c_type = str(type_and_content[1]).split(" ", 1)
                    amount = int(amount_str)
                except ValueError:
                    print(f"Warning: Could not parse amount from '{type_and_content[1]}'")
                    c_type = str(type_and_content[1])
            else:
                c_type = str(type_and_content[1])
            
            # --- Data Generation (Logic is the same) ---
            # CHANGED: We just append the *raw Python data* to row_data.
            # We DON'T add quotes. sqlite3 will handle it. (Fixes Bug #2)

            if c_type == "date":
                row_data.append(random_date())

            elif c_type == "rand_name":
                name_type = group.get(col_name) # Simpler way to get from dict
                if name_type == "f":
                    row_data.append(names.get_first_name())
                elif name_type == "l":
                    row_data.append(names.get_last_name())
                else:
                    row_data.append(names.get_full_name())

            elif c_type == "rand_str":
                row_data.append(random_string(amount))

            elif c_type == "rand_ch":
                the_group = group.get(col_name)
                if the_group:
                    row_data.append(random.choice(the_group))
                else:
                    print(f"Error! List for column name '{col_name}' not found in group!")
                    row_data.append(None) # Add None as a placeholder

            elif c_type == "rand_intg":
                the_range = group.get(col_name)
                if the_range:
                    if str(the_range[0]) == "f": # Float
                        the_number = round(random.uniform(int(the_range[1]), int(the_range[2])), 2)
                        row_data.append(the_number)
                    else: # Integer
                        the_number = random.randint(int(the_range[0]), int(the_range[1]))
                        row_data.append(the_number)
                else:
                    row_data.append(None) # Add None
            
            # NEW: Added support for a simple auto-incrementing integer
            elif c_type == "serial":
                row_data.append(None) # Tell SQLite to auto-generate this

            else:
                row_data.append(None) # Default case
        
        all_rows.append(tuple(row_data)) # Add the completed row tuple to our master list

    # --- 3. Execute and Save ---
    # CHANGED: This is the new, safe, and fast way to insert all data.
    # 'executemany' takes our query and our list of row-tuples
    # and handles all data types, quoting, etc., for us.
    cursor.executemany(insert_query, all_rows)
    
    conn.commit() # Save all changes to the database

    print(f"\nSuccessfully created and populated table '{table_name}' with {num_entries} entries.")


# ============================= testing the code =============================

# This "if __name__ == '__main__':" block means this code will ONLY run
# when you execute this script directly (not when you import it)
if __name__ == '__main__':
    
    DB_FILE = d_path # This is our main database file

    # Delete the old file if it exists, so we start fresh
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    
    # This creates the file and opens the connection
    conn = sqlite3.connect(DB_FILE)

    # --- Table 1: Employees ---
    # This is your test case, slightly modified
    create_and_populate_table(
        conn=conn, # Pass the connection
        table_name="Employees",
        primary_key="Employee ID",
        
        column_names = {
            "Employee ID": ["INTEGER", "serial"], # Use our new SERIAL type
            "First Name": ["TEXT NOT NULL", "rand_name"],
            "Last Name": ["TEXT", "rand_name"],
            "Employee Age": ["INTEGER", "rand_intg"],
            "Salary": ["REAL", "rand_intg"],
            "Department": ["TEXT", "rand_ch"],
            "Position": ["TEXT", "rand_ch"],
            "Date of Employment": ["DATE", "date"]
        },
        
        group = {
            "Department": ['IT', 'Marketing', 'Operations', 'Design', 'HR'],
            "First Name": "f",
            "Last Name": "l",
            "Position": ['Software Engineer', 'Data Analyst', 'Project Manager', 'Designer', 'HR Specialist'],
            "Salary": ["f", 45000, 120000],
            "Employee Age": [23, 57]
        },
        
        num_entries=50 # Let's make a bit more data
    )

    # --- Table 2: Sales (for our pandas lessons) ---
    # We can use our script to create our 'sales' table!
    create_and_populate_table(
        conn=conn,
        table_name="sales",
        primary_key="Order ID",
        column_names={
            "Order ID": ["INTEGER", "serial"],
            "Store": ["TEXT", "rand_ch"],
            "Product": ["TEXT", "rand_ch"],
            "Sales": ["REAL", "rand_intg"],
            "Quantity": ["INTEGER", "rand_intg"],
            "Sale Date": ["DATE", "date"]
        },
        group={
            "Store": ['Store_A', 'Store_B', 'Store_C', 'Store_D'],
            "Product": ['Apples', 'Oranges', 'Bananas', 'Grapes', 'Milk'],
            "Sales": ["f", 5, 500],
            "Quantity": [1, 20],
            "Sale Date": [] # 'date' type doesn't need a group
        },
        num_entries=200 # 200 sales transactions
    )

    # Close the connection when all tables are built
    conn.close()

    print(f"\n--- All tables created in {DB_FILE} ---")
    print("You are all set up. You can now connect to this DB with SQLTools.")














































































































































# import random
# from datetime import datetime, timedelta
# import string
# import names

# def random_date(start_year = 1991, end_year = 2024):
#     start = datetime(start_year, 1, 1)
#     end = datetime(end_year, 12, 31)
#     delta = end - start
#     random_days = random.randint(0, delta.days)
#     return (start + timedelta(days=random_days)).strftime('%Y-%m-%d')


# def random_string(length):
#     characters = string.ascii_letters + string.digits  # a-z, A-Z, 0-9
#     return ''.join(random.choices(characters, k=length))



# # file_name = f"the_sql_file_{(random.randint(1, 100)) + random.randint(1, 100)}"
# file_name = "the_sql_file"
# # let's just use one file "the_sql_file", instead of creating new files each time. we'll just run the code to create the table on the database and delete it after

# def sql_file_gen(
#     primary_key: str,
#     group: dict[str, list[str]],
#     column_names = dict,
#     table_name: str = f"table_{str(random.randint(1, 100)) + str(random.randint(1, 100))}",
#     sql_file_name: str = file_name,
#     num_entries: int = 29
#     ):


#     table_creation_list, CN_tuple = [], []

#     # if there is no column name or primary key, raise an Error
#     if primary_key is None:

#         print("Error! Primary Key cannot be empty")
    
#     elif column_names is None:

#         print("Error! Column names cannot be empty")


#     # adding table name to list

#     if " " in table_name:

#         table_name = f"`{table_name}`"
    
#     table_creation_list.append(f"CREATE TABLE {table_name} (")


#     if primary_key not in column_names.keys():
#         print("Error! Primary key not found!")

        

#     # adding column names and types to list
#     for column_name, type_and_content in column_names.items():


#         # add the column name to a list, which will be converted to a tuple and used later


#         type_and_content = list(type_and_content)

#         # if the column name was selected as to be the primary key, add "PRIMARY KEY", else don't

#         if column_name == primary_key:

#             if " " in column_name:

#                 column_name = f"`{column_name}`"

#             table_creation_list.append(
#                 f"  {column_name} {type_and_content[0]} PRIMARY KEY,"
#                 )
            
#             CN_tuple.append(column_name)
            
#         else:

#             if " " in column_name:

#                 column_name = f"`{column_name}`"

            
#             table_creation_list.append(
#                 f"  {column_name} {type_and_content[0]},"
#                 )
#             # i need to fix the bug that makes the code write a comma on the last column
#             '''
#             for example:
            
#             CREATE TABLE `Sales Table` (
#             Store TEXT,
#             Product TEXT,
#             Sales INTEGER,
#             Quantity INTEGER,
#             );


#             The last column "Quantity" isn't meant to have a comma "," at the end, as this would cause an error
#             '''
#             CN_tuple.append(column_name)
            
        
#     table_creation_list.append(");")
#     table_creation_list.append('''




#     ''')


#     CN_tuple = str(tuple(CN_tuple)).replace("'", "")

#     table_creation_list.append(f"INSERT INTO {table_name} {CN_tuple} VALUES")



#     table_rows = []

#     for x in range(1, num_entries + 1):


#         for col_name, type_and_content in column_names.items():

#             type_and_content = list(type_and_content)


#             if " " in str(type_and_content[1]):

#                 amount, c_type = str(type_and_content[1]).split(" ", 1)

#                 try:
#                     amount = int(amount)

#                 except Exception as an_error:
#                     print(f"Cannot convert amount to a number. Check the error --> {an_error}")

#             else:

#                 c_type = str(type_and_content[1])


            
#             # assigning column types
            
#             the_range = []

#             if c_type == "date":
#                 dat_e = random_date()

#                 table_rows.append(dat_e)

            

#             elif c_type == "rand_name":


#                 if col_name in list(group.keys()):
                
#                     name_type = str(group.get(f"{col_name}"))

#                     if name_type == "f":

#                         the_name = names.get_first_name()

#                     elif name_type == "l":

#                         the_name = names.get_last_name()
                    
#                     else:

#                         continue
                    

#                 else:

#                     the_name = names.get_full_name()

#                 table_rows.append(the_name)




#             elif c_type == "rand_str":

#                 rand_str = random_string(amount)

#                 table_rows.append(rand_str)

            

#             elif c_type == "rand_ch":

#                 if col_name in list(group.keys()):

#                     the_group = list(group.get(f"{col_name}"))

#                 else:

#                     print("Error! List for column name not found in group!")

                
#                 rand_ch = random.choice(the_group)

#                 table_rows.append(rand_ch)
            

#             elif c_type == "rand_intg":

#                 the_number = 0


#                 if col_name in list(group.keys()):
                
#                     the_range = list(group.get(f"{col_name}"))

#                     if str(the_range[0]) == "f":

#                         the_number = round(random.uniform(int(the_range[1]), int(the_range[2])), 2)

#                     else:

#                         the_number = random.randint(int(the_range[0]), int(the_range[1]))
                    
#                     table_rows.append(the_number)

#                 else:

#                     continue

#             else:

#                 continue

        
#         table_rows = tuple(table_rows)

#         if x == num_entries:

#             table_creation_list.append(
#             f"  {table_rows};"
#             )

#         else:

#             table_creation_list.append(
#             f"  {table_rows},"
#             )

#         table_rows = []
    


#     file_path = r"C:\Users\USER\Documents\My Programs\Machine_Learning\Python Programs\jesseVirtualEnvs\.mainDog\python code\Libraries\SQL_and_pandas\database_generator\generated_sql_files"

#     with open(f"{file_path}\{sql_file_name}.sql", "w") as file:

#         file.write("\n".join(table_creation_list))

#     print(f"SQL file \"{sql_file_name}\" created successfully.\n")












# # ============================= testing the code =============================



# sql_file_gen(
#     # table_name = "jesse table",

#     primary_key = "the ID",
    
#     column_names = {
#     "the ID": ["TEXT", "7 rand_str"],
#     "First Name": ["TEXT NOT NULL", "rand_name"],
#     "Middle Name": ["TEXT", "rand_name"],
#     "Employee Age": ["INTEGER", "rand_intg"],
#     "Salary": ["REAL", "rand_intg"],
#     "Department": ["TEXT", "rand_ch"],
#     "Position": ["TEXT", "rand_ch"],
#     "Date of Employment": ["DATE", "date"]
#     },
    
#     group = {
#     "Department": ['IT', 'Marketing', 'Operations', 'Design', 'HR'],

#     "First Name": "f",

#     "Middle Name": "l",
    
#     "Position": ['Software Engineer', 'Data Analyst', 'Project Manager', 'Designer', 'HR Specialist'],

#     "Salary": ["f", 20000, 55000],

#     "Employee Age": [23, 57]
#     },
    
#     num_entries = 10)






