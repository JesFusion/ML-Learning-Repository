import time
import logging
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType, StructField,
    StringType, IntegerType,
    DoubleType
)





# A conditional statement that always evaluates to true, executing the block below.
if True:

    # Initializes a logger instance named "PyTorch Learning".
    log = logging.getLogger(name = "PyTorch Learning")

    # Sets the minimum logging level to DEBUG to capture all log messages.
    log.setLevel(level = logging.DEBUG)

    # Creates a stream handler to send log output to the console.
    handler_1 = logging.StreamHandler()

    # Sets the stream handler's logging level to INFO.
    handler_1.setLevel(level = logging.INFO)

    # Defines a logging format that prints the message followed by a newline.
    format_1 = logging.Formatter(fmt = '%(message)s\n')

    # Applies the defined format to the stream handler.
    handler_1.setFormatter(fmt = format_1)

    # Attaches the configured stream handler to the logger.
    log.addHandler(hdlr = handler_1)



log.info(f"Running on device ")





spark_instance = (
    SparkSession.builder
    .appName(
        name = "Segment 1.1 & 1.2",
    )
    .master(
        master = 'local[4]'
    )
    .config(
        key = 'spark.driver.memory',
        value = '2g'
    )
    .config(
        key = 'sparl.sql.shuffle.partitions',
        value = '4'
    )
    .getOrCreate()
)



spark_instance.sparkContext.setLogLevel(
    logLevel = "WARN"
)


theSchema = StructType(
    fields = [
        StructField(
            name = "userID",
            dataType = IntegerType(),
            nullable = False
        ),


        StructField(
            name = "Name",
            dataType = StringType(),
            nullable = True
        ),


        StructField(
            name = "Country",
            dataType = StringType(),
            nullable = True
        ),


        StructField(
            name = "Age",
            dataType = IntegerType(),
            nullable = True
        ),


        StructField(
            name = "Department",
            dataType = StringType(),
            nullable = True
        ),


        StructField(
            name = "Salary",
            dataType = DoubleType(),
            nullable = True
        )
    ]
)




dataframe = (
    spark_instance.range(
    start = 0,
    end = 10001
    )
    .withColumn(
        colName = 'userID',
        col = F.col('id').cast(
            to = IntegerType()
        )
    )
    .withColumn(
        colName = 'Name',
        col = F.concat(
            F.lit("User-"),
            F.col('id').cast(
                to = 'string'
            )
        )
    )
    .withColumn(
        colName = 'Country',
        col = F.when(
            condition = (
                F.col('id') % 5 == 0
            ),

            value = "Nigeria"
        ) \
        
        
    )

)






















