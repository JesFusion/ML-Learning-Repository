#!/usr/bin/env sh

# Exit immediately if a command fails
set -e

# Database connection details (matching your previous setup)
DB_NAME="devops_learning_database"
DB_USER="jesfusion"
DB_PASS="40825619673461"
SQL_FILE="$1"

# Export the password as an environment variable so psql doesn't prompt for it interactively
export PGPASSWORD="$DB_PASS"


# Run the SQL file using psql
# -h localhost : Forces a TCP/IP connection (needed for password authentication)
# -d           : Specifies the database name
# -U           : Specifies the database user
# -f           : Reads and executes commands from the specified file
psql -h localhost -d "$DB_NAME" -U "$DB_USER" -f "$SQL_FILE"

# Unset the password variable to prevent it from lingering in the environment
unset PGPASSWORD





























# for setting up psql on Linux
: << 'COMMENT'
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration for the new database and user
# Change these variables before running the script
DB_NAME="devops_learning_database"
DB_USER="jesfusion"
DB_PASS="40825619673461"

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root (use sudo)."
  exit 1
fi

echo "Starting PostgreSQL installation..."

# 2. Detect package manager and install
if command -v apt-get &> /dev/null; then
    echo "Detected Debian/Ubuntu system. Installing via APT..."
    export DEBIAN_FRONTEND=noninteractive
    # apt-get update
    apt-get install -y postgresql postgresql-contrib
elif command -v dnf &> /dev/null; then
    echo "Detected RHEL/Fedora/Rocky system. Installing via DNF..."
    dnf install -y postgresql-server postgresql-contrib
    echo "Initializing database cluster..."
    postgresql-setup --initdb
elif command -v yum &> /dev/null; then
    echo "Detected older RHEL/CentOS system. Installing via YUM..."
    yum install -y postgresql-server postgresql-contrib
    echo "Initializing database cluster..."
    postgresql-setup initdb
else
    echo "Error: Unsupported package manager. Could not install PostgreSQL."
    exit 1
fi

# 3. Enable and start the PostgreSQL service safely
echo "Starting PostgreSQL service..."
if [ -d /run/systemd/system ]; then
    systemctl enable postgresql
    systemctl start postgresql
else
    echo "systemd not detected. Using 'service' command..."
    service postgresql start
fi

# 4. Create a custom database and user
echo "Creating database: $DB_NAME and user: $DB_USER..."
# We use '|| true' on the user creation just in case you run this twice and the user already exists
su - postgres -c "psql -c \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';\"" || true
su - postgres -c "psql -c \"CREATE DATABASE $DB_NAME OWNER $DB_USER;\"" || true
su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;\""

echo "========================================"
echo "PostgreSQL setup completed successfully!"
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "========================================"
COMMENT


































# for vscode sql snippet
: << 'POSTGRESQL'
{
  "CREATE TABLE": {
    "prefix": "CREATE TABLE",
    "body": "CREATE TABLE ${1:table_name} (\n\t${2:column_name} ${3:data_type},\n\tPRIMARY KEY (${4:column_name})\n);",
    "description": "Create a new table with primary key"
  },
  "CREATE TABLE IF NOT EXISTS": {
    "prefix": "CREATE TABLE IF NOT EXISTS",
    "body": "CREATE TABLE IF NOT EXISTS ${1:table_name} (\n\t${2:column_name} ${3:data_type},\n\tPRIMARY KEY (${4:column_name})\n);",
    "description": "Create a new table only if it does not exist"
  },
  "CREATE TEMPORARY TABLE": {
    "prefix": "CREATE TEMPORARY TABLE",
    "body": "CREATE TEMPORARY TABLE ${1:table_name} (\n\t${2:column_name} ${3:data_type},\n\tPRIMARY KEY (${4:column_name})\n);",
    "description": "Create a temporary table for the current session"
  },
  "CREATE UNLOGGED TABLE": {
    "prefix": "CREATE UNLOGGED TABLE",
    "body": "CREATE UNLOGGED TABLE ${1:table_name} (\n\t${2:column_name} ${3:data_type},\n\tPRIMARY KEY (${4:column_name})\n);",
    "description": "Create an unlogged table for better performance"
  },
  "CREATE TABLE AS SELECT": {
    "prefix": "CREATE TABLE AS SELECT",
    "body": "CREATE TABLE ${1:new_table} AS\nSELECT ${2:*}\nFROM ${3:source_table}\nWHERE ${4:condition};",
    "description": "Create a table from the result of a SELECT query"
  },
  "ALTER TABLE ADD COLUMN": {
    "prefix": "ALTER TABLE ADD COLUMN",
    "body": "ALTER TABLE ${1:table_name}\nADD COLUMN ${2:column_name} ${3:data_type}${4: NOT NULL}${5: DEFAULT ${6:value}};",
    "description": "Add a new column to an existing table"
  },
  "ALTER TABLE DROP COLUMN": {
    "prefix": "ALTER TABLE DROP COLUMN",
    "body": "ALTER TABLE ${1:table_name}\nDROP COLUMN ${2:column_name};",
    "description": "Remove a column from a table"
  },
  "ALTER TABLE RENAME COLUMN": {
    "prefix": "ALTER TABLE RENAME COLUMN",
    "body": "ALTER TABLE ${1:table_name}\nRENAME COLUMN ${2:old_name} TO ${3:new_name};",
    "description": "Rename a column in a table"
  },
  "ALTER TABLE RENAME": {
    "prefix": "ALTER TABLE RENAME",
    "body": "ALTER TABLE ${1:old_table_name}\nRENAME TO ${2:new_table_name};",
    "description": "Rename a table"
  },
  "ALTER TABLE ADD CONSTRAINT": {
    "prefix": "ALTER TABLE ADD CONSTRAINT",
    "body": "ALTER TABLE ${1:table_name}\nADD CONSTRAINT ${2:constraint_name} ${3:UNIQUE|PRIMARY KEY|FOREIGN KEY}(${4:column_name});",
    "description": "Add a constraint to an existing table"
  },
  "ALTER TABLE DROP CONSTRAINT": {
    "prefix": "ALTER TABLE DROP CONSTRAINT",
    "body": "ALTER TABLE ${1:table_name}\nDROP CONSTRAINT ${2:constraint_name};",
    "description": "Remove a constraint from a table"
  },
  "ALTER TABLE ALTER COLUMN": {
    "prefix": "ALTER TABLE ALTER COLUMN",
    "body": "ALTER TABLE ${1:table_name}\nALTER COLUMN ${2:column_name} ${3:SET|DROP} ${4:DEFAULT ${5:value}|NOT NULL};",
    "description": "Modify column properties like default values or nullability"
  },
  "ALTER TABLE SET SCHEMA": {
    "prefix": "ALTER TABLE SET SCHEMA",
    "body": "ALTER TABLE ${1:table_name}\nSET SCHEMA ${2:schema_name};",
    "description": "Move a table to a different schema"
  },
  "DROP TABLE": {
    "prefix": "DROP TABLE",
    "body": "DROP TABLE ${1:table_name};",
    "description": "Delete a table and all its data"
  },
  "DROP TABLE IF EXISTS": {
    "prefix": "DROP TABLE IF EXISTS",
    "body": "DROP TABLE IF EXISTS ${1:table_name};",
    "description": "Delete a table only if it exists"
  },
  "DROP TABLE CASCADE": {
    "prefix": "DROP TABLE CASCADE",
    "body": "DROP TABLE ${1:table_name} CASCADE;",
    "description": "Delete a table and all objects that depend on it"
  },
  "CREATE VIEW": {
    "prefix": "CREATE VIEW",
    "body": "CREATE VIEW ${1:view_name} AS\nSELECT ${2:*}\nFROM ${3:table_name};",
    "description": "Create a virtual table based on a SELECT query"
  },
  "CREATE OR REPLACE VIEW": {
    "prefix": "CREATE OR REPLACE VIEW",
    "body": "CREATE OR REPLACE VIEW ${1:view_name} AS\nSELECT ${2:*}\nFROM ${3:table_name};",
    "description": "Create or replace an existing view"
  },
  "CREATE MATERIALIZED VIEW": {
    "prefix": "CREATE MATERIALIZED VIEW",
    "body": "CREATE MATERIALIZED VIEW ${1:view_name} AS\nSELECT ${2:*}\nFROM ${3:table_name};",
    "description": "Create a materialized view with physical data storage"
  },
  "DROP VIEW": {
    "prefix": "DROP VIEW",
    "body": "DROP VIEW ${1:view_name};",
    "description": "Delete a view"
  },
  "DROP VIEW CASCADE": {
    "prefix": "DROP VIEW CASCADE",
    "body": "DROP VIEW ${1:view_name} CASCADE;",
    "description": "Delete a view and all dependent objects"
  },
  "REFRESH MATERIALIZED VIEW": {
    "prefix": "REFRESH MATERIALIZED VIEW",
    "body": "REFRESH MATERIALIZED VIEW ${1:view_name};",
    "description": "Refresh a materialized view with new data"
  },
  "CREATE INDEX": {
    "prefix": "CREATE INDEX",
    "body": "CREATE INDEX ${1:index_name} ON ${2:table_name}(${3:column_name});",
    "description": "Create an index for faster queries on specific columns"
  },
  "CREATE UNIQUE INDEX": {
    "prefix": "CREATE UNIQUE INDEX",
    "body": "CREATE UNIQUE INDEX ${1:index_name} ON ${2:table_name}(${3:column_name});",
    "description": "Create a unique index that enforces uniqueness"
  },
  "CREATE INDEX CONCURRENTLY": {
    "prefix": "CREATE INDEX CONCURRENTLY",
    "body": "CREATE INDEX CONCURRENTLY ${1:index_name} ON ${2:table_name}(${3:column_name});",
    "description": "Create an index without blocking table writes"
  },
  "DROP INDEX": {
    "prefix": "DROP INDEX",
    "body": "DROP INDEX ${1:index_name};",
    "description": "Delete an index"
  },
  "DROP INDEX CONCURRENTLY": {
    "prefix": "DROP INDEX CONCURRENTLY",
    "body": "DROP INDEX CONCURRENTLY ${1:index_name};",
    "description": "Delete an index without blocking table reads"
  },
  "CREATE FUNCTION": {
    "prefix": "CREATE FUNCTION",
    "body": "CREATE FUNCTION ${1:function_name}(${2:parameter} ${3:data_type})\nRETURNS ${4:return_type} AS $$\nBEGIN\n\t${5:-- function body}\n\tRETURN ${6:value};\nEND;\n$$ LANGUAGE PLPGSQL;",
    "description": "Create a user-defined function"
  },
  "CREATE OR REPLACE FUNCTION": {
    "prefix": "CREATE OR REPLACE FUNCTION",
    "body": "CREATE OR REPLACE FUNCTION ${1:function_name}(${2:parameter} ${3:data_type})\nRETURNS ${4:return_type} AS $$\nBEGIN\n\t${5:-- function body}\n\tRETURN ${6:value};\nEND;\n$$ LANGUAGE PLPGSQL;",
    "description": "Create or replace an existing function"
  },
  "DROP FUNCTION": {
    "prefix": "DROP FUNCTION",
    "body": "DROP FUNCTION ${1:function_name}(${2:data_type});",
    "description": "Delete a function"
  },
  "CREATE TRIGGER": {
    "prefix": "CREATE TRIGGER",
    "body": "CREATE TRIGGER ${1:trigger_name}\n${2:BEFORE|AFTER} ${3:INSERT|UPDATE|DELETE} ON ${4:table_name}\nFOR EACH ${5:ROW|STATEMENT}\nEXECUTE FUNCTION ${6:function_name}();",
    "description": "Create a trigger that executes a function"
  },
  "DROP TRIGGER": {
    "prefix": "DROP TRIGGER",
    "body": "DROP TRIGGER ${1:trigger_name} ON ${2:table_name};",
    "description": "Delete a trigger from a table"
  },
  "CREATE SCHEMA": {
    "prefix": "CREATE SCHEMA",
    "body": "CREATE SCHEMA ${1:schema_name};",
    "description": "Create a new database schema"
  },
  "DROP SCHEMA": {
    "prefix": "DROP SCHEMA",
    "body": "DROP SCHEMA ${1:schema_name};",
    "description": "Delete a schema"
  },
  "DROP SCHEMA CASCADE": {
    "prefix": "DROP SCHEMA CASCADE",
    "body": "DROP SCHEMA ${1:schema_name} CASCADE;",
    "description": "Delete a schema and all objects it contains"
  },
  "CREATE DATABASE": {
    "prefix": "CREATE DATABASE",
    "body": "CREATE DATABASE ${1:database_name};",
    "description": "Create a new database"
  },
  "DROP DATABASE": {
    "prefix": "DROP DATABASE",
    "body": "DROP DATABASE ${1:database_name};",
    "description": "Delete a database"
  },
  "CREATE EXTENSION": {
    "prefix": "CREATE EXTENSION",
    "body": "CREATE EXTENSION ${1:extension_name};",
    "description": "Install an extension (e.g., uuid-ossp, pgcrypto)"
  },
  "DROP EXTENSION": {
    "prefix": "DROP EXTENSION",
    "body": "DROP EXTENSION ${1:extension_name};",
    "description": "Uninstall an extension"
  },
  "CREATE SEQUENCE": {
    "prefix": "CREATE SEQUENCE",
    "body": "CREATE SEQUENCE ${1:sequence_name}\n\tSTART WITH ${2:1}\n\tINCREMENT BY ${3:1};",
    "description": "Create a sequence for auto-incrementing values"
  },
  "DROP SEQUENCE": {
    "prefix": "DROP SEQUENCE",
    "body": "DROP SEQUENCE ${1:sequence_name};",
    "description": "Delete a sequence"
  },
  "SELECT": {
    "prefix": "SELECT",
    "body": "SELECT ${1:*}\nFROM ${2:table_name};",
    "description": "Query data from a table"
  },
  "SELECT DISTINCT": {
    "prefix": "SELECT DISTINCT",
    "body": "SELECT DISTINCT ${1:column_name}\nFROM ${2:table_name};",
    "description": "Query unique data from a table"
  },
  "SELECT WITH WHERE": {
    "prefix": "SELECT WHERE",
    "body": "SELECT ${1:*}\nFROM ${2:table_name}\nWHERE ${3:condition};",
    "description": "Query with a WHERE condition"
  },
  "SELECT WITH ORDER BY": {
    "prefix": "SELECT ORDER BY",
    "body": "SELECT ${1:*}\nFROM ${2:table_name}\nORDER BY ${3:column_name} ${4:ASC|DESC};",
    "description": "Query with sorting"
  },
  "SELECT WITH GROUP BY": {
    "prefix": "SELECT GROUP BY",
    "body": "SELECT ${1:column_name}${2:, COUNT(*)}\nFROM ${3:table_name}\nGROUP BY ${4:column_name};",
    "description": "Query with grouping"
  },
  "SELECT WITH HAVING": {
    "prefix": "SELECT HAVING",
    "body": "SELECT ${1:column_name}}${2:, COUNT(*)}\nFROM ${3:table_name}\nGROUP BY ${4:column_name}\nHAVING ${5:condition};",
    "description": "Query with HAVING clause for group filtering"
  },
  "SELECT WITH LIMIT": {
    "prefix": "SELECT LIMIT",
    "body": "SELECT ${1:*}\nFROM ${2:table_name}\nLIMIT ${3:number};",
    "description": "Query with row limit"
  },
  "SELECT WITH OFFSET": {
    "prefix": "SELECT OFFSET",
    "body": "SELECT ${1:*}\nFROM ${2:table_name}\nLIMIT ${3:number} OFFSET ${4:number};",
    "description": "Query with pagination (LIMIT and OFFSET)"
  },
  "SELECT JOIN INNER": {
    "prefix": "SELECT INNER JOIN",
    "body": "SELECT ${1:*}\nFROM ${2:table1}\nINNER JOIN ${3:table2} ON ${4:table1.id}} = ${5:table2.id}};",
    "description": "Query with INNER JOIN between tables"
  },
  "SELECT JOIN LEFT": {
    "prefix": "SELECT LEFT JOIN",
    "body": "SELECT ${1:*}\nFROM ${2:table1}\nLEFT JOIN ${3:table2} ON ${4:table1.id}} = ${5:table2.id}};",
    "description": "Query with LEFT JOIN"
  },
  "SELECT JOIN RIGHT": {
    "prefix": "SELECT RIGHT JOIN",
    "body": "SELECT ${1:*}\nFROM ${2:table1}\nRIGHT JOIN ${3:table2} ON ${4:table1.id}} = ${5:table2.id}};",
    "description": "Query with RIGHT JOIN"
  },
  "SELECT JOIN FULL OUTER": {
    "prefix": "SELECT FULL OUTER JOIN",
    "body": "SELECT ${1:*}\nFROM ${2:table1}\nFULL OUTER JOIN ${3:table2} ON ${4:table1.id}} = ${5:table2.id}};",
    "description": "Query with FULL OUTER JOIN"
  },
  "SELECT CROSS JOIN": {
    "prefix": "SELECT CROSS JOIN",
    "body": "SELECT ${1:*}\nFROM ${2:table1}\nCROSS JOIN ${3:table2};",
    "description": "Query with CROSS JOIN (Cartesian product)"
  },
  "SELECT UNION": {
    "prefix": "SELECT UNION",
    "body": "SELECT ${1:column_name}} FROM ${2:table1}\nUNION\nSELECT ${3:column_name}} FROM ${4:table2};",
    "description": "Combine results from multiple queries"
  },
  "SELECT UNION ALL": {
    "prefix": "SELECT UNION ALL",
    "body": "SELECT ${1:column_name}} FROM ${2:table1}\nUNION ALL\nSELECT ${3:column_name}} FROM ${4:table2};",
    "description": "Combine results including duplicates"
  },
  "SELECT INTERSECT": {
    "prefix": "SELECT INTERSECT",
    "body": "SELECT ${1:column_name}} FROM ${2:table1}\nINTERSECT\nSELECT ${3:column_name}} FROM ${4:table2};",
    "description": "Find common rows between queries"
  },
  "SELECT EXCEPT": {
    "prefix": "SELECT EXCEPT",
    "body": "SELECT ${1:column_name}} FROM ${2:table1}\nEXCEPT\nSELECT ${3:column_name}} FROM ${4:table2};",
    "description": "Find rows in first query but not in second"
  },
  "SELECT SUBQUERY": {
    "prefix": "SELECT SUBQUERY",
    "body": "SELECT ${1:*}\nFROM (SELECT ${2:*} FROM ${3:table_name} WHERE ${4:condition}}) AS ${5:subquery_alias};",
    "description": "Query using a subquery"
  },
  "SELECT CASE WHEN": {
    "prefix": "SELECT CASE WHEN",
    "body": "SELECT ${1:column_name}},\n\tCASE\n\t\tWHEN ${2:condition}} THEN ${3:value}}\n\t\tELSE ${4:default_value}}\n\tEND AS ${5:alias}}\nFROM ${6:table_name}};",
    "description": "Query with conditional CASE WHEN logic"
  },
  "SELECT WITH CTE": {
    "prefix": "SELECT WITH CTE",
    "body": "WITH ${1:cte_name}} AS (\n\tSELECT ${2:*} FROM ${3:table_name}} WHERE ${4:condition}}\n)\nSELECT ${5:*}} FROM ${1:cte_name}};",
    "description": "Query using Common Table Expression (CTE)"
  },
  "SELECT WITH RECURSIVE CTE": {
    "prefix": "SELECT WITH RECURSIVE CTE",
    "body": "WITH RECURSIVE ${1:cte_name}} AS (\n\tSELECT ${2:base_case_columns}} FROM ${3:table_name}} WHERE ${4:base_condition}}\n\tUNION\n\tSELECT ${5:recursive_columns}} FROM ${1:cte_name}} WHERE ${6:recursive_condition}}\n)\nSELECT ${7:*}} FROM ${1:cte_name}};",
    "description": "Recursive CTE for hierarchical queries"
  },
  "SELECT COUNT": {
    "prefix": "SELECT COUNT",
    "body": "SELECT COUNT(${1:*})\nFROM ${2:table_name}};",
    "description": "Count rows in a table"
  },
  "SELECT SUM": {
    "prefix": "SELECT SUM",
    "body": "SELECT SUM(${1:column_name}})\nFROM ${2:table_name}};",
    "description": "Sum numeric values in a column"
  },
  "SELECT AVG": {
    "prefix": "SELECT AVG",
    "body": "SELECT AVG(${1:column_name}})\nFROM ${2:table_name}};",
    "description": "Calculate average of numeric values"
  },
  "SELECT MIN": {
    "prefix": "SELECT MIN",
    "body": "SELECT MIN(${1:column_name}})\nFROM ${2:table_name}};",
    "description": "Find minimum value in a column"
  },
  "SELECT MAX": {
    "prefix": "SELECT MAX",
    "body": "SELECT MAX(${1:column_name}})\nFROM ${2:table_name}};",
    "description": "Find maximum value in a column"
  },
  "INSERT INTO": {
    "prefix": "INSERT INTO",
    "body": "INSERT INTO ${1:table_name}} (${2:column1}}, ${3:column2}})\nVALUES (${4:value1}}, ${5:value2}});",
    "description": "Insert a single row into a table"
  },
  "INSERT INTO SELECT": {
    "prefix": "INSERT INTO SELECT",
    "body": "INSERT INTO ${1:table_name}} (${2:column_list}})\nSELECT ${3:columns}} FROM ${4:source_table}} WHERE ${5:condition}};",
    "description": "Insert rows from a SELECT query"
  },
  "INSERT INTO MULTIPLE": {
    "prefix": "INSERT INTO MULTIPLE",
    "body": "INSERT INTO ${1:table_name}} (${2:column1}}, ${3:column2}})\nVALUES\n\t(${4:value1}}, ${5:value2}}),\n\t(${6:value3}}, ${7:value4}});",
    "description": "Insert multiple rows in one statement"
  },
  "INSERT ON CONFLICT": {
    "prefix": "INSERT ON CONFLICT",
    "body": "INSERT INTO ${1:table_name}} (${2:column_list}})\nVALUES (${3:values}})\nON CONFLICT (${4:column_name}}) DO UPDATE SET ${5:column}} = EXCLUDED.${6:column}};",
    "description": "Insert with UPSERT on conflict"
  },
  "INSERT ON CONFLICT DO NOTHING": {
    "prefix": "INSERT ON CONFLICT DO NOTHING",
    "body": "INSERT INTO ${1:table_name}} (${2:column_list}})\nVALUES (${3:values}})\nON CONFLICT DO NOTHING;",
    "description": "Insert and ignore if conflict occurs"
  },
  "UPDATE": {
    "prefix": "UPDATE",
    "body": "UPDATE ${1:table_name}}\nSET ${2:column_name}} = ${3:value}}\nWHERE ${4:condition}};",
    "description": "Update rows in a table"
  },
  "UPDATE MULTIPLE": {
    "prefix": "UPDATE MULTIPLE",
    "body": "UPDATE ${1:table_name}}\nSET\n\t${2:column1}} = ${3:value1}},\n\t${4:column2}} = ${5:value2}}\nWHERE ${6:condition}};",
    "description": "Update multiple columns at once"
  },
  "UPDATE FROM": {
    "prefix": "UPDATE FROM",
    "body": "UPDATE ${1:table1}}\nSET ${2:column}} = ${3:table2.column}}\nFROM ${4:table2}}\nWHERE ${1:table1}}.${5:id}} = ${4:table2}}.${6:id}};",
    "description": "Update using values from another table"
  },
  "DELETE FROM": {
    "prefix": "DELETE FROM",
    "body": "DELETE FROM ${1:table_name}}\nWHERE ${2:condition}};",
    "description": "Delete rows from a table"
  },
  "DELETE FROM TRUNCATE": {
    "prefix": "TRUNCATE TABLE",
    "body": "TRUNCATE TABLE ${1:table_name}} ${2:CASCADE}};",
    "description": "Delete all rows from a table (faster than DELETE)"
  },
  "BEGIN TRANSACTION": {
    "prefix": "BEGIN",
    "body": "BEGIN;",
    "description": "Start a transaction"
  },
  "COMMIT": {
    "prefix": "COMMIT",
    "body": "COMMIT;",
    "description": "Commit a transaction"
  },
  "ROLLBACK": {
    "prefix": "ROLLBACK",
    "body": "ROLLBACK;",
    "description": "Rollback a transaction"
  },
  "SAVEPOINT": {
    "prefix": "SAVEPOINT",
    "body": "SAVEPOINT ${1:savepoint_name}};",
    "description": "Create a savepoint within a transaction"
  },
  "ROLLBACK TO SAVEPOINT": {
    "prefix": "ROLLBACK TO SAVEPOINT",
    "body": "ROLLBACK TO SAVEPOINT ${1:savepoint_name}};",
    "description": "Rollback to a savepoint"
  },
  "GRANT": {
    "prefix": "GRANT",
    "body": "GRANT ${1:SELECT|INSERT|UPDATE|DELETE|EXECUTE}} ON ${2:table_name}} TO ${3:user_name}};",
    "description": "Grant privileges to a user"
  },
  "GRANT ALL": {
    "prefix": "GRANT ALL",
    "body": "GRANT ALL PRIVILEGES ON ${1:table_name}} TO ${2:user_name}};",
    "description": "Grant all privileges to a user"
  },
  "REVOKE": {
    "prefix": "REVOKE",
    "body": "REVOKE ${1:SELECT|INSERT|UPDATE|DELETE}} ON ${2:table_name}} FROM ${3:user_name}};",
    "description": "Revoke privileges from a user"
  },
  "REVOKE ALL": {
    "prefix": "REVOKE ALL",
    "body": "REVOKE ALL PRIVILEGES ON ${1:table_name}} FROM ${2:user_name}};",
    "description": "Revoke all privileges from a user"
  },
  "CREATE USER": {
    "prefix": "CREATE USER",
    "body": "CREATE USER ${1:username}} WITH PASSWORD '${2:password}}';",
    "description": "Create a database user"
  },
  "CREATE ROLE": {
    "prefix": "CREATE ROLE",
    "body": "CREATE ROLE ${1:role_name}};",
    "description": "Create a role (similar to user)"
  },
  "ALTER USER": {
    "prefix": "ALTER USER",
    "body": "ALTER USER ${1:username}} WITH PASSWORD '${2:password}}';",
    "description": "Modify a user"
  },
  "DROP USER": {
    "prefix": "DROP USER",
    "body": "DROP USER ${1:username}};",
    "description": "Delete a user"
  },
  "DROP ROLE": {
    "prefix": "DROP ROLE",
    "body": "DROP ROLE ${1:role_name}};",
    "description": "Delete a role"
  },
  "DISTINCT ON": {
    "prefix": "DISTINCT ON",
    "body": "SELECT DISTINCT ON (${1:column_name}}) ${2:*}}\nFROM ${3:table_name}}\nORDER BY ${1:column_name}}${4:, other_column}};",
    "description": "Select distinct rows based on specific column"
  },
  "WINDOW FUNCTION ROW_NUMBER": {
    "prefix": "ROW_NUMBER",
    "body": "SELECT ROW_NUMBER() OVER (PARTITION BY ${1:column}} ORDER BY ${2:column}}) AS rn, ${3:*}}\nFROM ${4:table_name}};",
    "description": "Window function for row numbering"
  },
  "WINDOW FUNCTION RANK": {
    "prefix": "RANK",
    "body": "SELECT RANK() OVER (ORDER BY ${1:column}} DESC) AS rank, ${2:*}}\nFROM ${3:table_name}};",
    "description": "Window function for ranking with gaps"
  },
  "WINDOW FUNCTION DENSE_RANK": {
    "prefix": "DENSE_RANK",
    "body": "SELECT DENSE_RANK() OVER (ORDER BY ${1:column}} DESC) AS dense_rank, ${2:*}}\nFROM ${3:table_name}};",
    "description": "Window function for ranking without gaps"
  },
  "WINDOW FUNCTION LAG": {
    "prefix": "LAG",
    "body": "SELECT LAG(${1:column}}) OVER (ORDER BY ${2:order_column}}) AS previous_value, ${3:*}}\nFROM ${4:table_name}};",
    "description": "Window function to access previous row value"
  },
  "WINDOW FUNCTION LEAD": {
    "prefix": "LEAD",
    "body": "SELECT LEAD(${1:column}}) OVER (ORDER BY ${2:order_column}}) AS next_value, ${3:*}}\nFROM ${4:table_name}};",
    "description": "Window function to access next row value"
  },
  "LIKE PATTERN": {
    "prefix": "LIKE",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} LIKE '${4:%pattern%}}';}",
    "description": "Pattern matching with LIKE"
  },
  "ILIKE PATTERN": {
    "prefix": "ILIKE",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} ILIKE '${4:%pattern%}}';}",
    "description": "Case-insensitive pattern matching"
  },
  "IN OPERATOR": {
    "prefix": "IN",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} IN (${4:value1}}, ${5:value2}}, ${6:value3}});",
    "description": "Check if value is in a list"
  },
  "BETWEEN OPERATOR": {
    "prefix": "BETWEEN",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} BETWEEN ${4:value1}} AND ${5:value2}};",
    "description": "Check if value is between two values"
  },
  "IS NULL": {
    "prefix": "IS NULL",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} IS NULL;",
    "description": "Check for NULL values"
  },
  "IS NOT NULL": {
    "prefix": "IS NOT NULL",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:column}} IS NOT NULL;",
    "description": "Check for non-NULL values"
  },
  "EXISTS": {
    "prefix": "EXISTS",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}} t1\nWHERE EXISTS (SELECT 1 FROM ${3:table_name2}} t2 WHERE t1.${4:id}} = t2.${5:id}});",
    "description": "Check if subquery returns any rows"
  },
  "NOT EXISTS": {
    "prefix": "NOT EXISTS",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}} t1\nWHERE NOT EXISTS (SELECT 1 FROM ${3:table_name2}} WHERE ${4:condition}});",
    "description": "Check if subquery returns no rows"
  },
  "CAST": {
    "prefix": "CAST",
    "body": "SELECT CAST(${1:column}} AS ${2:INTEGER|VARCHAR|DATE|NUMERIC}}) AS ${3:alias}}\nFROM ${4:table_name}};",
    "description": "Convert column to different data type"
  },
  "COALESCE": {
    "prefix": "COALESCE",
    "body": "SELECT COALESCE(${1:column1}}, ${2:column2}}, ${3:default_value}}) AS ${4:alias}}\nFROM ${5:table_name}};",
    "description": "Return first non-NULL value"
  },
  "NULLIF": {
    "prefix": "NULLIF",
    "body": "SELECT NULLIF(${1:column1}}, ${2:column2}}) AS ${3:alias}}\nFROM ${4:table_name}};",
    "description": "Return NULL if two values are equal"
  },
  "GREATEST": {
    "prefix": "GREATEST",
    "body": "SELECT GREATEST(${1:column1}}, ${2:column2}}, ${3:column3}}) AS ${4:max_value}}\nFROM ${5:table_name}};",
    "description": "Return greatest value from multiple columns"
  },
  "LEAST": {
    "prefix": "LEAST",
    "body": "SELECT LEAST(${1:column1}}, ${2:column2}}, ${3:column3}}) AS ${4:min_value}}\nFROM ${5:table_name}};",
    "description": "Return least value from multiple columns"
  },
  "STRING_AGG": {
    "prefix": "STRING_AGG",
    "body": "SELECT STRING_AGG(${1:column}}, '${2:,}}') AS ${3:concatenated}}\nFROM ${4:table_name}}\nGROUP BY ${5:group_column}};",
    "description": "Aggregate strings with delimiter"
  },
  "ARRAY_AGG": {
    "prefix": "ARRAY_AGG",
    "body": "SELECT ARRAY_AGG(${1:column}}) AS ${2:array_column}}\nFROM ${3:table_name}}\nGROUP BY ${4:group_column}};",
    "description": "Aggregate values into array"
  },
  "JSONB OPERATORS": {
    "prefix": "JSONB",
    "body": "SELECT ${1:jsonb_column}} -> '${2:key}}' AS ${3:value}}\nFROM ${4:table_name}}\nWHERE ${1:jsonb_column}} @> '${5:{\"key\": \"value\"}}}}'::jsonb;",
    "description": "Query JSONB data type"
  },
  "ARRAY SUBSCRIPT": {
    "prefix": "ARRAY SUBSCRIPT",
    "body": "SELECT ${1:array_column}}[${2:1}}] AS ${3:first_element}}\nFROM ${4:table_name}};",
    "description": "Access array element by index"
  },
  "RANGE OPERATORS": {
    "prefix": "RANGE OPERATORS",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:range_column}} @> '${4:[1,5)}}' ::int4range;",
    "description": "Query range data types"
  },
  "EXTRACT": {
    "prefix": "EXTRACT",
    "body": "SELECT EXTRACT(${1:YEAR|MONTH|DAY|HOUR|MINUTE}} FROM ${2:date_column}}) AS ${3:value}}\nFROM ${4:table_name}};",
    "description": "Extract part of a date/timestamp"
  },
  "DATE_PART": {
    "prefix": "DATE_PART",
    "body": "SELECT DATE_PART('${1:year|month|day}}', ${2:date_column}}) AS ${3:value}}\nFROM ${4:table_name}};",
    "description": "Extract part of a date/timestamp"
  },
  "DATE_TRUNC": {
    "prefix": "DATE_TRUNC",
    "body": "SELECT DATE_TRUNC('${1:hour|day|month}}', ${2:timestamp_column}}) AS ${3:truncated}}\nFROM ${4:table_name}};",
    "description": "Truncate timestamp to specified precision"
  },
  "NOW": {
    "prefix": "NOW",
    "body": "SELECT NOW() AS ${1:current_timestamp}};",
    "description": "Get current date and time"
  },
  "CURRENT_DATE": {
    "prefix": "CURRENT_DATE",
    "body": "SELECT CURRENT_DATE AS ${1:today}};",
    "description": "Get current date"
  },
  "CURRENT_TIME": {
    "prefix": "CURRENT_TIME",
    "body": "SELECT CURRENT_TIME AS ${1:current_time}};",
    "description": "Get current time"
  },
  "CURRENT_TIMESTAMP": {
    "prefix": "CURRENT_TIMESTAMP",
    "body": "SELECT CURRENT_TIMESTAMP AS ${1:current_timestamp}};",
    "description": "Get current timestamp"
  },
  "SUBSTRING": {
    "prefix": "SUBSTRING",
    "body": "SELECT SUBSTRING(${1:column}}, ${2:start}}, ${3:length}}) AS ${4:substring}}\nFROM ${5:table_name}};",
    "description": "Extract substring from string"
  },
  "UPPER": {
    "prefix": "UPPER",
    "body": "SELECT UPPER(${1:column}}) AS ${2:uppercase}}\nFROM ${3:table_name}};",
    "description": "Convert string to uppercase"
  },
  "LOWER": {
    "prefix": "LOWER",
    "body": "SELECT LOWER(${1:column}}) AS ${2:lowercase}}\nFROM ${3:table_name}};",
    "description": "Convert string to lowercase"
  },
  "TRIM": {
    "prefix": "TRIM",
    "body": "SELECT TRIM(${1:column}}) AS ${2:trimmed}}\nFROM ${3:table_name}};",
    "description": "Remove leading/trailing whitespace"
  },
  "LTRIM": {
    "prefix": "LTRIM",
    "body": "SELECT LTRIM(${1:column}}) AS ${2:trimmed}}\nFROM ${3:table_name}};",
    "description": "Remove leading whitespace"
  },
  "RTRIM": {
    "prefix": "RTRIM",
    "body": "SELECT RTRIM(${1:column}}) AS ${2:trimmed}}\nFROM ${3:table_name}};",
    "description": "Remove trailing whitespace"
  },
  "LENGTH": {
    "prefix": "LENGTH",
    "body": "SELECT LENGTH(${1:column}}) AS ${2:string_length}}\nFROM ${3:table_name}};",
    "description": "Get length of string"
  },
  "REPLACE": {
    "prefix": "REPLACE",
    "body": "SELECT REPLACE(${1:column}}, '${2:find}}', '${3:replace_with}}') AS ${4:replaced}}\nFROM ${5:table_name}};",
    "description": "Replace text in string"
  },
  "SPLIT_PART": {
    "prefix": "SPLIT_PART",
    "body": "SELECT SPLIT_PART(${1:column}}, '${2:delimiter}}', ${3:position}}) AS ${4:part}}\nFROM ${5:table_name}};",
    "description": "Split string and get part"
  },
  "CONCAT": {
    "prefix": "CONCAT",
    "body": "SELECT CONCAT(${1:column1}}, '${2:separator}}', ${3:column2}}) AS ${4:concatenated}}\nFROM ${5:table_name}};",
    "description": "Concatenate strings"
  },
  "CONCAT_WS": {
    "prefix": "CONCAT_WS",
    "body": "SELECT CONCAT_WS('${1:separator}}', ${2:column1}}, ${3:column2}}, ${4:column3}}) AS ${5:concatenated}}\nFROM ${6:table_name}};",
    "description": "Concatenate with separator"
  },
  "POSITION": {
    "prefix": "POSITION",
    "body": "SELECT POSITION('${1:substring}}' IN ${2:column}}) AS ${3:position}}\nFROM ${4:table_name}};",
    "description": "Find position of substring"
  },
  "ROUND": {
    "prefix": "ROUND",
    "body": "SELECT ROUND(${1:column}}, ${2:decimal_places}}) AS ${3:rounded}}\nFROM ${4:table_name}};",
    "description": "Round numeric value"
  },
  "CEILING": {
    "prefix": "CEILING",
    "body": "SELECT CEILING(${1:column}}) AS ${2:ceiling}}\nFROM ${3:table_name}};",
    "description": "Round up to nearest integer"
  },
  "FLOOR": {
    "prefix": "FLOOR",
    "body": "SELECT FLOOR(${1:column}}) AS ${2:floor}}\nFROM ${3:table_name}};",
    "description": "Round down to nearest integer"
  },
  "ABS": {
    "prefix": "ABS",
    "body": "SELECT ABS(${1:column}}) AS ${2:absolute}}\nFROM ${3:table_name}};",
    "description": "Get absolute value"
  },
  "POWER": {
    "prefix": "POWER",
    "body": "SELECT POWER(${1:base}}, ${2:exponent}}) AS ${3:result}}\nFROM ${4:table_name}};",
    "description": "Raise base to power"
  },
  "SQRT": {
    "prefix": "SQRT",
    "body": "SELECT SQRT(${1:column}}) AS ${2:square_root}}\nFROM ${3:table_name}};",
    "description": "Get square root"
  },
  "EXPLAIN": {
    "prefix": "EXPLAIN",
    "body": "EXPLAIN\nSELECT ${1:*}}\nFROM ${2:table_name}};",
    "description": "Analyze query execution plan"
  },
  "EXPLAIN ANALYZE": {
    "prefix": "EXPLAIN ANALYZE",
    "body": "EXPLAIN ANALYZE\nSELECT ${1:*}}\nFROM ${2:table_name}};",
    "description": "Analyze and execute query plan"
  },
  "VACUUM": {
    "prefix": "VACUUM",
    "body": "VACUUM ${1:table_name}};",
    "description": "Clean up table storage"
  },
  "VACUUM ANALYZE": {
    "prefix": "VACUUM ANALYZE",
    "body": "VACUUM ANALYZE ${1:table_name}};",
    "description": "Clean up and update statistics"
  },
  "ANALYZE": {
    "prefix": "ANALYZE",
    "body": "ANALYZE ${1:table_name}};",
    "description": "Update table statistics"
  },
  "REINDEX": {
    "prefix": "REINDEX",
    "body": "REINDEX TABLE ${1:table_name}};",
    "description": "Rebuild all indexes on table"
  },
  "LISTEN": {
    "prefix": "LISTEN",
    "body": "LISTEN ${1:channel_name}};",
    "description": "Listen to notifications"
  },
  "NOTIFY": {
    "prefix": "NOTIFY",
    "body": "NOTIFY ${1:channel_name}}, '${2:payload}}';",
    "description": "Send notification to channel"
  },
  "CONSTRAINT UNIQUE": {
    "prefix": "UNIQUE",
    "body": "UNIQUE (${1:column_name}})",
    "description": "Unique constraint definition"
  },
  "CONSTRAINT PRIMARY KEY": {
    "prefix": "PRIMARY KEY",
    "body": "PRIMARY KEY (${1:column_name}})",
    "description": "Primary key constraint"
  },
  "CONSTRAINT FOREIGN KEY": {
    "prefix": "FOREIGN KEY",
    "body": "FOREIGN KEY (${1:column}}) REFERENCES ${2:other_table}}(${3:column}})",
    "description": "Foreign key constraint"
  },
  "CONSTRAINT CHECK": {
    "prefix": "CHECK",
    "body": "CHECK (${1:condition}})",
    "description": "Check constraint"
  },
  "CONSTRAINT NOT NULL": {
    "prefix": "NOT NULL",
    "body": "NOT NULL",
    "description": "Not null constraint"
  },
  "CONSTRAINT DEFAULT": {
    "prefix": "DEFAULT",
    "body": "DEFAULT ${1:value}}",
    "description": "Default value constraint"
  },
  "COLUMN TYPE BIGINT": {
    "prefix": "BIGINT",
    "body": "BIGINT",
    "description": "64-bit integer data type"
  },
  "COLUMN TYPE INT": {
    "prefix": "INT",
    "body": "INT",
    "description": "32-bit integer data type"
  },
  "COLUMN TYPE SMALLINT": {
    "prefix": "SMALLINT",
    "body": "SMALLINT",
    "description": "16-bit integer data type"
  },
  "COLUMN TYPE NUMERIC": {
    "prefix": "NUMERIC",
    "body": "NUMERIC(${1:precision}}, ${2:scale}})",
    "description": "Exact numeric data type"
  },
  "COLUMN TYPE DECIMAL": {
    "prefix": "DECIMAL",
    "body": "DECIMAL(${1:precision}}, ${2:scale}})",
    "description": "Exact decimal data type"
  },
  "COLUMN TYPE REAL": {
    "prefix": "REAL",
    "body": "REAL",
    "description": "Single precision floating point"
  },
  "COLUMN TYPE DOUBLE PRECISION": {
    "prefix": "DOUBLE PRECISION",
    "body": "DOUBLE PRECISION",
    "description": "Double precision floating point"
  },
  "COLUMN TYPE VARCHAR": {
    "prefix": "VARCHAR",
    "body": "VARCHAR(${1:max_length}})",
    "description": "Variable character string"
  },
  "COLUMN TYPE CHAR": {
    "prefix": "CHAR",
    "body": "CHAR(${1:length}})",
    "description": "Fixed length character string"
  },
  "COLUMN TYPE TEXT": {
    "prefix": "TEXT",
    "body": "TEXT",
    "description": "Unlimited length text string"
  },
  "COLUMN TYPE BOOLEAN": {
    "prefix": "BOOLEAN",
    "body": "BOOLEAN",
    "description": "Boolean true/false data type"
  },
  "COLUMN TYPE DATE": {
    "prefix": "DATE",
    "body": "DATE",
    "description": "Date data type"
  },
  "COLUMN TYPE TIME": {
    "prefix": "TIME",
    "body": "TIME",
    "description": "Time of day data type"
  },
  "COLUMN TYPE TIMESTAMP": {
    "prefix": "TIMESTAMP",
    "body": "TIMESTAMP",
    "description": "Date and time data type"
  },
  "COLUMN TYPE TIMESTAMPTZ": {
    "prefix": "TIMESTAMPTZ",
    "body": "TIMESTAMP WITH TIME ZONE",
    "description": "Timestamp with timezone"
  },
  "COLUMN TYPE INTERVAL": {
    "prefix": "INTERVAL",
    "body": "INTERVAL",
    "description": "Time interval data type"
  },
  "COLUMN TYPE BYTEA": {
    "prefix": "BYTEA",
    "body": "BYTEA",
    "description": "Binary data type"
  },
  "COLUMN TYPE UUID": {
    "prefix": "UUID",
    "body": "UUID",
    "description": "Universally unique identifier"
  },
  "COLUMN TYPE JSON": {
    "prefix": "JSON",
    "body": "JSON",
    "description": "JSON data type"
  },
  "COLUMN TYPE JSONB": {
    "prefix": "JSONB",
    "body": "JSONB",
    "description": "Binary JSON data type"
  },
  "COLUMN TYPE ARRAY": {
    "prefix": "ARRAY",
    "body": "${1:data_type}}[]",
    "description": "Array data type"
  },
  "COLUMN TYPE ENUM": {
    "prefix": "ENUM",
    "body": "CREATE TYPE ${1:enum_name}} AS ENUM(${2:'value1'}}, ${3:'value2}});",
    "description": "Enumerated data type"
  },
  "COLUMN TYPE RANGE": {
    "prefix": "RANGE",
    "body": "${1:int4range|int8range|numrange|tsrange|tstzrange|daterange}}",
    "description": "Range data type"
  },
  "OPERATOR AND": {
    "prefix": "AND",
    "body": "AND",
    "description": "Logical AND operator"
  },
  "OPERATOR OR": {
    "prefix": "OR",
    "body": "OR",
    "description": "Logical OR operator"
  },
  "OPERATOR NOT": {
    "prefix": "NOT",
    "body": "NOT",
    "description": "Logical NOT operator"
  },
  "OPERATOR EQUAL": {
    "prefix": "=",
    "body": "=",
    "description": "Equality operator"
  },
  "OPERATOR NOT EQUAL": {
    "prefix": "!=",
    "body": "!=",
    "description": "Not equal operator"
  },
  "OPERATOR LESS THAN": {
    "prefix": "<",
    "body": "<",
    "description": "Less than operator"
  },
  "OPERATOR GREATER THAN": {
    "prefix": ">",
    "body": ">",
    "description": "Greater than operator"
  },
  "OPERATOR LESS THAN OR EQUAL": {
    "prefix": "<=",
    "body": "<=",
    "description": "Less than or equal operator"
  },
  "OPERATOR GREATER THAN OR EQUAL": {
    "prefix": ">=",
    "body": ">=",
    "description": "Greater than or equal operator"
  },
  "OPERATOR PLUS": {
    "prefix": "+",
    "body": "+",
    "description": "Addition operator"
  },
  "OPERATOR MINUS": {
    "prefix": "-",
    "body": "-",
    "description": "Subtraction operator"
  },
  "OPERATOR MULTIPLY": {
    "prefix": "*",
    "body": "*",
    "description": "Multiplication operator"
  },
  "OPERATOR DIVIDE": {
    "prefix": "/",
    "body": "/",
    "description": "Division operator"
  },
  "OPERATOR MODULO": {
    "prefix": "%",
    "body": "%",
    "description": "Modulo operator"
  },
  "OPERATOR POWER": {
    "prefix": "^",
    "body": "^",
    "description": "Power operator"
  },
  "OPERATOR CONCATENATE": {
    "prefix": "||",
    "body": "||",
    "description": "String concatenation operator"
  },
  "OPERATOR REGEX MATCH": {
    "prefix": "~",
    "body": "~",
    "description": "Regular expression match"
  },
  "OPERATOR REGEX NOT MATCH": {
    "prefix": "!~",
    "body": "!~",
    "description": "Regular expression not match"
  },
  "OPERATOR REGEX ICASE MATCH": {
    "prefix": "~*",
    "body": "~*",
    "description": "Case-insensitive regex match"
  },
  "OPERATOR REGEX ICASE NOT MATCH": {
    "prefix": "!~*",
    "body": "!~*",
    "description": "Case-insensitive regex not match"
  },
  "COLLATE": {
    "prefix": "COLLATE",
    "body": "COLLATE ${1:collation_name}}",
    "description": "Specify collation for string comparison"
  },
  "LATERAL": {
    "prefix": "LATERAL",
    "body": "LATERAL ${1:subquery}}",
    "description": "Allow subquery to reference earlier tables"
  },
  "OFFSET": {
    "prefix": "OFFSET",
    "body": "OFFSET ${1:number}}",
    "description": "Skip rows in result set"
  },
  "FETCH FIRST": {
    "prefix": "FETCH FIRST",
    "body": "FETCH FIRST ${1:number}} ROWS ONLY",
    "description": "Fetch limited number of rows"
  },
  "FETCH NEXT": {
    "prefix": "FETCH NEXT",
    "body": "FETCH NEXT ${1:number}} ROWS ONLY",
    "description": "Fetch next set of rows"
  },
  "FOR UPDATE": {
    "prefix": "FOR UPDATE",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:condition}}\nFOR UPDATE;",
    "description": "Lock rows for update"
  },
  "FOR SHARE": {
    "prefix": "FOR SHARE",
    "body": "SELECT ${1:*}}\nFROM ${2:table_name}}\nWHERE ${3:condition}}\nFOR SHARE;",
    "description": "Lock rows for shared access"
  },
  "NOWAIT": {
    "prefix": "NOWAIT",
    "body": "NOWAIT",
    "description": "Fail immediately if row locked"
  },
  "SKIP LOCKED": {
    "prefix": "SKIP LOCKED",
    "body": "SKIP LOCKED",
    "description": "Skip locked rows"
  },
  "GROUPING SETS": {
    "prefix": "GROUPING SETS",
    "body": "SELECT ${1:column1}}, ${2:column2}}, COUNT(*) \nFROM ${3:table_name}}\nGROUP BY GROUPING SETS ((${1:column1}}), (${2:column2}}), ());",
    "description": "Multiple groupings in single query"
  },
  "CUBE": {
    "prefix": "CUBE",
    "body": "SELECT ${1:column1}}, ${2:column2}}, COUNT(*)\nFROM ${3:table_name}}\nGROUP BY CUBE (${1:column1}}, ${2:column2}});",
    "description": "All possible grouping combinations"
  },
  "ROLLUP": {
    "prefix": "ROLLUP",
    "body": "SELECT ${1:column1}}, ${2:column2}}, COUNT(*)\nFROM ${3:table_name}}\nGROUP BY ROLLUP (${1:column1}}, ${2:column2}});",
    "description": "Hierarchical grouping from left to right"
  },
  "FILTER CLAUSE": {
    "prefix": "FILTER",
    "body": "SELECT COUNT(*) FILTER (WHERE ${1:condition}}) AS ${2:filtered_count}}\nFROM ${3:table_name}};",
    "description": "Filter aggregate function with condition"
  },
  "GENERATED ALWAYS": {
    "prefix": "GENERATED ALWAYS",
    "body": "${1:column_name}} ${2:data_type}} GENERATED ALWAYS AS (${3:expression}}) STORED",
    "description": "Generated column with stored expression"
  },
  "EXCLUDE CONSTRAINT": {
    "prefix": "EXCLUDE",
    "body": "EXCLUDE USING ${1:index_method}} (${2:column}} WITH ${3:operator}})",
    "description": "Exclusion constraint to prevent overlapping values"
  },
  "DEFERRABLE": {
    "prefix": "DEFERRABLE",
    "body": "DEFERRABLE INITIALLY ${1:IMMEDIATE|DEFERRED}}",
    "description": "Make constraint deferrable until end of transaction"
  },
  "VIEW WITH CHECK OPTION": {
    "prefix": "WITH CHECK OPTION",
    "body": "WITH ${1:LOCAL|CASCADED}} CHECK OPTION",
    "description": "Ensure inserted rows satisfy view condition"
  }
}
POSTGRESQL





















# for vscode user settings.json
: << 'SETTINGSJSON'
  "editor.tokenColorCustomizations": {
    "textMateRules": [
        {
            "scope": [
                "source.sql", 
                "entity.name",
                "variable",
                "meta.column.sql",
                "meta.table.sql"
            ],
            "settings": {
                "foreground": "#39aeb3"
            }
        }
    ]
}
SETTINGSJSON