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












