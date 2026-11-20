from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("DTP-First-Batch-Job")
    .getOrCreate()
)

df = spark.range(10_000_000)

result = df.selectExpr("sum(id) AS total")

result.show()

spark.stop()