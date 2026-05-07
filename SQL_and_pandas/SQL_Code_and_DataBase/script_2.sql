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
















































































<<<<<<< Updated upstream
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













































































DROP TABLE IF EXISTS modelRuns CASCADE;
DROP TABLE IF EXISTS MlModels CASCADE;


CREATE TABLE MlModels(
	id SERIAL PRIMARY KEY,	
	ModelName VARCHAR(100) NOT NULL,
	VersionTag VARCHAR(33) NOT NULL UNIQUE,
	ModelDescription TEXT,
	CreatedAt TIMESTAMP NOT NULL DEFAULT NOW()
);

--moving to the ml_models schema...
ALTER TABLE public.MlModels SET SCHEMA ml_schema;



SET search_path TO ml_schema, public;


CREATE TABLE ModelRuns(
	RunID SERIAL PRIMARY KEY,
	ModelID INT NOT NULL REFERENCES MlModels(id) ON DELETE CASCADE, -- ON DELETE CASCADE means: if a model is deleted from ml_models, all its associated runs in this table are automatically deleted too
	MAccuracy FLOAT CHECK(MAccuracy >= 0.0 AND MAccuracy <= 1.0),
	ModelLoss FLOAT CHECK(ModelLoss >= 0.0),
	MEpochs INT NOT NULL CHECK(mepochs > 0), -- epochs cannot be 0 or less. How the heck did you train your model?
	RunTime TIMESTAMP NOT NULL DEFAULT NOW()
);


-- Insert valid random data first to confirm the happy path works...
INSERT INTO MlModels (ModelName, VersionTag, ModelDescription)
SELECT 
    'Model_' || i, 
    'v1.' || i || '.0', 
    'Auto-generated description for model ' || i
FROM generate_series(1, 23) AS i;


INSERT INTO ModelRuns(ModelID, MAccuracy, ModelLoss, MEpochs)
VALUES
(1, 0.87, 0.34, 10),
(1, 0.91, 0.21, 25),
(2, 0.94, 0.15, 50);

-- let's view the columns...
SELECT * FROM MlModels;
SELECT * FROM ModelRuns;


-- the following insert should fail...
INSERT INTO MlModels (ModelName, VersionTag)
VALUES
('ResNet Classifier', 'v1.5.0');










































































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
    -- Sets up a 'CreatedAt' column to track when the record was made; it defaults to the current database timestamp ('NOW()') if nalue is explicitly provided.
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
=======







































DROP TABLE IF EXISTS customers_transactions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS ml_models CASCADE;


CREATE TABLE customers(
	id_of_user SERIAL PRIMARY KEY,
	name_of_user VARCHAR(58) NOT NULL,
	user_email  VARCHAR(100) UNIQUE NOT NULL,
	user_age INTEGER,
	user_location VARCHAR(100),
	sign_date TIMESTAMP DEFAULT NOW()
);


CREATE TABLE customers_transactions (
	t_id SERIAL PRIMARY KEY,
	id_of_user INTEGER NOT NULL,
	p_id INTEGER NOT NULL,
	price NUMERIC(10, 2), -- WHAT: Purchase amount in dollars (10 digits total, 2 after decimal)
	sell_date DATE NOT NULL,
	FOREIGN KEY (id_of_user) REFERENCES customers(id_of_user) ON DELETE CASCADE	-- connecting customers_transactions.id_of_user to customers.id_of_user; ON DELETE CASCADE means that if a user is deleted, their transactions are also deleted
);


CREATE TABLE ml_models(
	m_id SERIAL PRIMARY KEY,
	m_name VARCHAR(100) NOT NULL,
	p_id INTEGER,
	m_acc NUMERIC(5, 4), -- maximum of 5 whole numbers, 4 decimal points
	c_date TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY (p_id) REFERENCES ml_models(m_id) ON DELETE SET NULL -- We're self-referencing the foreign key (points to the same table). This enables querying model lineage (which model was this fine-tuned from)
--	ON DELETE SET NULL means that if a parent model is deleted, this model's parent becomes NULL (instead of deleting the child model)
);



-- insert sample users
INSERT INTO customers (name_of_user , user_email, user_age, user_location, sign_date) VALUES
    ('alice_ml', 'alice@startup.com', 28, 'San Francisco', '2023-01-15'),
    ('bob_data', 'bob@company.io', 35, 'New York', '2023-02-20'),    
    ('charlie_ai', 'charlie@tech.net', 42, 'Austin', '2023-03-10'),    
    ('diana_ops', 'diana@devops.com', 30, 'Seattle', '2023-04-05'),    
    ('eve_engineer', 'eve@mlops.org', 26, 'San Francisco', '2023-05-12');
    
    
-- Insert sample transactions (note: not all users have transactions)
INSERT INTO customers_transactions (id_of_user, p_id, price, sell_date) VALUES
    (1, 101, 49.99, '2023-01-20'),
    (1, 102, 79.99, '2023-02-15'),
    (1, 103, 129.99, '2023-03-10'),
    (2, 101, 49.99, '2023-03-01'),
    (2, 104, 199.99, '2023-03-15'),
    (3, 102, 79.99, '2023-03-25'),
    (4, 101, 49.99, '2023-04-20')
;
 

-- Insert sample models (hierarchical structure for self-joins)
INSERT INTO ml_models (m_name, p_id, m_acc, c_date) VALUES
    ('GPT-Base', NULL, 0.7823, '2023-01-01'),
    ('GPT-FineTuned-v1', 1, 0.8456, '2023-02-01'),
    ('GPT-FineTuned-v2', 2, 0.8912, '2023-03-01'),       
    ('BERT-Base', NULL, 0.8012, '2023-01-15'),           
    ('BERT-FineTuned', 4, 0.8734, '2023-02-15')
;
    

-- ===================================== INNER JOIN =====================================
SELECT cust.id_of_user, cust.name_of_user, cust.user_age, cust.user_location,
	ctran.t_id, ctran.p_id, ctran.price, ctran.sell_date
FROM customers cust INNER JOIN customers_transactions ctran
ON cust.id_of_user = ctran.id_of_user;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


-- RESULT INTERPRETATION:
-- Expected: 7 rows (one per transaction)
-- Missing: Eve (user_id 5) because she has no transactions
-- This is INNER JOIN behavior: only matched rows appear

-- ----------------------------------------------------------------------------
-- REAL-WORLD USE CASE: Building a Training Dataset for Recommendation Model
-- ----------------------------------------------------------------------------

-- Calculate aggregated features per user (only for users with purchase history)
-- WHAT: Creates a feature vector for each active user
-- WHY: ML models need numeric features, not raw transactional data
-- WHAT IF we didn't aggregate: Model would see individual transactions (not user-level patterns)
SELECT 
    u.user_id,                                  
    u.username,
    u.age,
    u.location,
    
    COUNT(t.transaction_id) AS purchase_count,  -- WHAT: Total number of purchases per user
                                                 -- WHY: Frequency metric (F in RFM analysis)
                                                 -- WHAT IF we used COUNT(*): Same result here, but COUNT(column) is safer (ignores NULLs)
    
    SUM(t.amount) AS total_spent,               -- WHAT: Lifetime revenue from this user
                                                 -- WHY: Monetary metric (M in RFM analysis)
                                                 -- WHAT IF a user has no transactions: SUM returns NULL (handled by INNER JOIN - no such users here)
    
    AVG(t.amount) AS avg_transaction_amount,    -- WHAT: Mean purchase value
                                                 -- WHY: Indicates user's spending tier (budget vs premium)
                                                 -- WHAT IF we calculate this in Python: Inefficient (pulls raw data, then aggregates)

    
    MAX(t.transaction_date) AS last_purchase,   -- WHAT: Most recent purchase date
                                                 -- WHY: Recency metric (R in RFM analysis)
                                                 -- WHAT IF we use MIN: Would give first purchase date (useful for customer age)
    
    CURRENT_DATE - MAX(t.transaction_date) AS days_since_last_purchase
                                                 -- WHAT: Computed feature (current date minus last purchase)
                                                 -- WHY: Churn prediction models use recency (inactive users = high churn risk)
                                                 -- WHAT IF this value is > 90 days: User is at risk of churning
FROM 
    users u
INNER JOIN 
    transactions t 
ON 
    u.user_id = t.user_id
GROUP BY 
    u.user_id, u.username, u.age, u.location;   -- WHAT: All non-aggregated columns must be in GROUP BY
                                                 -- WHY: PostgreSQL needs to know which user to assign aggregates to
    
    
SELECT cust.id_of_user, cust.name_of_user, cust.user_age, cust.user_location,
COUNT(ctran.t_id) AS p_count, SUM(ctran.price) AS t_spent, AVG(ctran.price) AS avg_speng,
MAX(ctran.sell_date) AS lp_date, CURRENT_DATE - MAX(ctran.sell_date) AS d_slp
FROM customers cust INNER JOIN customers_transactions ctran
ON cust.id_of_user = ctran.id_of_user
GROUP BY cust.id_of_user, cust.name_of_user, cust.user_age, cust.user_location
;

                                                 -- WHAT IF we omit u.username from GROUP BY: ERROR (column must be aggregated or grouped)

-- RESULT INTERPRETATION:
-- Expected: 4 rows (Alice, Bob, Charlie, Diana)
-- Missing: Eve (no transactions = excluded by INNER JOIN)
-- This feature table is ready to be loaded into scikit-learn for training

-- ----------------------------------------------------------------------------
-- PART 2: LEFT JOIN (The Loyal Friend)
-- ----------------------------------------------------------------------------

-- Show ALL users, even those without purchases
-- WHAT: Returns all rows from left table (users), matched with right table (transactions)
-- WHY: For churn analysis, we need to see inactive users (those with zero purchases)
-- WHAT IF we used INNER JOIN: Eve would disappear (we'd miss potential churners)
SELECT 
    u.user_id,
    u.username,
    u.age,
    u.location,
    t.transaction_id,       -- WHAT: Will be NULL for users with no purchases
                            -- WHY: No matching row exists in transactions table
                            -- WHAT IF we filter WHERE t.transaction_id IS NOT NULL: Converts LEFT JOIN back to INNER JOIN
    
    t.product_id,           -- WHAT: Will be NULL for Eve
    t.amount,               -- WHAT: Will be NULL for Eve
    t.transaction_date      -- WHAT: Will be NULL for Eve
FROM 
    users u                 -- WHAT: Left table (all rows from here are preserved)
                            -- WHY: We're prioritizing user completeness over transaction completeness
LEFT JOIN 
    transactions t          -- WHAT: Right table (only matched rows are included)
                            -- WHY: If no match exists, right-side columns become NULL
                            -- WHAT IF we swap (transactions LEFT JOIN users): Would show all transactions, orphaned purchases would have NULL users
ON 
    u.user_id = t.user_id
ORDER BY 
    u.user_id, t.transaction_date;  
                            -- WHAT: Sort by user first, then transaction date
                            -- WHY: Groups each user's transactions together, sorted chronologically
                            -- WHAT IF we omit ORDER BY: Results are in random order (hard to interpret)

-- RESULT INTERPRETATION:
-- Expected: 8 rows (7 transactions + 1 row for Eve with NULLs)
-- Key observation: Eve appears with transaction_id = NULL
-- This is LEFT JOIN behavior: all left table rows appear, even without matches

-- ----------------------------------------------------------------------------
-- REAL-WORLD USE CASE: Identifying Users at Risk of Churning
-- ----------------------------------------------------------------------------

-- Find users who have NEVER made a purchase (potential churners)
-- WHAT: Filters LEFT JOIN results to show only unmatched rows
-- WHY: These users signed up but never converted (onboarding problem?)
-- WHAT IF we used INNER JOIN: Impossible to find these users (they'd be excluded)
SELECT 
    u.user_id,
    u.username,
    u.email,                -- WHAT: Contact info for re-engagement campaigns
                            -- WHY: Marketing team can send "Come back!" emails
    
    u.signup_date,
    CURRENT_DATE - u.signup_date AS days_since_signup
                            -- WHAT: How long they've been registered without purchasing
                            -- WHY: Indicates urgency (30 days = still warm lead, 180 days = cold)
FROM 
    users u
LEFT JOIN 
    transactions t 
ON 
    u.user_id = t.user_id
WHERE 
    t.transaction_id IS NULL;   -- WHAT: Filters for rows where the right table had no match
                                 -- WHY: NULL in transaction_id means "no purchases"
                                 -- WHAT IF we check t.user_id IS NULL: Same result, but transaction_id is clearer (it's the primary key)

-- RESULT INTERPRETATION:
-- Expected: 1 row (Eve)
-- Action: Send Eve a promotional discount (she's signed up but hasn't purchased)

-- ----------------------------------------------------------------------------
-- REAL-WORLD USE CASE: Aggregating with LEFT JOIN (Handling NULLs)
-- ----------------------------------------------------------------------------

-- Calculate purchase stats for ALL users (including those with 0 purchases)
-- WHAT: Same aggregation as INNER JOIN example, but includes non-purchasers
-- WHY: Churn models need features for inactive users (can't train on active users only)
-- WHAT IF we used INNER JOIN: Model would have selection bias (only learns from engaged users)
SELECT 
    u.user_id,
    u.username,
    u.age,
    u.location,
    
    COUNT(t.transaction_id) AS purchase_count,  -- WHAT: Counts non-NULL transaction IDs
                                                 -- WHY: COUNT(column) ignores NULLs, so Eve gets 0 (not NULL)
                                                 -- WHAT IF we used COUNT(*): Would return 1 for Eve (counts the row itself, even though transaction columns are NULL)
    
    COALESCE(SUM(t.amount), 0) AS total_spent,  -- WHAT: SUM of amounts, replacing NULL with 0
                                                 -- WHY: SUM(NULL) = NULL, but we want 0 for users with no purchases
                                                 -- WHAT IF we omit COALESCE: Eve's total_spent would be NULL (confusing for ML models)
    
    COALESCE(AVG(t.amount), 0) AS avg_transaction_amount,
                                                 -- WHAT: Average amount, defaulting to 0 for non-purchasers
                                                 -- WHY: AVG(NULL) = NULL, but 0 is more meaningful for feature engineering
    
    MAX(t.transaction_date) AS last_purchase,   -- WHAT: Will be NULL for Eve
                                                 -- WHY: No purchase = no last purchase date
                                                 -- WHAT IF we COALESCE to signup_date: Could mislead model (suggests they purchased on signup)
    
    CASE 
        WHEN MAX(t.transaction_date) IS NULL THEN NULL
        ELSE CURRENT_DATE - MAX(t.transaction_date)
    END AS days_since_last_purchase             -- WHAT: NULL for non-purchasers, calculated for others
                                                 -- WHY: Prevents DATE arithmetic on NULL (which would error)
                                                 -- WHAT IF we didn't use CASE: Query would fail (can't subtract NULL)
FROM 
    users u
LEFT JOIN 
    transactions t 
ON 
    u.user_id = t.user_id
GROUP BY 
    u.user_id, u.username, u.age, u.location;

-- RESULT INTERPRETATION:
-- Expected: 5 rows (all users)
-- Eve's row: purchase_count = 0, total_spent = 0, avg_transaction_amount = 0, last_purchase = NULL
-- This is the complete feature table (including inactive users)

-- ----------------------------------------------------------------------------
-- PART 3: RIGHT JOIN (The Reverse Loyal Friend) - RARELY USED
-- ----------------------------------------------------------------------------

-- Show ALL transactions, even if the user was deleted (orphaned transactions)
-- WHAT: Returns all rows from right table (transactions), matched with left table (users)
-- WHY: Audit orphaned data (transactions pointing to non-existent users)
-- WHAT IF we used INNER JOIN: Orphaned transactions would be hidden
SELECT 
    u.user_id,              -- WHAT: Will be NULL if transaction has no matching user
                            -- WHY: Indicates data integrity issue (orphaned transaction)
    
    u.username,
    t.transaction_id,       -- WHAT: All transactions appear (right table is preserved)
    t.user_id AS transaction_user_id,   
                            -- WHAT: The user_id stored in the transaction
                            -- WHY: Compare with u.user_id to detect orphans (if u.user_id IS NULL but transaction_user_id IS NOT NULL = orphan)
    
    t.amount,
    t.transaction_date
FROM 
    users u
RIGHT JOIN 
    transactions t          -- WHAT: Right table (all rows from here are preserved)
                            -- WHY: We're prioritizing transaction completeness
ON 
    u.user_id = t.user_id;

-- RESULT INTERPRETATION:
-- Expected: 7 rows (all transactions)
-- If we had an orphaned transaction (user_id = 999, but user 999 doesn't exist), 
-- that row would show u.user_id = NULL, transaction_user_id = 999

-- NOTE: This is almost never used in practice. Why?
-- Because we can rewrite it as a LEFT JOIN (just swap the tables):
-- "transactions LEFT JOIN users" gives the same result as "users RIGHT JOIN transactions"

-- The LEFT JOIN version is more readable:
SELECT 
    t.transaction_id,
    t.user_id AS transaction_user_id,
    t.amount,
    t.transaction_date,
    u.user_id,
    u.username
FROM 
    transactions t          -- WHAT: Left table (prioritized)
LEFT JOIN 
    users u                 -- WHAT: Right table
ON 
    t.user_id = u.user_id;

-- Same result, but more intuitive (we read left-to-right, so the primary table is first)

-- ----------------------------------------------------------------------------
-- PART 4: FULL OUTER JOIN (The Completionist)
-- ----------------------------------------------------------------------------

-- Show ALL users and ALL transactions, regardless of matches
-- WHAT: Returns all rows from both tables, filling gaps with NULLs
-- WHY: Data reconciliation (find discrepancies between two systems)
-- WHAT IF we used INNER JOIN: Would miss unmatched rows from both sides
SELECT 
    u.user_id AS user_table_user_id,    
                            -- WHAT: User ID from users table (NULL if no matching user)
                            -- WHY: Distinct from transaction_user_id for comparison
    
    u.username,
    u.email,
    t.transaction_id,
    t.user_id AS transaction_user_id,   
                            -- WHAT: User ID from transactions table (NULL if no matching transaction)
    
    t.amount,
    t.transaction_date
FROM 
    users u
FULL OUTER JOIN 
    transactions t
ON 
    u.user_id = t.user_id
ORDER BY 
    u.user_id, t.transaction_id;

-- RESULT INTERPRETATION:
-- Expected: 8 rows (7 transactions + 1 unmatched user)
-- Eve appears with transaction columns = NULL (has no transactions)
-- If we had an orphaned transaction, it would appear with user columns = NULL

-- ----------------------------------------------------------------------------
-- REAL-WORLD USE CASE: Finding Data Gaps
-- ----------------------------------------------------------------------------

-- Identify mismatches (users without transactions OR transactions without users)
-- WHAT: Filters FULL OUTER JOIN for unmatched rows on either side
-- WHY: Data quality checks (find orphaned records)
-- WHAT IF our database has referential integrity: This query returns only non-purchasers (no orphaned transactions possible)
SELECT 
    COALESCE(u.user_id, t.user_id) AS user_id, 
                            -- WHAT: Use user_id from whichever table has it (handles NULLs)
                            -- WHY: At least one side will have a non-NULL user_id
                            -- WHAT IF both are NULL: Impossible (can't join on nothing)
    
    u.username,
    t.transaction_id,
    CASE 
        WHEN u.user_id IS NULL THEN 'Orphaned Transaction (no matching user)'
        WHEN t.transaction_id IS NULL THEN 'User with no purchases'
        ELSE 'Match found (should not appear here)'
    END AS mismatch_type    -- WHAT: Categorizes the type of gap
                            -- WHY: Helps prioritize data cleanup (orphaned transactions = critical bug)
FROM 
    users u
FULL OUTER JOIN 
    transactions t
ON 
    u.user_id = t.user_id
WHERE 
    u.user_id IS NULL       -- WHAT: Transaction has no matching user (orphaned)
    OR 
    t.transaction_id IS NULL;   
                            -- WHAT: User has no matching transaction (non-purchaser)
                            -- WHY: Only interested in mismatches (not successful joins)

-- RESULT INTERPRETATION:
-- Expected: 1 row (Eve - user with no purchases)
-- If we had orphaned transactions, they'd also appear here

-- ----------------------------------------------------------------------------
-- PART 5: SELF-JOIN (Comparing a Table to Itself)
-- ----------------------------------------------------------------------------

-- SCENARIO 1: Show each model and its parent model's name
-- WHAT: Joins the models table to itself to resolve parent_model_id into a readable name
-- WHY: parent_model_id is just a number (not human-readable), we want the parent's name
-- WHAT IF we didn't use self-join: We'd only see parent_model_id = 1 (not helpful)
SELECT 
    child.model_id AS child_model_id,           
                            -- WHAT: The current model's ID
                            -- WHY: Aliased as 'child' for clarity (this is the derived model)
    
    child.model_name AS child_model_name,
                            -- WHAT: The current model's name
    
    child.accuracy AS child_accuracy,
                            -- WHAT: The current model's test accuracy
    
    child.parent_model_id,  -- WHAT: The ID of the model this was fine-tuned from
                            -- WHY: Shows the relationship numerically (for debugging)
    
    parent.model_name AS parent_model_name,     
                            -- WHAT: The parent model's name (from the second "copy" of the table)
                            -- WHY: Human-readable lineage (easier than remembering IDs)
                            -- WHAT IF parent is NULL: Parent model doesn't exist (this is a base model)
    
    parent.accuracy AS parent_accuracy          
                            -- WHAT: The parent model's accuracy
                            -- WHY: Compare performance (did fine-tuning improve accuracy?)
FROM 
    models child            -- WHAT: First "copy" of the models table (the child model)
                            -- WHY: Aliased as 'child' because these are the derived models
LEFT JOIN 
    models parent           -- WHAT: Second "copy" of the models table (the parent model)
                            -- WHY: Aliased as 'parent' because we're looking up the parent
                            -- WHAT IF we used INNER JOIN: Base models (parent_model_id = NULL) would disappear
ON 
    child.parent_model_id = parent.model_id;    
                            -- WHAT: Join condition (child's parent_model_id matches parent's model_id)
                            -- WHY: This "resolves" the foreign key to get parent's details
                            -- WHAT IF we join on child.model_id = parent.model_id: Would create a nonsensical self-match (each model matched to itself)

-- RESULT INTERPRETATION:
-- Expected: 5 rows
-- GPT-Base: parent_model_name = NULL (it's a root model)
-- GPT-FineTuned-v1: parent_model_name = 'GPT-Base'
-- GPT-FineTuned-v2: parent_model_name = 'GPT-FineTuned-v1'
-- This shows the lineage chain: Base → v1 → v2

-- ----------------------------------------------------------------------------
-- SCENARIO 2: Find models that improved upon their parent
-- ----------------------------------------------------------------------------

-- WHAT: Filters for models where accuracy increased compared to parent
-- WHY: Track which fine-tuning runs were successful (improved performance)
-- WHAT IF a model has no parent: Can't compare (excluded by WHERE clause)
SELECT 
    child.model_name,
    child.accuracy AS child_accuracy,
    parent.model_name AS parent_model_name,
    parent.accuracy AS parent_accuracy,
    (child.accuracy - parent.accuracy) AS accuracy_improvement
                            -- WHAT: Difference in accuracy (positive = improvement)
                            -- WHY: Quantify the benefit of fine-tuning
                            -- WHAT IF this is negative: Fine-tuning made the model worse (overfitting?)
FROM 
    models child
INNER JOIN                  -- WHAT: Using INNER JOIN here (not LEFT)
                            -- WHY: We only care about models with parents (base models are excluded)
    models parent
ON 
    child.parent_model_id = parent.model_id
WHERE 
    child.accuracy > parent.accuracy;   
                            -- WHAT: Filters for improvements only
                            -- WHY: Highlight successful fine-tuning experiments
                            -- WHAT IF we omit this: Would see all fine-tuned models (including those that degraded)

-- RESULT INTERPRETATION:
-- Expected: 4 rows (all fine-tuned models improved in this example)
-- If a model's accuracy decreased, it wouldn't appear here

-- ----------------------------------------------------------------------------
-- SCENARIO 3: Hierarchical Query (Find all descendants of a base model)
-- ----------------------------------------------------------------------------

-- WHAT: Multi-level self-join to show the full lineage chain
-- WHY: Trace the evolution of a model family (GPT-Base → v1 → v2 → v3...)
-- WHAT IF we had 10 generations: Would need 10 self-joins (this is where recursive CTEs help, covered in Module 8)
SELECT 
    grandparent.model_name AS generation_1,     
                            -- WHAT: The original base model
    
    parent.model_name AS generation_2,          
                            -- WHAT: First fine-tuned version
    
    child.model_name AS generation_3,           
                            -- WHAT: Second fine-tuned version
    
    grandparent.accuracy AS gen1_accuracy,
    parent.accuracy AS gen2_accuracy,
    child.accuracy AS gen3_accuracy
FROM 
    models grandparent
INNER JOIN 
    models parent 
ON 
    parent.parent_model_id = grandparent.model_id
INNER JOIN 
    models child 
ON 
    child.parent_model_id = parent.model_id;    
                            -- WHAT: Chain of joins (grandparent → parent → child)
                            -- WHY: Shows 3-generation lineage
                            -- WHAT IF we had 5 generations: Would need 5 JOINs (gets unwieldy, use recursive CTEs instead)

-- RESULT INTERPRETATION:
-- Expected: 1 row (GPT-Base → GPT-FineTuned-v1 → GPT-FineTuned-v2)
-- This shows the full evolution of the GPT model family

-- ----------------------------------------------------------------------------
-- MLOps CONTEXT: Finding Model Lineage (Real-World Self-Join Use Case)
-- ----------------------------------------------------------------------------

-- SCENARIO: Your startup has 500 model versions. A critical bug was found in 
-- GPT-Base (model_id = 1). You need to find ALL models that were derived from 
-- GPT-Base (directly or indirectly) so you can retrain them.

-- Simple case: Find direct children
-- WHAT: Models where parent_model_id = 1 (GPT-Base)
-- WHY: Immediate descendants need retraining
-- WHAT IF we only run this: Would miss grandchildren (v2 was trained from v1, which came from GPT-Base)
SELECT 
    model_id,
    model_name,
    parent_model_id
FROM 
    models
WHERE 
    parent_model_id = 1;    -- WHAT: Filter for models whose parent is GPT-Base
                            -- WHY: These were directly fine-tuned from the buggy base model
                            -- WHAT IF we use LIKE: Can't (parent_model_id is an integer, not text)

-- RESULT: Shows GPT-FineTuned-v1 (direct child)
-- MISSING: GPT-FineTuned-v2 (grandchild, indirectly affected)

-- Better approach: Self-join to find children and grandchildren
SELECT 
    gen1.model_name AS direct_child,
    gen2.model_name AS grandchild
FROM 
    models gen1
LEFT JOIN 
    models gen2 
ON 
    gen2.parent_model_id = gen1.model_id
WHERE 
    gen1.parent_model_id = 1;   
                            -- WHAT: Find models whose parent is GPT-Base, then their children
                            -- WHY: Captures 2 levels of lineage
                            -- WHAT IF we needed 5 levels: Use recursive CTE (Module 8.1)

-- RESULT: 
-- Row 1: direct_child = 'GPT-FineTuned-v1', grandchild = 'GPT-FineTuned-v2'
-- Now we know to retrain BOTH v1 and v2

-- ============================================================================
-- KEY TAKEAWAYS FOR MLOps ENGINEERS
-- ============================================================================

-- 1. INNER JOIN: Use for feature engineering when you only care about users 
--    with activity (training data for recommendation models).
--
-- 2. LEFT JOIN: Use for churn analysis (include inactive users) or when you 
--    need to preserve all records from the primary table.
--
-- 3. RIGHT JOIN: Almost never used (just swap tables and use LEFT JOIN).
--
-- 4. FULL OUTER JOIN: Use for data reconciliation (finding gaps between 
--    production logs and scheduled jobs).
--
-- 5. SELF-JOIN: Use for hierarchical data (org charts, model lineage, 
--    referral chains) or comparing rows within the same table.
--
-- 6. ALWAYS use table aliases (u, t) to make queries readable.
--
-- 7. ALWAYS specify the join condition (ON clause) explicitly (don't rely 
--    on implicit joins like "FROM users, transactions WHERE users.id = transactions.user_id").
--
-- 8. Count wisely: COUNT(*) counts rows, COUNT(column) counts non-NULL values.
--
-- 9. Handle NULLs: Use COALESCE in aggregations when working with LEFT/FULL OUTER JOINs.
--
-- 10. Do aggregations in the database, not in pandas (PostgreSQL is faster 
--     and more memory-efficient).

-- ============================================================================
-- END OF SEGMENT 3.1
-- ============================================================================































>>>>>>> Stashed changes




