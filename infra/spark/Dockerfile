ARG SPARK_VERSION=4.0.1

# Spark distribution is taken from the official image (Docker Hub is much faster
# than archive.apache.org, which is bandwidth-throttled). It ships the
# hadoop3 / Scala 2.13 build.
FROM apache/spark:${SPARK_VERSION} AS spark-dist

FROM python:3.12-slim-bookworm

ARG SPARK_VERSION
ARG DELTA_VERSION=4.0.0
ARG POSTGRES_JDBC_VERSION=42.7.8

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    SPARK_HOME=/opt/spark \
    PYSPARK_PYTHON=/usr/local/bin/python \
    PYSPARK_DRIVER_PYTHON=/usr/local/bin/python \
    PATH=/opt/spark/bin:/opt/spark/sbin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
      openjdk-17-jre-headless \
      bash \
      curl \
      tini \
      procps \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=spark-dist /opt/spark "${SPARK_HOME}"

# Delta Lake and PostgreSQL JDBC dependencies are baked into the image.
RUN curl -fsSL "https://repo1.maven.org/maven2/io/delta/delta-spark_2.13/${DELTA_VERSION}/delta-spark_2.13-${DELTA_VERSION}.jar" \
      -o "${SPARK_HOME}/jars/delta-spark_2.13-${DELTA_VERSION}.jar" \
    && curl -fsSL "https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar" \
      -o "${SPARK_HOME}/jars/delta-storage-${DELTA_VERSION}.jar" \
    && curl -fsSL "https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_VERSION}/postgresql-${POSTGRES_JDBC_VERSION}.jar" \
      -o "${SPARK_HOME}/jars/postgresql-${POSTGRES_JDBC_VERSION}.jar"

COPY conf/spark-defaults.conf "${SPARK_HOME}/conf/spark-defaults.conf"
COPY conf/hive-site.xml "${SPARK_HOME}/conf/hive-site.xml"
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/data /opt/project \
    && chmod -R a+rX "${SPARK_HOME}"

WORKDIR /opt/project

EXPOSE 7077 8080 8081 8082 15002 4040 18080

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
