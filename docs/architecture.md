# Architecture

## 1. Design goals

The platform is a local, Databricks-inspired environment. It should be reproducible, lightweight by default, observable, and operated through code rather than manual setup.

The architecture separates development, compute, storage, orchestration and user-facing inspection.

## 2. Logical architecture

```text
Developer workstation (WSL2)
  VS Code
    |
    +-- Path A: pyspark-client -> Spark Connect server
    |
    +-- Path B: docker compose run -> spark-submit driver
                                      |
                                      v
                           Spark Standalone cluster
                           Master + Worker 1 + Worker 2
                                      |
                     +----------------+----------------+
                     |                |                |
                 Delta data       Event logs       Catalog metadata
                 shared volume    History Server   PostgreSQL metastore
                     |
              Bronze / Silver / Gold / ops

Later services:
  Airflow 3 -> submits Path-B jobs
  FastAPI + React/TypeScript -> catalog, SQL, jobs and compute workspace
```

## 3. Compute services

All Spark services use the same `bdp-spark` image. The image contains the pinned Spark distribution, Java 17, Python 3.12, Delta dependencies, PostgreSQL JDBC driver and Spark configuration.

| Service | Responsibility | Host ports | Roadmap phase |
|---|---|---:|---:|
| `spark-master` | Standalone scheduler/master | 7077, 8080 | 1 |
| `spark-worker-1`, `spark-worker-2` | Execute tasks; two cores each | 8081, 8082 | 1 |
| `spark-connect` | Long-running driver for interactive Path A | 15002, 4040 | 1 |
| `spark-history` | Browse completed and failed applications | 18080 | 1 |
| `submit` | Short-lived Path-B job driver | 4041 | 1 |
| `postgres` | Hive metastore; later Airflow/workspace DBs | 5432 | 2 |
| Airflow API server/scheduler/DAG processor | Orchestrate jobs | 8090 | 6 |
| `workspace` | FastAPI backend serving React UI | 3000 | 7 |

Compose profiles keep optional services such as job, orchestration and workspace components out of the default lightweight startup when they are not needed.

## 4. Two execution paths

### Path A — interactive development

VS Code runs Python locally using `pyspark-client`. `SPARK_REMOTE=sc://localhost:15002` sends Spark operations to the Spark Connect server in Docker.

Use this path for exploration, debugging, reading plans and interactive development. Spark Connect does not expose `df.rdd` or `spark.sparkContext`.

### Path B — submitted application

A job is submitted using `docker compose run --rm submit spark-submit ...`. Each submission creates its own Spark application and is the path used for full pipeline runs, benchmarks and Airflow.

Both paths use the same job code and shared tables where applicable. Airflow invokes the same Path-B job entry points.

## 5. Storage and catalog

A shared local data directory is mounted into containers as `/opt/data`.

```text
data/
├── raw/             # generated landing files
├── warehouse/       # managed table data
└── spark-events/    # Spark event logs
```

The lakehouse uses Delta tables (Parquet data files plus `_delta_log`). Spark's Hive catalog metadata is stored in PostgreSQL. A shared metastore is required because the interactive Connect server and submitted jobs must see the same table definitions; embedded Derby is not suitable for concurrent processes.

## 6. Data layers

- `bronze`: source data as received, append-oriented, with ingestion metadata.
- `silver`: normalized, validated, deduplicated and merged data.
- `gold`: business-level analytical tables.
- `ops`: data-quality results and benchmark records.

The detailed table inventory is maintained alongside the implementation and roadmap.

## 7. Observability

Spark event logging is enabled and persisted to the shared data volume. The History Server reads those logs so completed and failed runs remain inspectable.

Evidence to retain includes:
- Spark Master view showing both workers and total cores.
- Spark application stages and tasks.
- Physical plans for representative transformations.
- Data-quality results.
- Benchmark configurations and measurements.

## 8. Workspace (later phase)

The workspace is a local single-user web application at `localhost:3000`.

- FastAPI backend exposes catalog, SQL, jobs and compute APIs.
- React + TypeScript frontend provides four main pages: Catalog, SQL editor, Jobs and Compute.
- The backend uses Spark Connect for catalog and SQL operations and the Airflow REST API for DAG operations.

Authentication and multi-user permissions are out of scope for v1.

## 9. Resource considerations

The roadmap estimates roughly 4.4 GB for the default phases 1–5 profile, around 5.4 GB while a submitted job runs, and materially more when Airflow and the workspace are enabled. These are planning estimates, not hard guarantees. Check Docker/WSL memory and host capacity before enabling optional profiles.

## 10. Deliberate v1 exclusions

Cloud object storage, streaming, Unity Catalog, Photon, ML, notebook UI, user management and multi-node fault tolerance are not part of v1. MinIO, streaming, Unity Catalog OSS, Prometheus/Grafana, workspace enhancements and dbt are possible post-v1 extensions.
