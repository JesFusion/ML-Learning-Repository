<<<<<<< Updated upstream


-- =============================================================================
-- SEGMENT 2.2: THE STRUCTURE (Normalization → Feature Store Schema)
-- Goal: Design a normalized Feature Store, then build a de-normalized
--       flat view of it for fast real-time inference reads.
-- =============================================================================

DROP TABLE IF EXISTS feature_values CASCADE;
DROP TABLE IF EXISTS feature_definitions CASCADE;
DROP TABLE IF EXISTS entities CASCADE;


-- [WHY: This is the "entities" table — the THINGS we're computing features FOR.
--  In a recommendation system, entities are users. Could also be products, sessions, etc.
--  This is 3NF: entity_email and entity_name depend ONLY on entity_id (the PK).]
CREATE TABLE entities (
    entity_id   SERIAL          PRIMARY KEY,
    entity_name VARCHAR(100)    NOT NULL,
    entity_type VARCHAR(50)     NOT NULL,   -- e.g., 'user', 'product', 'session'
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);


-- [WHY: This table defines WHAT each feature is — its name, type, and description.
--  Separating feature definitions from feature values is 2NF in action.
--  The feature's name and description depend on feature_id alone, not on any entity.]
CREATE TABLE feature_definitions (
    feature_id      SERIAL          PRIMARY KEY,
    feature_name    VARCHAR(100)    NOT NULL UNIQUE,    -- e.g., 'days_since_login'
    data_type       VARCHAR(30)     NOT NULL,           -- e.g., 'FLOAT', 'INTEGER'
    description     TEXT
);


-- [WHY: This is the junction/fact table. It stores the ACTUAL computed values.
--  Each row answers: "For entity X, what is the value of feature Y?"
--  This is fully normalized (3NF). Both FKs point to their respective tables.
--  WHAT: The composite UNIQUE constraint prevents duplicate entries for the
--        same entity-feature pair.]
CREATE TABLE feature_values (
    value_id        SERIAL          PRIMARY KEY,
    entity_id       INT             NOT NULL REFERENCES entities(entity_id) ON DELETE CASCADE,
    feature_id      INT             NOT NULL REFERENCES feature_definitions(feature_id) ON DELETE CASCADE,
    feature_value   FLOAT           NOT NULL,
    computed_at     TIMESTAMP       NOT NULL DEFAULT NOW(),

    -- [WHY: This prevents the same feature being logged twice for the same entity
    --  at the same timestamp — a common bug in feature pipelines.]
    UNIQUE (entity_id, feature_id, computed_at)
);


-- Seed the normalized Feature Store with data
INSERT INTO entities (entity_name, entity_type) VALUES
    ('jesse_nwachukwu', 'user'),
    ('ada_okafor',      'user'),
    ('chidi_eze',       'user');

INSERT INTO feature_definitions (feature_name, data_type, description) VALUES
    ('days_since_login',    'INTEGER',  'Number of days since the user last logged in'),
    ('total_transactions',  'INTEGER',  'Total number of completed transactions'),
    ('avg_session_duration','FLOAT',    'Average session length in minutes');

-- [WHY: entity_id 1 = jesse, 2 = ada, 3 = chidi. feature_id 1,2,3 per definition above.]
INSERT INTO feature_values (entity_id, feature_id, feature_value) VALUES
    (1, 1, 2.0),   -- jesse: days_since_login = 2
    (1, 2, 150.0), -- jesse: total_transactions = 150
    (1, 3, 8.5),   -- jesse: avg_session_duration = 8.5 mins
    (2, 1, 14.0),  -- ada: days_since_login = 14
    (2, 2, 43.0),  -- ada: total_transactions = 43
    (2, 3, 3.2),   -- ada: avg_session_duration = 3.2 mins
    (3, 1, 1.0),   -- chidi: days_since_login = 1
    (3, 2, 280.0), -- chidi: total_transactions = 280
    (3, 3, 12.1);  -- chidi: avg_session_duration = 12.1 mins


-- View the raw normalized data (requires JOINs — this is the "expensive" read)
SELECT
    e.entity_name,
    fd.feature_name,
    fv.feature_value
FROM feature_values      fv
JOIN entities            e   ON e.entity_id   = fv.entity_id
JOIN feature_definitions fd  ON fd.feature_id = fv.feature_id
ORDER BY e.entity_name, fd.feature_name;


-- [WHY: De-normalization for inference speed.
--  The query above with 2 JOINs is too slow when you need to serve predictions
--  in under 50ms. We pivot the data into a flat, wide table — one row per user,
--  all features as columns. No joins at read time.
--  WHAT: CREATE VIEW saves this query as a named virtual table. We call it like a
--        regular table but it's computed on the fly from the underlying tables.]
CREATE OR REPLACE VIEW flat_feature_store AS
SELECT
    e.entity_id,
    e.entity_name,
    -- [WHAT: FILTER (WHERE ...) applies a condition to an aggregation.
    --  We use MAX() here because after filtering, only one value remains per feature.
    --  This is the SQL "pivot" pattern — converting rows into columns.]
    MAX(fv.feature_value) FILTER (WHERE fd.feature_name = 'days_since_login')      AS days_since_login,
    MAX(fv.feature_value) FILTER (WHERE fd.feature_name = 'total_transactions')    AS total_transactions,
    MAX(fv.feature_value) FILTER (WHERE fd.feature_name = 'avg_session_duration')  AS avg_session_duration
FROM feature_values      fv
JOIN entities            e   ON e.entity_id   = fv.entity_id
JOIN feature_definitions fd  ON fd.feature_id = fv.feature_id
GROUP BY e.entity_id, e.entity_name;


-- [WHY: This is the "fast inference read." One row per user, all features ready.
--  In production, your ML model's prediction service hits THIS view, not 3 joined tables.]
SELECT * FROM flat_feature_store ORDER BY entity_id;




-- =============================================================================
-- SEGMENT 2.3: THE FLEXIBLE (JSONB & Unstructured Data)
-- Goal: Store model hyperparameters as JSONB and query inside them —
--       without ever running ALTER TABLE when new params are added.
-- =============================================================================

DROP TABLE IF EXISTS model_experiments CASCADE;


-- [WHAT: JSONB stores JSON data in a decomposed binary format.
--  WHY: We use JSONB (not JSON) because it supports GIN indexing and is
--       significantly faster for reads — which is what we do most in analytics.
--  WHY: The hyperparameters column has NO fixed structure. Each experiment
--       can store completely different keys. Zero schema migrations needed.]
CREATE TABLE model_experiments (
    experiment_id   SERIAL          PRIMARY KEY,
    model_name      VARCHAR(150)    NOT NULL,
    version_tag     VARCHAR(30)     NOT NULL UNIQUE,
    hyperparameters JSONB,                          -- The flexible column
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);


-- [WHY: Notice each row's hyperparameters JSON is completely different in structure.
--  experiment 1: simple flat config
--  experiment 2: introduces dropout_rate (new key — no ALTER TABLE needed)
--  experiment 3: nested JSON (scheduler is an object inside the object)
--  experiment 4: entirely different architecture params
--  All live happily in the same column.]
INSERT INTO model_experiments (model_name, version_tag, hyperparameters) VALUES
(
    'ResNet Baseline', 'v1.0.0',
    '{"learning_rate": 0.001, "batch_size": 32, "optimizer": "sgd", "epochs": 20}'
),
(
    'ResNet + Dropout', 'v1.1.0',
    '{"learning_rate": 0.001, "batch_size": 64, "optimizer": "adam", "dropout_rate": 0.3, "epochs": 30}'
),
(
    'ResNet + Scheduler', 'v1.2.0',
    '{"learning_rate": 0.0003, "batch_size": 128, "optimizer": "adam", "dropout_rate": 0.5, "scheduler": {"type": "cosine_annealing", "warmup_steps": 500}, "epochs": 50}'
),
(
    'BERT Fine-Tune', 'v2.0.0',
    '{"learning_rate": 0.00002, "batch_size": 16, "optimizer": "adamw", "weight_decay": 0.01, "max_seq_length": 512, "epochs": 3}'
);


-- --- QUERYING INSIDE JSONB ---

-- [WHAT: The -> operator extracts a value from JSONB, returning it as a JSONB type.
--  WHY: We use -> here to retrieve the nested scheduler object.
--       The result is still a JSON object, so we can chain into it further.]
SELECT
    version_tag,
    hyperparameters -> 'scheduler' AS scheduler_config
FROM model_experiments
WHERE hyperparameters -> 'scheduler' IS NOT NULL;


-- [WHAT: The ->> operator extracts a value and returns it as plain TEXT.
--  WHY: We need TEXT (not JSON) for comparisons in WHERE clauses and for display.
--       You can't do WHERE jsonb_col -> 'optimizer' = 'adam' — types won't match.
--       You MUST use ->> to cast to text first.]
SELECT
    version_tag,
    hyperparameters ->> 'optimizer'     AS optimizer,
    hyperparameters ->> 'learning_rate' AS learning_rate,
    hyperparameters ->> 'batch_size'    AS batch_size
FROM model_experiments
ORDER BY version_tag;


-- [WHAT: @> is the "contains" operator. It checks if the left JSONB value
--        contains the right JSONB value as a subset.
--  WHY: This is the most efficient way to filter by a specific key-value pair
--       inside JSONB, especially when a GIN index is present (see Module 6).]
SELECT
    version_tag,
    hyperparameters
FROM model_experiments
WHERE hyperparameters @> '{"optimizer": "adam"}';


-- [WHY: Drilling into nested JSON. We chain -> to navigate into the scheduler
--  object first, then use ->> to extract the warmup_steps value as text.]
SELECT
    version_tag,
    hyperparameters -> 'scheduler' ->> 'warmup_steps' AS warmup_steps
FROM model_experiments
WHERE hyperparameters -> 'scheduler' IS NOT NULL;


-- [WHAT: CAST(..., FLOAT) converts a TEXT value extracted by ->> into a number.
--  WHY: All ->> extractions return TEXT. To do math (compare, sort, aggregate),
--       you must cast the value to the appropriate numeric type.]
SELECT
    version_tag,
    CAST(hyperparameters ->> 'learning_rate' AS FLOAT) AS lr_numeric
FROM model_experiments
ORDER BY lr_numeric ASC;


-- =============================================================================
-- END OF MODULE 2
-- =============================================================================

=======
-- ============================================================================
-- SEGMENT 3.1: THE WEAVER (JOINS)
-- ============================================================================
-- Goal: Master all join types to combine data from multiple tables
-- MLOps Context: Merging "User Tables" with "Transaction Tables" to create 
--                training datasets for recommendation models
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SETUP: Creating Our MLOps Scenario Tables
-- ----------------------------------------------------------------------------

-- DROP existing tables if they exist (for clean reruns)
-- WHY: Ensures we start fresh without schema conflicts
-- WHAT IF we skip this: CREATE TABLE will fail if tables already exist
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS models CASCADE;

-- Create the USERS table (our primary entity table)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,        -- WHAT: Auto-incrementing unique identifier
                                        -- WHY: Every user needs a unique ID for joins
                                        -- WHAT IF we used VARCHAR: Slower joins, more storage
    
    username VARCHAR(50) NOT NULL,      -- WHAT: User's display name
                                        -- WHY: NOT NULL ensures data quality (no anonymous users)
                                        -- WHAT IF we allowed NULL: Analytics would have incomplete user profiles
    
    email VARCHAR(100) UNIQUE NOT NULL, -- WHAT: User's email address
                                        -- WHY: UNIQUE prevents duplicate accounts, NOT NULL ensures we can contact users
                                        -- WHAT IF we skip UNIQUE: One person could create multiple accounts
    
    age INTEGER,                        -- WHAT: User's age (nullable for privacy)
                                        -- WHY: Used as a feature in ML models (age-based segmentation)
                                        -- WHAT IF we make this NOT NULL: Some users won't sign up (privacy concerns)
    
    location VARCHAR(100),              -- WHAT: User's city/region
                                        -- WHY: Geographic features improve recommendation quality
                                        -- WHAT IF we normalize this into a separate table: Better data integrity, but more complex joins
    
    signup_date DATE NOT NULL           -- WHAT: When the user created their account
                                        -- WHY: Calculate "days_since_signup" feature for churn prediction
                                        -- WHAT IF we use TIMESTAMP: More precision, but unnecessary for this use case
);

-- Create the TRANSACTIONS table (our event/activity table)
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,  -- WHAT: Unique transaction identifier
                                        -- WHY: Every purchase needs a unique ID for tracking
                                        -- WHAT IF we used composite key (user_id + timestamp): More complex, harder to reference
    
    user_id INTEGER NOT NULL,           -- WHAT: Foreign key linking to the users table
                                        -- WHY: Establishes the relationship "which user made this purchase"
                                        -- WHAT IF this was NULL: Orphaned transactions (can't attribute to a user)
    
    product_id INTEGER NOT NULL,        -- WHAT: Which product was purchased
                                        -- WHY: Enables product-level analytics (best sellers, category preferences)
                                        -- WHAT IF we stored product_name instead: Data duplication, inconsistent naming
    
    amount NUMERIC(10, 2) NOT NULL,     -- WHAT: Purchase amount in dollars (10 digits total, 2 after decimal)
                                        -- WHY: NUMERIC prevents floating-point errors (unlike FLOAT)
                                        -- WHAT IF we used INTEGER (cents): More storage efficient, but less readable
    
    transaction_date DATE NOT NULL,     -- WHAT: When the purchase occurred
                                        -- WHY: Time-based features (recency, frequency) for RFM analysis
                                        -- WHAT IF we used TIMESTAMP: Better for intraday analysis, but overkill for daily aggregates
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
                                        -- WHAT: Enforces referential integrity (user_id must exist in users table)
                                        -- WHY: Prevents orphaned transactions (transactions without a valid user)
                                        -- WHAT IF we skip this: Data corruption (transactions pointing to deleted users)
                                        -- ON DELETE CASCADE: If a user is deleted, their transactions are also deleted
);

-- Create the MODELS table (for demonstrating self-joins)
CREATE TABLE models (
    model_id SERIAL PRIMARY KEY,        -- WHAT: Unique model version identifier
                                        -- WHY: Track lineage of model iterations
                                        -- WHAT IF we used semantic versioning strings: Harder to sort, less efficient joins
    
    model_name VARCHAR(100) NOT NULL,   -- WHAT: Human-readable model name
                                        -- WHY: Engineers need descriptive names for model registry
                                        -- WHAT IF we only had model_id: Hard to identify models in dashboards
    
    parent_model_id INTEGER,            -- WHAT: References another model_id (the base model this was fine-tuned from)
                                        -- WHY: Enables hierarchical queries (find all descendants of GPT-Base)
                                        -- WHAT IF this was NOT NULL: Can't create a base model (every model would need a parent)
    
    accuracy NUMERIC(5, 4),             -- WHAT: Model's test accuracy (e.g., 0.9523 = 95.23%)
                                        -- WHY: Track performance improvements across versions
                                        -- WHAT IF we stored as percentage integer: Lose precision (95% vs 95.23%)
    
    created_date DATE NOT NULL,         -- WHAT: When this model version was trained
                                        -- WHY: Audit trail for model lineage
                                        -- WHAT IF we used TIMESTAMP: More precise, but DATE is sufficient for versioning
    
    FOREIGN KEY (parent_model_id) REFERENCES models(model_id) ON DELETE SET NULL
                                        -- WHAT: Self-referencing foreign key (points to the same table)
                                        -- WHY: Enables querying model lineage (which model was this fine-tuned from)
                                        -- ON DELETE SET NULL: If parent is deleted, this model's parent becomes NULL (not deleted)
);

-- ----------------------------------------------------------------------------
-- POPULATE TABLES WITH SAMPLE DATA
-- ----------------------------------------------------------------------------

-- Insert sample users
INSERT INTO users (username, email, age, location, signup_date) VALUES
    ('alice_ml', 'alice@startup.com', 28, 'San Francisco', '2023-01-15'),
    -- WHY these specific values: Realistic user profile for a tech startup
    -- WHAT IF age was NULL: Would demonstrate LEFT JOIN behavior with missing data
    
    ('bob_data', 'bob@company.io', 35, 'New York', '2023-02-20'),
    -- WHY different location: Tests geographic segmentation in GROUP BY queries
    
    ('charlie_ai', 'charlie@tech.net', 42, 'Austin', '2023-03-10'),
    -- WHY older age: Creates age distribution for cohort analysis
    
    ('diana_ops', 'diana@devops.com', 30, 'Seattle', '2023-04-05'),
    -- WHY Seattle: Adds another geographic segment
    
    ('eve_engineer', 'eve@mlops.org', 26, 'San Francisco', '2023-05-12');
    -- WHY same location as alice: Tests PARTITION BY location in window functions later
    -- WHAT IF we added 1 million users: JOIN performance would become critical (need indexes)

-- Insert sample transactions (note: not all users have transactions)
INSERT INTO transactions (user_id, product_id, amount, transaction_date) VALUES
    (1, 101, 49.99, '2023-01-20'),   -- Alice's first purchase (5 days after signup)
    -- WHY this date: Demonstrates quick conversion (good user engagement)
    
    (1, 102, 79.99, '2023-02-15'),   -- Alice's second purchase
    -- WHY 26 days later: Shows repeat purchase behavior (loyalty signal)
    
    (1, 103, 129.99, '2023-03-10'),  -- Alice's third purchase (increasing amounts = upsell success)
    -- WHY increasing amounts: Demonstrates customer lifetime value growth
    
    (2, 101, 49.99, '2023-03-01'),   -- Bob's first purchase (9 days after signup)
    -- WHY longer than Alice: Different user engagement pattern
    
    (2, 104, 199.99, '2023-03-15'),  -- Bob's second purchase (high-value)
    -- WHY high amount: Demonstrates variance in spending patterns (useful for STDDEV)
    
    (3, 102, 79.99, '2023-03-25'),   -- Charlie's only purchase (15 days after signup)
    -- WHY only one: Demonstrates at-risk user (churn prediction signal)
    
    (4, 101, 49.99, '2023-04-20');   -- Diana's only purchase
    -- NOTE: user_id 5 (Eve) has NO transactions (demonstrates LEFT JOIN behavior)
    -- WHY Eve has none: Tests NULL handling in aggregations

-- Insert sample models (hierarchical structure for self-joins)
INSERT INTO models (model_name, parent_model_id, accuracy, created_date) VALUES
    ('GPT-Base', NULL, 0.7823, '2023-01-01'),            
    -- WHY parent_model_id is NULL: This is the root model (no parent)
    -- WHAT IF all models had parents: Impossible to create the first model
    
    ('GPT-FineTuned-v1', 1, 0.8456, '2023-02-01'),       
    -- WHY parent_model_id = 1: This was fine-tuned from GPT-Base
    -- WHAT IF we didn't track lineage: Can't trace which models share a common ancestor
    
    ('GPT-FineTuned-v2', 2, 0.8912, '2023-03-01'),       
    -- WHY parent_model_id = 2: This was fine-tuned from v1 (3 generations deep)
    
    ('BERT-Base', NULL, 0.8012, '2023-01-15'),           
    -- WHY another NULL parent: Independent model family (not related to GPT lineage)
    
    ('BERT-FineTuned', 4, 0.8734, '2023-02-15');         
    -- WHY parent_model_id = 4: This was fine-tuned from BERT-Base

-- ----------------------------------------------------------------------------
-- PART 1: INNER JOIN (The Strict Matchmaker)
-- ----------------------------------------------------------------------------

-- Show only users who have made at least one purchase
-- WHAT: Returns rows where user_id exists in BOTH tables
-- WHY: For recommendation models, we only care about users with purchase history
-- WHAT IF we used LEFT JOIN: Would include Eve (user with no purchases), resulting in NULL values
SELECT 
    u.user_id,              -- WHAT: User's unique identifier from users table
                            -- WHY: Needed to identify which user this row belongs to
                            -- WHAT IF we omit this: Can't trace results back to specific users
    
    u.username,             -- WHAT: User's display name
                            -- WHY: Human-readable identifier for reports/dashboards
    
    u.age,                  -- WHAT: User demographic feature
                            -- WHY: Age is a strong predictor in collaborative filtering
    
    u.location,             -- WHAT: Geographic feature
                            -- WHY: Location-based recommendations (geo-targeting)
    
    t.transaction_id,       -- WHAT: Unique purchase identifier
                            -- WHY: Each row represents a distinct purchase event
    
    t.product_id,           -- WHAT: Which product was purchased
                            -- WHY: Item-based collaborative filtering needs product IDs
    
    t.amount,               -- WHAT: Purchase amount
                            -- WHY: Revenue-based features for customer lifetime value models
    
    t.transaction_date      -- WHAT: When the purchase occurred
                            -- WHY: Recency feature for RFM analysis (Recency, Frequency, Monetary)
FROM 
    users u                 -- WHAT: Left table (aliased as 'u' for brevity)
                            -- WHY: 'u' prefix makes it clear which table columns come from
                            -- WHAT IF we didn't use aliases: Query would be verbose (users.user_id, users.username...)
INNER JOIN 
    transactions t          -- WHAT: Right table (aliased as 't')
                            -- WHY: We're joining transaction data to user data
                            -- WHAT IF we swap table order (transactions INNER JOIN users): Same result (INNER JOIN is commutative)
ON 
    u.user_id = t.user_id;  -- WHAT: The join condition (how tables relate)
                            -- WHY: user_id is the foreign key linking transactions to users
                            -- WHAT IF we join on username instead: Slower (VARCHAR comparison vs INTEGER), fragile (username might change)

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
