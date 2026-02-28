-- Data Definition Language

-- creating a new table
CREATE TABLE f_table(
    un_ID SERIAL PRIMARY KEY,

    the_name VARCHAR(15) NOT NULL,

    model_type VARCHAR(45),

    model_loss REAL,

    model_pushed BOOLEAN DEFAULT FALSE,

    creation_time TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);


CREATE TABLE model_logs(
    id_of_the_log SERIAL,

    message TEXT
);


INSERT INTO model_logs ("message") VALUES ('Jesse'), ('Favour');


SELECT * FROM model_logs;

-- use TRUNCATE to delete all data in a table without deleting the table itself
TRUNCATE TABLE model_logs;





























































-- we use INSERT INTO to add new rows to a table
INSERT INTO f_table (the_name, model_type, model_loss, model_pushed, creation_time)
VALUES ('Model A', 'XGBoost', 0.2214, TRUE, '2029-10-27 10:00:00');


INSERT INTO f_table (the_name, model_type, model_pushed)
VALUES ('model B', 'XGBoost', FALSE)
RETURNING un_id, creation_time;


INSERT INTO f_table (the_name, model_type, model_loss, model_pushed)
VALUES 
		('model_c', 'sklearn', 2.233, FALSE),
		('model D', 'pytorch', NULL, TRUE),
		('Model E', 'Deep Learning', NULL, FALSE), -- this model has no loss because it crashed during training
		('Model F', 'Resnet', 0.1477, FALSE);


--we use UPDATE and SET to change change values in a row. WHERE helps us apply a condition
UPDATE f_table
SET model_loss = 0.2214,
model_type = 'Jesse is cool'
WHERE un_id = 6;

-- we use DELETE FROM to remove a row in a table
DELETE FROM f_table WHERE the_name = 'Price Predictor';


SELECT * FROM f_table;


UPDATE f_table
SET un_id = 1
WHERE un_id = 2;


































































--we use SELECT & FROM to obtain columns from a table
SELECT the_name, model_loss FROM f_table;


-- pagination enables us to load data (ie, rows) in chunks, to avoid overwhelming a system
SELECT un_id, the_name, creation_time
FROM f_table
ORDER BY creation_time ASC
LIMIT 2; -- this brings out rows 2 at a time


SELECT un_id, the_name, creation_time
FROM f_table
ORDER BY un_id ASC
LIMIT 4
OFFSET 2; -- this makes us skip the first 2 rows and take the next 2 rows 


--we use WHERE and BETWEEN to filter and obtain rows that pass requirements we set
SELECT * FROM f_table
WHERE model_loss > 0.1
AND creation_time BETWEEN '2026-01-01' AND '2030-12-31'

-- LIKE and ILIKE
SELECT * FROM f_table
WHERE model_type LIKE '%net%';

SELECT * FROM f_table
WHERE model_type ILIKE '%torch%'; -- ILIKE is case insensitive, unlike LIKE which is

SELECT * FROM f_table;


/*
 HANDLING NULLS:
 
 we don't do:
 
 column_name  = NULL
 
 instead we do:
 
 column_name IS NULL
*/

SELECT model_type, model_pushed
FROM f_table
WHERE model_loss IS NOT NULL;








































DROP TABLE IF EXISTS datasets_table CASCADE;

-- creating a table to store unique dataset names
CREATE TABLE datasets_table (
	id SERIAL PRIMARY KEY,
	
	name_of_dataset VARCHAR(55) UNIQUE NOT NULL
);

-- we extract unique names from raw_training_logs
INSERT INTO datasets_table (name_of_dataset)
SELECT DISTINCT dataset_name
FROM raw_training_logs
WHERE dataset_name IS NOT NULL;


SELECT * FROM datasets_table; -- should consist of just 4 unique dataset names under the 'name_of_dataset' column


-- CREATING THE LINKED TABLE (FOREIGN KEYS)
DROP TABLE IF EXISTS normalized_experiments;

CREATE TABLE normalized_experiments (
	id SERIAL PRIMARY KEY,
	m_name VARCHAR(112),
	model_accuracy REAL,
	ID_of_dataset INT REFERENCES datasets_table(id) -- this is the foreign key. It replaces the string "ImageNet" with an Integer ID	
);


-- THE JOIN INSERT
-- This is how we convert string data to ID references on the fly.

INSERT INTO normalized_experiments (m_name, model_accuracy, id_of_dataset)
SELECT rtl.experiment_name,
	rtl.model_accuracy,
	dt.id -- extracting the ID from datasets_table
FROM raw_training_logs rtl
JOIN datasets_table dt ON rtl.dataset_name = dt.name_of_dataset -- string name should be matched
WHERE rtl.experiment_name  IS NOT NULL;

-- The new table uses integers for datasets, saving space.
SELECT * FROM normalized_experiments LIMIT 23;










































































DROP TABLE IF EXISTS model_info CASCADE;


CREATE TABLE model_info (
	id SERIAL PRIMARY KEY,
	model VARCHAR(55) NOT NULL,
	m_acc REAL,
	cre_time TIMESTAMP DEFAULT NOW(),
	params JSONB NOT NULL -- this uses JSONB, a no-SQL structure supported by postgres
);





/*

In PostgreSQL, REAL and FLOAT are both inexact, floating-point numeric types, but they differ in how they map to storage size and precision.

1. REAL:
	This is a 4-byte (32-bit) single-precision floating-point number. It offers a precision of at least 6 decimal digits and is often used when storage space is a concern and slight inaccuracies are acceptable.

2. FLOAT:
		FLOAT is a generic alias that maps to either REAL or DOUBLE PRECISION based on a specified precision:
        FLOAT(1) to FLOAT(24) maps to REAL (4 bytes).
        FLOAT(25) to FLOAT(53) maps to DOUBLE PRECISION (8 bytes).
        FLOAT (without specifying precision) defaults to DOUBLE PRECISION. 

*/





-- we create GIN (Generalized Inverted Index) on the params column to make it quickly-searchable for information O(1) when we run queries
CREATE INDEX idx_params ON model_info USING GIN (params);



INSERT INTO model_info (model, m_acc, params)
VALUES (
	'linear_regression_v1',
	0.56,
	-- we convert the string to JSON Binary to ensure Postgres validates it on insert
	'{"alpha": 0.4, "solver": "dakls", "normalize": true}'::jsonb
);


INSERT INTO model_info (model, m_acc, params)
VALUES (
    'random_forest_v1',
    0.92,
    -- Note: No "alpha", instead we have "n_estimators" and "max_depth"
    '{"n_estimators": 100, "max_depth": 10, "criterion": "gini"}'::jsonb
);



INSERT INTO model_info (model, m_acc, params)
VALUES (
    'cnn_resnet_v2',
    0.98,
    -- Complex nested structure. Standard SQL columns would fail here.
    '{
        "optimizer": "adam",
        "epochs": 50,
        "layers": {
            "conv1": {"filters": 64, "kernel": 3},
            "dense1": {"units": 128, "activation": "relu"}
        },
        "learning_rate": 0.001
    }'::jsonb
);



INSERT INTO model_info (model, m_acc, params)
VALUES (
    'cnn_resnet_v3',
    0.94,
    '{"optimizer": "sgd", "epochs": 100, "learning_rate": 0.01}'::jsonb
);




-- we use ->> to extract the values of each row of a JSON key we specify
-- If a model (like Random Forest) doesn't have it, Postgres returns NULL gracefully.
SELECT model, (params ->> 'learning_rate')::REAL -- we must convert the value to float (::REAL) if we intend to do math with it
AS lr
FROM model_info;
--WHERE id = 165;



SELECT m_acc, (params ->> 'max_depth')::FLOAT AS max_depth
FROM model_info
WHERE id BETWEEN 100 AND 200;



-- here, we're making use of the GIN index we created earlier
SELECT COUNT(*) FROM model_info
WHERE params @> '{"optimizer": "lars"}'; -- it's like asking postgres: show me all rows where the JSON blob on the left ("optimizer") matches that on the right ("adam")


SELECT model, m_acc, params
FROM model_info
-- we use -> to keep entering inside the JSON, and ->> to extract a key's value
WHERE (params -> 'layers' -> 'conv1' ->> 'filters')::INT >= 50; -- we convert the result to an integer, then check if it's greater then 50



SELECT model, m_acc, params FROM model_info
WHERE
(params -> 'layers' -> 'conv1' ->> 'filters')::INT <= 50
AND
(params -> 'layers' -> 'dense1' ->> 'units')::INT >= 100;


SELECT * FROM model_info
WHERE (params ->> 'n_estimators')::INT > 50;
















































































-- ===================================== MLOPS FEATURE ENGINEERING: THE WEAVER (JOINS) =====================================

-- creating synthetic data...

-- create Table A (customers)
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
	id SERIAL PRIMARY KEY,
	user_age INT,
	user_country VARCHAR(50),
	info VARCHAR(88)
);


-- creating Table B (customer_transactions)
DROP TABLE IF EXISTS customer_transactions CASCADE;
CREATE TABLE customer_transactions (
	tr_id SERIAL PRIMARY KEY,
	id INT, -- Foreign key to customers
	trans_amount REAL,
	"is_fraud?" BOOLEAN, -- target column (y)
	tr_date DATE,
	info VARCHAR(88)
);


-- insert data into "customerss" table
INSERT INTO customers (id, user_age, user_country, info) VALUES
(1, 23, 'Niger', 'Customers and Customer Transactions'),
(2, 22, 'Belgium', 'Customers'),
(3, 11, 'Ghana', 'Customers and Customer Transactions'),
(4, 44, 'Hamas', 'Customers and Customer Transactions');



INSERT INTO customer_transactions (id, trans_amount, "is_fraud?", tr_date, info) VALUES
(1, 234.34, TRUE, '2023-10-01', 'Customers and Customer Transactions'),
(3, 1111.22, FALSE, '2023-10-02', 'Customers and Customer Transactions'),
(5, 44, FALSE, '2023-10-03', 'Customer Transactions'),
(4, 22.4, FALSE, '2023-11-05', 'Customers and Customer Transactions');


-- ===================================== INNER JOIN =====================================
SELECT
	-- from customer_transactions table
	tr.id, tr.trans_amount, tr.info,
	-- from customers table
	cus.user_age, cus.user_country, cus.info
FROM customer_transactions tr
INNER JOIN customers cus
ON cus.id = tr.id;

SELECT cus.user_age, ctr.trans_amount, ctr.tr_date
FROM customers cus
LEFT JOIN customer_transactions ctr
ON cus.id = ctr.id;


-- ===================================== LEFT JOIN =====================================

SELECT
	ctr.id, cus.id, ctr.trans_amount, ctr.info,
	cus.user_age, -- will be null for user 5
	cus.user_country,
	cus.info
FROM customer_transactions ctr
LEFT JOIN customers cus
ON ctr.id = cus.id;



SELECT
	ctr.id, cus.id, cus.info, ctr.info,
	ctr.trans_amount, -- user 2 will be NULL
	cus.user_country
FROM customers cus
LEFT JOIN customer_transactions ctr
ON ctr.id = cus.id;



-- ===================================== OUTER JOIN =====================================

-- outer join combines both tables, filling NULLS in empty cells not available in the other table
SELECT 
	ctr.tr_id, cus.id AS customer_id,
	ctr.trans_amount AS transaction_amount,
	ctr.info AS tr_info,
	cus.info AS customer_info
FROM customer_transactions ctr
FULL OUTER JOIN customers cus
ON ctr.id = cus.id;




-- ===================================== SELF-JOIN =====================================

/*

We want to predict today's stock price using yesterday's stock price.

The data is in a different ROW, not a different column.

The solution is to join the table to itself to align "Yesterday" with "Today".

*/


-- create a stocks table...
DROP TABLE IF EXISTS prices_of_stocks;

CREATE TABLE prices_of_stocks (
	date DATE,
	ticker VARCHAR(15),
	closing_price FLOAT
);

INSERT INTO prices_of_stocks (date, ticker, closing_price) VALUES
('2026-02-06', 'AAPL', 185.00), ('2026-02-07', 'AAPL', 185.50), ('2026-02-08', 'AAPL', 186.10),
('2026-02-09', 'AAPL', 184.90), ('2026-02-10', 'AAPL', 187.20), ('2026-02-11', 'AAPL', 188.00),
('2026-02-12', 'AAPL', 189.15), ('2026-02-13', 'AAPL', 187.50), ('2026-02-14', 'AAPL', 186.40),
('2026-02-15', 'AAPL', 188.90), ('2026-02-16', 'AAPL', 190.10), ('2026-02-17', 'AAPL', 191.20),
('2026-02-18', 'AAPL', 192.50), ('2026-02-19', 'AAPL', 191.80), ('2026-02-20', 'AAPL', 193.00),
('2026-02-21', 'AAPL', 194.20), ('2026-02-22', 'AAPL', 195.10), ('2026-02-23', 'AAPL', 194.80),
('2026-02-24', 'AAPL', 196.00), ('2026-02-25', 'AAPL', 197.30), ('2026-02-26', 'AAPL', 198.50),
('2026-02-27', 'AAPL', 197.90), ('2026-02-28', 'AAPL', 199.10), ('2026-03-01', 'AAPL', 200.20),
('2026-03-02', 'AAPL', 201.50), ('2026-03-03', 'AAPL', 202.80), ('2026-03-04', 'AAPL', 203.40),
('2026-03-05', 'AAPL', 202.90), ('2026-03-06', 'AAPL', 204.10), ('2026-03-07', 'AAPL', 205.20),
('2026-03-08', 'AAPL', 206.30), ('2026-03-09', 'AAPL', 205.80), ('2026-03-10', 'AAPL', 207.00),
('2026-03-11', 'AAPL', 208.20), ('2026-03-12', 'AAPL', 209.40), ('2026-03-13', 'AAPL', 210.60),
('2026-03-14', 'AAPL', 211.80), ('2026-03-15', 'AAPL', 212.90), ('2026-03-16', 'AAPL', 211.50),
('2026-03-17', 'AAPL', 213.20), ('2026-03-18', 'AAPL', 214.40), ('2026-03-19', 'AAPL', 215.60),
('2026-03-20', 'AAPL', 216.80), ('2026-03-21', 'AAPL', 217.00), ('2026-03-22', 'AAPL', 218.20),
('2026-03-23', 'AAPL', 219.40), ('2026-03-24', 'AAPL', 220.60), ('2026-03-25', 'AAPL', 221.80),
('2026-03-26', 'AAPL', 222.00), ('2026-03-27', 'AAPL', 221.50), ('2026-03-28', 'AAPL', 223.70),
('2026-03-29', 'AAPL', 224.90), ('2026-03-30', 'AAPL', 225.10), ('2026-03-31', 'AAPL', 226.30),
('2026-04-01', 'AAPL', 227.50), ('2026-04-02', 'AAPL', 228.70), ('2026-04-03', 'AAPL', 229.90),
('2026-04-04', 'AAPL', 230.10), ('2026-04-05', 'AAPL', 231.30), ('2026-04-06', 'AAPL', 232.50),
('2026-04-07', 'AAPL', 233.70), ('2026-04-08', 'AAPL', 234.90), ('2026-04-09', 'AAPL', 235.10),
('2026-04-10', 'AAPL', 236.30), ('2026-04-11', 'AAPL', 237.50);



SELECT
	today.date AS prediction_date,
	today.closing_price AS label_y, -- price today
	yesterday.closing_price AS feature_previous_day	-- price yesterday
FROM prices_of_stocks today
LEFT JOIN prices_of_stocks yesterday
ON yesterday.date = today.date - INTERVAL '1 day' -- join where yesterday is equal to today minus 1 day
-- joining on ticker too...
AND yesterday.ticker = today.ticker;

/*
Result:
'2026-02-06': NULL previous price (First day)
'2026-02-07': Target 185.50, Feature 185.00
'2026-02-08': Target 186.10, Feature 185.50

*/












































































-- Removes the 'modelRuns' table from the database if it already exists, using 'CASCADE' to automatically drop any objects (like views or constraints) that depend on it, ensuring a clean slate.
DROP TABLE IF EXISTS modelRuns CASCADE;
-- Removes the 'MlModels' table from the database if it exists, also using 'CASCADE' to drop dependent objects, preventing errors when we try to recreate it below.
DROP TABLE IF EXISTS MlModels CASCADE;


-- Initiates the creation of a new table named 'MlModels' to store information about different machine learning models.
CREATE TABLE MlModels(
    -- Defines 'id' as the primary key using 'SERIAL', an auto-incrementing integer type that uniquely identifies each model record.
    id SERIAL PRIMARY KEY,  
    -- Creates a 'ModelName' column that can hold a string up to 100 characters long, and 'NOT NULL' ensures every model must have a name.
    ModelName VARCHAR(100) NOT NULL,
    -- Creates a 'VersionTag' column for strings up to 33 characters, requiring it to be populated ('NOT NULL') and ensuring no two models can share the same version tag ('UNIQUE').
    VersionTag VARCHAR(33) NOT NULL UNIQUE,
    -- Adds a 'ModelDescription' column using the 'TEXT' data type, which allows for storing arbitrarily long string descriptions of the model.
    ModelDescription TEXT,
    -- Sets up a 'CreatedAt' column to track when the record was made; it defaults to the current database timestamp ('NOW()') if no value is explicitly provided.
    CreatedAt TIMESTAMP NOT NULL DEFAULT NOW()
-- Closes the column definition list and executes the table creation statement.
);

--moving to the ml_models schema...
-- Modifies the newly created 'MlModels' table (explicitly referencing it in the 'public' schema) and physically moves it into a different organizational schema named 'ml_schema'.
ALTER TABLE public.MlModels SET SCHEMA ml_schema;



-- Updates the current session's 'search_path', instructing the database to first look in 'ml_schema' and then in 'public' when resolving unqualified table names in subsequent queries.
SET search_path TO ml_schema, public;


-- Begins defining a second table named 'ModelRuns' to log the performance metrics of individual executions or training runs for the models.
CREATE TABLE ModelRuns(
    -- Defines 'RunID' as the primary key, using 'SERIAL' so the database automatically generates a unique, incrementing ID for every run.
    RunID SERIAL PRIMARY KEY,
    -- Creates a 'ModelID' column acting as a foreign key that links to the 'id' column in the 'MlModels' table, establishing a relationship between a run and its parent model.
    ModelID INT NOT NULL REFERENCES MlModels(id) ON DELETE CASCADE, -- ON DELETE CASCADE means: if a model is deleted from ml_models, all its associated runs in this table are automatically deleted too
    -- Adds a column for the model's accuracy as a floating-point number, enforcing a rule ('CHECK') that the value must be a percentage between 0.0 and 1.0.
    MAccuracy FLOAT CHECK(MAccuracy >= 0.0 AND MAccuracy <= 1.0),
    -- Adds a column to record the model's loss (error rate) as a float, restricting it so that the loss cannot be a negative number.
    ModelLoss FLOAT CHECK(ModelLoss >= 0.0),
    -- Defines a column for the number of training epochs as an integer, requiring a value and ensuring it is strictly greater than zero.
    MEpochs INT NOT NULL CHECK(mepochs > 0), -- epochs cannot be 0 or less. How the heck did you train your model?
    -- Creates a 'RunTime' timestamp column to record when the run occurred, automatically defaulting to the exact moment the record is inserted.
    RunTime TIMESTAMP NOT NULL DEFAULT NOW()
-- Finalizes the structural definition of the 'ModelRuns' table.
);


-- Insert valid random data first to confirm the happy path works...
-- Begins an insertion operation targeting the 'MlModels' table, specifying that we will provide data for the 'ModelName', 'VersionTag', and 'ModelDescription' columns.
INSERT INTO MlModels (ModelName, VersionTag, ModelDescription)
-- Starts a SELECT query that will generate rows of data on-the-fly to be fed directly into the INSERT statement above.
SELECT 
    -- Dynamically constructs the model name by concatenating the string 'Model_' with the current integer 'i'.
    'Model_' || i, 
    -- Dynamically builds a unique semantic version string (e.g., 'v1.1.0') by placing the integer 'i' between 'v1.' and '.0'.
    'v1.' || i || '.0', 
    -- Creates a dummy description text by appending the integer 'i' to the end of a base string.
    'Auto-generated description for model ' || i
-- Uses the 'generate_series' set-returning function to create a temporary sequence of numbers from 1 to 23, assigning each number to the alias 'i' for the SELECT clause to use.
FROM generate_series(1, 23) AS i;


-- Prepares to add new records into the 'ModelRuns' table, listing the specific columns ('ModelID', 'MAccuracy', 'ModelLoss', 'MEpochs') we are providing data for.
INSERT INTO ModelRuns(ModelID, MAccuracy, ModelLoss, MEpochs)
-- Indicates that the exact data rows to be inserted follow immediately after this keyword.
VALUES
-- Inserts the first record: linking to Model 1, with 87% accuracy, 0.34 loss, over 10 epochs.
(1, 0.87, 0.34, 10),
-- Inserts the second record: another run for Model 1, showing improved accuracy (91%) and lower loss (0.21) after 25 epochs.
(1, 0.91, 0.21, 25),
-- Inserts the third record: linking to Model 2, logging a 94% accuracy and 0.15 loss over 50 epochs, completing the multi-row insert statement.
(2, 0.94, 0.15, 50);

-- let's view the columns...
-- Retrieves and displays every column ('*') for all rows currently stored in the 'MlModels' table to verify our mass insertion worked.
SELECT * FROM MlModels;
-- Retrieves and displays every column ('*') for all rows in the 'ModelRuns' table to review the manual metric logs we just added.
SELECT * FROM ModelRuns;


-- the following insert should fail...
-- Attempts an insertion into the 'MlModels' table providing only the 'ModelName' and 'VersionTag' columns.
INSERT INTO MlModels (ModelName, VersionTag)
-- Declares the single row of values to be inserted.
VALUES
-- Attempts to insert 'ResNet Classifier' and 'v1.5.0'. NOTE: This will fail (as the user comment implies) because 'v1.5.0' was already generated and inserted by the 'generate_series' loop earlier, violating the UNIQUE constraint on 'VersionTag'.
('ResNet Classifier', 'v1.5.0');




