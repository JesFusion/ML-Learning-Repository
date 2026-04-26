

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

