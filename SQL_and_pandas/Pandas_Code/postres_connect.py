import pandas as pd
from sqlalchemy import create_engine

# --- STEP 1: DEFINE THE CONNECTION ---
# Format: postgresql+psycopg2://username:password@host:port/database_name
# Note: Replace 'secure_password' with the actual password you set earlier!
db_connection_str = 'postgresql+psycopg2://postgres:40825619673461@localhost:5432/postgres'
db_connection = create_engine(db_connection_str)

the_dataset = pd.read_sql(
    "SELECT * FROM startups",

    db_connection
)


print(the_dataset.head().to_markdown())


