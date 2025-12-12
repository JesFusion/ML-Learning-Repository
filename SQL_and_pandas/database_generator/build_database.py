import random
import string
import names
from datetime import datetime, timedelta
from sqlalchemy import create_engine, text
import pandas as pd
from jesse_custom_code.pandas_file import postgre_connect


class PSQLDataGenerator:
    """
    An enterprise-grade class to generate random data directly into PostgreSQL.
    """
    
    def __init__(self, connection_string):
        try:
            self.engine = create_engine(connection_string)
            with self.engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            print("Successfully connected to the PostgreSQL Database!")
        except Exception as e:
            print(f"Connection Failed. Error: {e}")
            raise

    # --- HELPER METHODS ---
    def _random_date(self, start_year=2020, end_year=2024):
        start = datetime(start_year, 1, 1)
        end = datetime(end_year, 12, 31)
        delta = end - start
        random_days = random.randint(0, delta.days)
        return (start + timedelta(days=random_days)).strftime('%Y-%m-%d')

    def _random_string(self, length):
        characters = string.ascii_letters + string.digits
        return ''.join(random.choices(characters, k=length))

    # --- CORE METHOD: GENERATE TABLE ---
    def create_and_populate_table(self, table_name, primary_key, column_config, groups, num_entries=50):
        print(f"\n--- Processing Table: {table_name} ---")

        # 1. Construct the CREATE TABLE statement
        cols_sql = []
        
        for col_name, (sql_type, gen_type) in column_config.items():
            safe_col = f'"{col_name}"' 
            
            if col_name == primary_key:
                if gen_type == 'serial':
                    cols_sql.append(f"{safe_col} SERIAL PRIMARY KEY")
                else:
                    cols_sql.append(f"{safe_col} {sql_type} PRIMARY KEY")
            else:
                cols_sql.append(f"{safe_col} {sql_type}")

        create_query = f"""
        DROP TABLE IF EXISTS "{table_name}";
        CREATE TABLE "{table_name}" (
            {', '.join(cols_sql)}
        );
        """

        with self.engine.begin() as conn:
            conn.execute(text(create_query))
        
        print("   -> Table structure created.")

        # 2. Generate Data Rows
        rows_to_insert = []
        
        for i in range(1, num_entries + 1):
            row = {}
            for col_name, (sql_type, gen_type) in column_config.items():
                
                # Logic to handle range definitions
                if " " in str(gen_type):
                    parts = str(gen_type).split(" ", 1)
                    if parts[0].isdigit():
                        amount = int(parts[0])
                        actual_type = parts[1]
                    else:
                        amount = 0
                        actual_type = gen_type
                else:
                    amount = 0
                    actual_type = gen_type

                val = None

                if actual_type == 'serial':
                    continue 

                elif actual_type == 'date':
                    val = self._random_date()

                elif actual_type == 'rand_name':
                    mode = groups.get(col_name, 'full')
                    if mode == 'f':
                        val = names.get_first_name()
                    elif mode == 'l':
                        val = names.get_last_name()
                    else:
                        val = names.get_full_name()

                elif actual_type == 'rand_str':
                    val = self._random_string(amount if amount > 0 else 8)

                elif actual_type == 'rand_ch':
                    choices = groups.get(col_name, [])
                    val = random.choice(choices) if choices else None

                elif actual_type == 'rand_intg':
                    constraints = groups.get(col_name)
                    if constraints:
                        if str(constraints[0]) == 'f':
                            val = round(random.uniform(constraints[1], constraints[2]), 2)
                        else:
                            val = random.randint(constraints[0], constraints[1])
                    else:
                        val = 0

                elif actual_type == 'prefixed_id':
                    prefix = groups.get(col_name, 'id')
                    unique_part = self._random_string(8)
                    val = f"{prefix}_{unique_part}"

                row[col_name] = val
            
            rows_to_insert.append(row)

        # --- 3. Bulk Insert (FIXED: Handling Spaces in Column Names) ---
        if rows_to_insert:
            # We need two mappings:
            # 1. The Real Column Name (for SQL) -> "Dept ID"
            # 2. The Safe Bind Parameter (for Python) -> "Dept_ID"
            
            # Map original keys to safe keys (replace spaces with underscores)
            col_map = {orig: orig.replace(" ", "_") for orig in rows_to_insert[0].keys()}
            
            # Create a new list of dicts with the SAFE keys
            clean_rows = []
            for row in rows_to_insert:
                clean_row = {col_map[k]: v for k, v in row.items()}
                clean_rows.append(clean_row)

            # Build the query parts
            # col_part uses the REAL names: "Dept ID", "Budget"
            col_part = ", ".join([f'"{real_col}"' for real_col in col_map.keys()])
            
            # val_part uses the SAFE keys with colon prefix: :Dept_ID, :Budget
            val_part = ", ".join([f':{safe_key}' for safe_key in col_map.values()])
            
            insert_query = text(f'INSERT INTO "{table_name}" ({col_part}) VALUES ({val_part})')

            with self.engine.begin() as conn:
                conn.execute(insert_query, clean_rows)
        
        print(f"   -> Inserted {len(rows_to_insert)} rows.")


    # --- NEW FEATURE: COLUMN TRANSFER ---
    def inject_foreign_key_column(self, source_table, source_col, target_table, target_col_name):
        print(f"\n--- Injecting Foreign Key: {source_table}.{source_col} -> {target_table}.{target_col_name} ---")
        
        with self.engine.connect() as conn:
            # 1. Fetch valid IDs
            query = text(f'SELECT "{source_col}" FROM "{source_table}"')
            valid_ids = [row[0] for row in conn.execute(query)]
            
            if not valid_ids:
                print("Error: Source table is empty!")
                return

            # 2. Add column
            try:
                conn.execute(text(f'ALTER TABLE "{target_table}" ADD COLUMN "{target_col_name}" TEXT'))
                conn.commit()
                print(f"   -> Column '{target_col_name}' added.")
            except Exception as e:
                print(f"   -> Column likely exists, proceeding... ({e})")

            # 3. Update rows
            target_rows = conn.execute(text(f'SELECT ctid FROM "{target_table}"')).fetchall()
            
            updates = []
            for row in target_rows:
                random_id = random.choice(valid_ids)
                updates.append({'new_val': random_id, 'row_id': row[0]})
            
            print("   -> Assigning random relationships...")
            for update in updates:
                conn.execute(
                    text(f'UPDATE "{target_table}" SET "{target_col_name}" = :new_val WHERE ctid = :row_id'),
                    update
                )
            conn.commit()
            
        print("   -> Relationship injection complete.")


# ============================= EXECUTION =============================

if __name__ == '__main__':
    
    generator = PSQLDataGenerator(postgre_connect)

    # --- 1. Create 'Departments' ---
    generator.create_and_populate_table(
        table_name="Departments",
        primary_key="Dept ID",
        column_config={
            "Dept ID": ["TEXT", "prefixed_id"],
            "Dept Name": ["TEXT", "rand_ch"],
            "Budget": ["INTEGER", "rand_intg"]
        },
        groups={
            "Dept ID": "dep",
            "Dept Name": ["Engineering", "HR", "Sales", "Legal"],
            "Budget": [50000, 500000]
        },
        num_entries=4
    )

    # --- 2. Create 'Employees' ---
    generator.create_and_populate_table(
        table_name="Employees",
        primary_key="Emp ID",
        column_config={
            "Emp ID": ["TEXT", "prefixed_id"],
            "First Name": ["TEXT", "rand_name"],
            "Last Name": ["TEXT", "rand_name"],
            "Salary": ["INTEGER", "rand_intg"]
        },
        groups={
            "Emp ID": "emp",
            "First Name": "f",
            "Last Name": "l",
            "Salary": [60000, 150000]
        },
        num_entries=50
    )

    # --- 3. Link them! ---
    generator.inject_foreign_key_column(
        source_table="Departments", 
        source_col="Dept ID", 
        target_table="Employees", 
        target_col_name="department_id"
    )

    print("\n--- DONE! Check your PostgreSQL Database ---")