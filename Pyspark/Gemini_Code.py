# =============================================================================
# MODULE 1: THE PARADIGM SHIFT — DISTRIBUTED ARCHITECTURE & EXECUTION
# Segments 1.1 & 1.2
# =============================================================================
# HOW TO RUN:
#   pip install pyspark
#   python module1_spark_fundamentals.py
# =============================================================================

from pyspark.sql import SparkSession
from pyspark.sql import functions as F   # The native Spark functions library. ALWAYS alias as F.
from pyspark.sql.types import (
    StructType,      # Defines the schema (the full table blueprint)
    StructField,     # Defines one column inside a StructType
    StringType,      # Spark's string data type
    IntegerType,     # Spark's integer data type
    DoubleType,      # Spark's double-precision float type
)
import time          # Used to measure execution time to prove a point about .count()

# --- SPARKSESSION: THE ENTRY POINT TO EVERYTHING ---
# SparkSession is the single object through which you interact with Spark.
# Think of it as the "CEO's office" — all orders go through here.
#
# .builder: Accesses the builder pattern to configure the session before creating it.
# .appName(): Tags this job with a name visible in the Spark UI.
# .master("local[4]"): Runs Spark locally on your machine using 4 threads.
#   "local[4]" simulates a mini-cluster with 4 executor cores on your laptop.
#   On a real Databricks cluster, this line is absent — the cluster manages it.
# .config(): Injects Spark configuration key-value pairs.
#   "spark.driver.memory": Allocates 2GB of RAM to the Driver JVM process.
#   "spark.sql.shuffle.partitions": Overrides the DEFAULT of 200 shuffle partitions. 200 is absurd for a local machine — we set it to 4 to match our local[4] cores.
# .getOrCreate(): Creates a new session, or returns the existing one if already running.
spark = SparkSession.builder \
    .appName(name="Module1_Spark_Fundamentals") \
    .master(master="local[4]") \
    .config(key="spark.driver.memory", value="2g") \
    .config(key="spark.sql.shuffle.partitions", value="4") \
    .getOrCreate()

# Suppress Spark's chatty INFO logs so our print() output is readable.
# "WARN" means: only show warnings and errors, silence everything else.
spark.sparkContext.setLogLevel(logLevel="WARN")


# ==========================================================================
# --- GLOBAL DATA SETUP ---
# We create ONE synthetic dataset here at the top and reuse it across segments.
# Synthetic data because: no file downloads, no external dependencies, and we
# control the data to make specific points (e.g., injecting a skewed column).
# ===========================================================================

# [Strategy: We explicitly define the schema instead of letting Spark infer it.
#  Schema inference forces Spark to do a full read of the data first just to
#  guess types. On large datasets, that's an expensive wasted job. Always define
#  your schema upfront in production.]
#
# StructType() takes a list of StructField objects — one per column.
# StructField(name, dataType, nullable):
#   name: The column name string.
#   dataType: The Spark type for that column.
#   nullable: Whether NULL values are allowed in this column.
schema = StructType(fields=[
    StructField(name="user_id",    dataType=IntegerType(), nullable=False),


    StructField(name="name",       dataType=StringType(),  nullable=True),


    StructField(name="country",    dataType=StringType(),  nullable=True),


    StructField(name="age",        dataType=IntegerType(), nullable=True),


    StructField(name="department", dataType=StringType(),  nullable=True),


    StructField(name="salary",     dataType=DoubleType(),  nullable=True),
])

# [Strategy: We create 10,000 rows so partitioning is visible and meaningful.
#  Each row is a tuple matching the schema column order exactly.]
#
# spark.range() generates a sequence of integers from 0 to n-1, distributedStringType
# across partitions. We use it as a seed to generate our synthetic columns.
#
# .withColumn(): Adds or replaces a column. Takes (colName, columnExpression).
# F.col(): References an existing column by name.
# F.lit(): Creates a column of a literal (constant) value.
# (F.col("id") % 5): Modulo operation — gives us values 0,1,2,3,4 cyclically.
# F.when().when().otherwise(): Spark's vectorized IF-ELSE chain. Evaluates
#   conditions top to bottom and returns the first match.
raw_df = spark.range(start=0, end=10000) \
    .withColumn(
        colName="user_id",
        col=F.col(str="id").cast(to=IntegerType())
    ) \
    .withColumn(
        colName="name",
        # F.concat() joins strings together. F.lit() wraps a plain string as a column value.
        col=F.concat(F.lit("User_"), F.col("id").cast(to="string"))
    ) \
    .withColumn(
        colName="country",
        # F.when(condition, value): If condition is true, return value.
        # .when(): Chain additional conditions.
        # .otherwise(): The fallback if no condition matched.
        col=F.when(condition=(F.col("id") % 5 == 0), value="Nigeria") \
            .when(condition=(F.col("id") % 5 == 1), value="USA") \
            .when(condition=(F.col("id") % 5 == 2), value="UK") \
            .when(condition=(F.col("id") % 5 == 3), value="Canada") \
            .otherwise(value="Germany")
    ) \
    .withColumn(
        colName="age",
        # (F.col("id") % 42 + 18): Creates ages cycling from 18 to 59.
        col=(F.col("id") % 42 + 18).cast(to=IntegerType())
    ) \
    .withColumn(
        colName="department",
        col=F.when(condition=(F.col("id") % 4 == 0), value="Engineering") \
            .when(condition=(F.col("id") % 4 == 1), value="Sales") \
            .when(condition=(F.col("id") % 4 == 2), value="Marketing") \
            .otherwise(value="HR")
    ) \
    .withColumn(
        colName="salary",
        # F.round(): Rounds to N decimal places. Here we generate salary as
        # a float: base of 40000 + (id * 3.7 mod 60000) to create variation.
        col=F.round(
            col=(F.lit(40000.0) + (F.col("id") * F.lit(3.7)) % F.lit(60000)),
            scale=2
        )
    ) \
    .drop(col="id")  # Remove the raw seed column — it served its purpose.


# =============================================================================
print("\n" + "="*70)
print("  SEGMENT 1.1: CLUSTER MECHANICS & THE SPARK ABSTRACTION")
print("="*70 + "\n")
# =============================================================================


# --- 1.1.A: INSPECTING THE CLUSTER CONFIGURATION ---
print("--- 1.1.A: CLUSTER CONFIGURATION (Driver's View) ---\n")

# spark.sparkContext exposes the low-level SparkContext object, which manages
# the connection between the Driver and the cluster.
sc = spark.sparkContext

# .appName: The name we gave this job — visible in the Spark UI.
print(f"  App Name      : {sc.appName}")

# .master: Shows which cluster manager is being used.
# "local[4]" = our laptop simulation. A real cluster shows "yarn" or "k8s://...".
print(f"  Master        : {sc.master}")

# .defaultParallelism: The default number of parallel tasks Spark will use.
# On local[4], this equals 4 (our 4 simulated cores).
# On a real cluster with 10 workers × 4 cores each = 40.
print(f"  Default Parallelism (Simulated Executor Cores): {sc.defaultParallelism}")

# spark.conf.get(): Reads a Spark configuration value by its key.
# We're reading back the shuffle.partitions value we set at session creation.
shuffle_partitions = spark.conf.get(key="spark.sql.shuffle.partitions")
print(f"  Shuffle Partitions (our override): {shuffle_partitions}")
print()


# --- 1.1.B: PARTITIONS — THE CURRENCY OF SPARK ---
print("--- 1.1.B: PARTITIONS — HOW DATA IS PHYSICALLY DISTRIBUTED ---\n")

# .rdd: Accesses the underlying low-level RDD (Resilient Distributed Dataset).
# .getNumPartitions(): Returns the number of physical partitions this DataFrame
# is currently split into across the cluster.
num_partitions = raw_df.rdd.getNumPartitions()
print(f"  Total Rows    : 10,000")
print(f"  Num Partitions: {num_partitions}")
print(f"  Approx Rows/Partition: {10000 // num_partitions}")
print()
print("  [CONCEPT] Each partition is processed by ONE Task on ONE Executor core.")
print("  With local[4], Spark runs up to 4 partitions in parallel.")
print("  More partitions = more parallelism (up to your core count limit).")
print()

# .repartition(n): Triggers a FULL SHUFFLE to redistribute data into exactly N
# equal partitions. This is a WIDE transformation — data moves across the network.
# [Strategy: We increase partitions here to demonstrate the concept. In real
#  workloads, you repartition before expensive wide operations to ensure even
#  distribution and avoid data skew.]
df_repartitioned = raw_df.repartition(numPartitions=8)
print(f"  After .repartition(8): {df_repartitioned.rdd.getNumPartitions()} partitions")

# .coalesce(n): Reduces partitions WITHOUT a full shuffle by merging adjacent
# partitions on the same Executor. Cheaper than repartition when reducing.
# WARNING: Never coalesce BEFORE a wide transformation (like groupBy or join).
# You'd collapse parallelism right before the most expensive operation.
df_coalesced = raw_df.coalesce(num_partitions=2)
print(f"  After .coalesce(2)   : {df_coalesced.rdd.getNumPartitions()} partitions")
print()


# --- 1.1.C: df.count() vs len() — THE COST OF DISTRIBUTED COUNTING ---
print("--- 1.1.C: THE HIDDEN COST OF df.count() ---\n")

print("  [In Pandas]  len(df) → O(1). Reads internal metadata. Zero compute.")
print("  [In Spark]   df.count() → Full distributed job. Reads ALL partitions.")
print()

# We time the .count() call to make the point visceral.
# time.time(): Returns the current time as a float (seconds since epoch).
start_time = time.time()

# .count(): This is an ACTION. It triggers the ENTIRE DAG to execute.
# Spark reads every partition, counts rows locally per-Executor,
# then shuffles partial counts back to the Driver to sum them.
row_count = raw_df.count()

elapsed = time.time() - start_time

print(f"  Row Count     : {row_count:,}")
print(f"  Time Elapsed  : {elapsed:.4f} seconds")
print()
print("  [NOTE] Even on 10K rows locally, .count() spins up a full Spark job.")
print("  On 10TB of data across a real cluster, this scan costs real money.")
print("  Rule: Only call .count() when you genuinely need the number.")
print()


# --- 1.1.D: THE DANGER OF .collect() ---
print("--- 1.1.D: .collect() — THE DRIVER KILLER ---\n")

# [Strategy: We filter down to a tiny subset BEFORE collecting.
#  This is the ONLY safe pattern for .collect() — you must be certain
#  the result set is small enough to fit in the Driver's RAM.]
#
# .filter(): A NARROW transformation. Each partition is filtered independently.
# No data moves between Executors. Fast, local, efficient.
tiny_subset = raw_df.filter(condition=F.col(str="user_id") < 5)

# .collect(): An ACTION. Pulls ALL rows from ALL Executors to the Driver
# as a Python list of Row objects.
collected_rows = tiny_subset.collect()

print(f"  Safe .collect() on {len(collected_rows)} rows (intentionally tiny subset):")
for row in collected_rows:
    # row["column_name"]: Access a field from a Spark Row object like a dict key.
    print(f"    user_id={row['user_id']}  name={row['name']}  country={row['country']}")

print()
print("  [ANTI-PATTERN] Never do this:")
print("    all_data = raw_df.collect()  # 10TB → Driver OOM crash")
print("  [SAFE PATTERN] Only collect AFTER aggressive filtering/aggregation.")
print()


# =============================================================================
print("\n" + "="*70)
print("  SEGMENT 1.2: LAZY EVALUATION & THE CATALYST OPTIMIZER")
print("="*70 + "\n")
# =============================================================================


# --- 1.2.A: PROVING LAZY EVALUATION — TRANSFORMATIONS DO NOTHING ---
print("--- 1.2.A: LAZY EVALUATION — TRANSFORMATIONS ARE JUST PLANS ---\n")

print("  Building a chain of 4 transformations...")
print("  Watch: zero execution happens until an Action is called.\n")

# TRANSFORMATION 1 — Narrow: .filter()
# Adds a Filter node to the logical plan. No data read. No compute.
t1_filter = raw_df.filter(condition=F.col(str="country") == "Nigeria")

# TRANSFORMATION 2 — Narrow: .select()
# Adds a Project (column selection) node to the plan.
t2_select = t1_filter.select("user_id", "name", "age", "salary", "department")

# TRANSFORMATION 3 — Narrow: .withColumn()
# Adds a new computed column node to the plan.
# F.col("salary") * 1.1: Gives a 10% salary raise.
t3_raise = t2_select.withColumn(
    colName="salary_after_raise",
    col=F.round(col=F.col(str="salary") * F.lit(1.1), scale=2)
)

# TRANSFORMATION 4 — Wide: .groupBy().agg()
# THIS crosses a Stage boundary. A shuffle will be required.
# groupBy(): Declares partitioning by "department". Wide transformation.
# .agg(): Declares the aggregation functions to apply per group.
# F.count("*"): Counts all rows in each group.
# F.avg(): Computes the mean of a column.
# F.alias(): Renames the resulting aggregated column.
t4_agg = t3_raise.groupBy(F.col(str="department")).agg(
    F.count(col="*").alias(alias="headcount"),
    F.round(
        col=F.avg(col="salary_after_raise"),
        scale=2
    ).alias(alias="avg_salary_after_raise")
)

print("  4 transformations defined. Has ANY data been read or computed? NO.")
print("  Spark is holding a blueprint. Nothing happened yet.")
print()

# NOW we trigger an ACTION — .show() demands actual results.
# [Strategy: .show() is safer than .collect() for learning/debugging because
#  it only returns the first N rows to the Driver, not everything.]
#
# n=10: Show at most 10 rows.
# truncate=False: Don't cut off long column values with "...".
print("  Triggering ACTION: .show() — now the full plan executes:\n")
t4_agg.show(n=10, truncate=False)


# --- 1.2.B: NARROW VS. WIDE TRANSFORMATIONS ---
print("--- 1.2.B: NARROW vs. WIDE TRANSFORMATIONS (STAGE BOUNDARIES) ---\n")

print("  NARROW (no shuffle): filter, select, withColumn")
print("  → Each partition processed independently on its Executor.")
print("  → No data crosses the network.")
print()
print("  WIDE (shuffle required): groupBy, join, distinct, repartition")
print("  → Data must be reorganized across ALL partitions.")
print("  → Causes a Stage boundary in the DAG.")
print("  → Most expensive operation in distributed computing.")
print()

# Demonstrating: a narrow-only pipeline vs a wide pipeline.
# We time both to make the cost visible even on a local machine.

# --- NARROW ONLY ---
narrow_start = time.time()
narrow_result = raw_df \
    .filter(condition=F.col(str="age") > 30) \
    .select("user_id", "name", "salary") \
    .withColumn(
        colName="senior_flag",
        # F.lit(True): A column of the literal boolean value True.
        col=F.lit(value=True)
    )
# .count() triggers the narrow pipeline
narrow_count = narrow_result.count()
narrow_elapsed = time.time() - narrow_start
print(f"  Narrow pipeline result : {narrow_count:,} rows | Time: {narrow_elapsed:.4f}s")

# --- WIDE (groupBy = shuffle) ---
wide_start = time.time()
wide_result = raw_df \
    .filter(condition=F.col(str="age") > 30) \
    .groupBy(F.col(str="department")) \
    .agg(F.count(col="*").alias(alias="count"))
wide_result.show(n=10, truncate=False)
wide_elapsed = time.time() - wide_start
print(f"  Wide pipeline time     : {wide_elapsed:.4f}s (shuffle overhead visible)\n")


# --- 1.2.C: THE CATALYST OPTIMIZER — PREDICATE PUSHDOWN & COLUMN PRUNING ---
print("--- 1.2.C: CATALYST IN ACTION — PREDICATE PUSHDOWN & COLUMN PRUNING ---\n")

# [Strategy: To see predicate pushdown in action, we write the DataFrame
#  to Parquet first, then read it back with a filter. When reading from a
#  columnar file (Parquet), Catalyst can push the filter INTO the file scan
#  itself — meaning rows that don't match never enter Spark's memory at all.]

import tempfile    # Standard Python library for creating temporary directories.
import os

# tempfile.mkdtemp(): Creates a unique empty temporary directory and returns its path.
# We use a temp dir so we don't litter the filesystem.
temp_dir = tempfile.mkdtemp()
parquet_path = os.path.join(temp_dir, "users_parquet")

# .write: Accesses the DataFrameWriter object.
# .mode("overwrite"): If files already exist at this path, replace them.
# .parquet(path): Writes the DataFrame in Parquet format to the given path.
raw_df.write.mode(saveMode="overwrite").parquet(path=parquet_path)

print("  DataFrame written to Parquet. Now reading back with a filter...\n")

# Read the Parquet back into a new DataFrame.
# spark.read.parquet(): Reads Parquet files. Spark auto-discovers the schema
# from the Parquet metadata (no need to re-specify it).
df_from_parquet = spark.read.parquet(parquet_path)

# Now define a filtered DataFrame — this is still LAZY (no data read yet).
df_nigerian_engineers = df_from_parquet.filter(
    condition=(F.col(str="country") == "Nigeria") & (F.col(str="department") == "Engineering")
# & operator: Spark's column-level AND. Both conditions must be true.
).select("user_id", "name", "salary")
# .select() here triggers Column Pruning — Catalyst will tell Parquet
# to ONLY deserialize the user_id, name, and salary columns from disk.


# --- 1.2.D: THE explain() METHOD — READING THE PHYSICAL PLAN ---
print("--- 1.2.D: explain() — YOUR WINDOW INTO CATALYST'S BRAIN ---\n")

print("  Physical Plan for the filtered Parquet query:")
print("  (Read BOTTOM-UP: bottom = first operation, top = last operation)\n")

# .explain(): Prints the execution plan Spark INTENDS to run.
# mode="formatted": Provides a clean, human-readable formatted output.
# This does NOT execute the query — it's purely a diagnostic tool.
df_nigerian_engineers.explain(mode="formatted")

print()
print("  KEY THINGS TO SPOT IN THE PLAN ABOVE:")
print("  1. 'PushedFilters' inside the FileScan line:")
print("     → Catalyst pushed our .filter() INTO the Parquet file scan.")
print("     → Rows that don't match 'Nigeria' + 'Engineering' are NEVER loaded.")
print()
print("  2. 'ReadSchema' inside FileScan shows only 3 columns listed:")
print("     → Column Pruning at work. Spark only reads user_id, name, salary.")
print("     → The 'age', 'department', 'country' columns are NEVER deserialized.")
print()
print("  3. No 'Exchange' node in this plan:")
print("     → No shuffle. Our filter + select is all narrow transformations.")
print("     → Cheap, parallel, no network cost.")
print()

# Now let's show the plan for the WIDE transformation to contrast.
print("  Physical Plan for the groupBy() (Wide Transformation):\n")

df_wide_plan = df_from_parquet \
    .filter(condition=F.col(str="age") > 30) \
    .groupBy(F.col(str="country")) \
    .agg(F.avg(col="salary").alias(alias="avg_salary"))

df_wide_plan.explain(mode="formatted")

print()
print("  KEY THINGS TO SPOT IN THE WIDE PLAN ABOVE:")
print("  1. 'Exchange' node:")
print("     → This IS the shuffle. Data physically moves across partitions here.")
print("     → Everything ABOVE Exchange is the reduce phase (post-shuffle).")
print("     → Everything BELOW Exchange is the map phase (pre-shuffle).")
print()
print("  2. 'HashAggregate' appears TWICE:")
print("     → Catalyst is smart: it does a PARTIAL aggregation before the shuffle")
print("       (bottom HashAggregate), then a FINAL aggregation after (top).")
print("     → This minimizes the data volume that crosses the network.")
print()

# Final result to confirm everything works end-to-end.
print("--- FINAL OUTPUT: Nigerian Engineers After Raise ---\n")

final_result = df_from_parquet \
    .filter(
        condition=(F.col(str="country") == "Nigeria") & (F.col(str="department") == "Engineering")
    ) \
    .withColumn(
        colName="salary_after_raise",
        col=F.round(col=F.col(str="salary") * F.lit(1.1), scale=2)
    ) \
    .select("user_id", "name", "salary", "salary_after_raise") \
    .orderBy(F.col(str="salary").desc()) \
    .limit(num=10)
# .orderBy(): Sorts the entire DataFrame. Wide transformation (requires shuffle).
# .desc(): Sorts in descending order (highest salary first).
# .limit(n): Returns at most n rows. Spark pushes this down to minimize data read.

final_result.show(n=10, truncate=False)

print()
print("="*70)
print("  MODULE 1 COMPLETE. Spark session alive — run next batch to continue.")
print("="*70 + "\n")

# --- CLEANUP ---
# Always stop the SparkSession when you're done. Releases JVM memory,
# shuts down the Executor threads, and closes the Py4J gateway server.
spark.stop()