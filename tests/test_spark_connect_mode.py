
import os
from pyspark.sql.session import SparkSession
remote = "sc://localhost:15002"

spark = (
    SparkSession.builder
    .remote(remote)
    .appName("dtp-connectivity-test")
    .getOrCreate()
)

print("Connected to Spark Connect!")

# Create a distributed DataFrame with 8 partitions

df = spark.range(10_000_000)

# Execute a distributed aggregation
result = df.selectExpr("sum(id) AS total")
result.show()

# Inspect the execution plan
result.explain()

spark.stop()