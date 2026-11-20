# Built-in Data Platform

A mini Databricks-inspired data platform that runs locally on a laptop. You write and debug Python in VS Code; Spark workloads run in Docker. Data moves through Bronze, Silver and Gold Delta tables, Airflow schedules pipelines in a later phase, and a local web workspace provides catalog browsing, SQL, jobs and compute visibility.

The purpose is not just to make pipelines work: it is to understand how Spark executes them and to support every optimization with reproducible measurements.

## Goals

- Run a realistic e-commerce lakehouse from raw files to analytical tables.
- Understand Spark drivers, executors, jobs, stages, tasks, shuffles and memory.
- Compare optimization strategies using controlled experiments.
- Provide a Databricks-like local workflow: VS Code, catalog, SQL editor, jobs and compute.
- Produce a documented technical case study suitable for a portfolio.

## Architecture summary

```text
VS Code (Python 3.12)
  |-- Path A: pyspark-client / Spark Connect ------------------+
  |                                                             |
  +-- Path B: docker compose run / spark-submit ----------------+--> Spark Standalone
                                                                |      Master
                                                                |      Workers 1 & 2
                                                                |
                                                                +--> Delta Lake tables
                                                                       Bronze
                                                                       Silver
                                                                       Gold
                                                                       ops

Docker Compose services:
  Spark Connect | Spark Master | Spark Workers | Spark History Server
  PostgreSQL (metastore; later also Airflow/workspace databases)
  Airflow (later phase) | FastAPI + React workspace (later phase)
```

See [`docs/architecture.md`](docs/architecture.md) for the detailed design and [`docs/roadmap.md`](docs/roadmap.md) for the build sequence.

## Technology baseline

Pin exact patch versions in `.env` and document any deliberate changes.

| Component | Target |
|---|---|
| Python | 3.12 |
| Java | 17 |
| Apache Spark | 4.0.x (roadmap baseline: 4.0.1) |
| Delta Lake | 4.0.x (roadmap baseline: 4.0.0) |
| PostgreSQL | 16 |
| Apache Airflow | 3.x |
| Node.js | 22 LTS |

The Spark services use one common `bdp-spark` image so Spark, Python and required JAR versions remain consistent. Delta and PostgreSQL JDBC JARs are baked into the image rather than downloaded at container startup.

## Prerequisites

The roadmap targets Windows with WSL2 and keeps the repository on the Linux filesystem.

- WSL2 Linux distribution
- Docker Desktop with WSL integration
- Git
- Python 3.12
- VS Code with WSL, Python, Docker and Ruff extensions

The roadmap recommends allocating approximately 10 GB to WSL2 for later phases. Check available host memory before enabling Airflow and the workspace profile.

## Repository layout

```text
built-in-data-platform/
├── infrastructure/
│   ├── docker-compose.yml
│   ├── spark/
│   ├── airflow/
│   └── postgres/
├── .vscode/
├── src/bdp/
│   ├── platform/
│   ├── ingestion/
│   ├── transformations/
│   ├── analytics/
│   ├── quality/
│   └── jobs/
├── scripts/
├── experiments/
├── benchmarks/
├── dags/
├── workspace/
│   ├── backend/
│   └── frontend/
├── tests/
├── docs/
├── data/                 # local data; ignored by Git
├── .env.example
├── .gitignore
├── Makefile
└── pyproject.toml
```

Directories are introduced as their roadmap phase begins; this is the target structure, not a claim that every component already exists.

## Data

The project generates five e-commerce source datasets:

| Dataset | Raw format |
|---|---|
| customers | CSV with header |
| products | CSV with header |
| orders | Nested JSON Lines |
| payments | Parquet |
| events | JSON Lines |

The generator is a Spark job and accepts scale, seed and batch parameters. The generated data intentionally includes duplicates, malformed values, late-arriving events, skew and hot keys for quality and performance exercises.

### Lakehouse layers

- **Bronze:** source records as received, with `_ingested_at`, `_source_file` and `_batch_id`.
- **Silver:** cleaned, deduplicated and incrementally merged datasets; rejected records are retained in `silver.rejects`.
- **Gold:** analytical tables for revenue, customer lifetime value, product sales, payment reconciliation and funnel metrics.
- **Ops:** data-quality results and benchmark-run metadata.

All lakehouse tables are managed Delta tables. The Hive metastore is backed by PostgreSQL so multiple Spark processes can share table metadata.

## Development principles

- Everything is code: images, configuration, tables, DAGs and UI belong in Git.
- Reproducibility: pin versions, seed generated data and record benchmark configuration.
- Idempotency: ingestion and pipeline jobs should be safe to rerun.
- Explicit schemas: do not use `inferSchema`.
- Transformations should be DataFrame-to-DataFrame functions; jobs handle orchestration and I/O.
- Do not collect large datasets to the driver.
- Use Ruff for linting/formatting and pytest for tests.
- Save plans, screenshots and benchmark results as evidence.

## Getting started

This repository is built phase by phase. The following are the intended setup steps; commands become available as the relevant files are implemented.

1. Create the repository on the WSL2 Linux filesystem.
2. Create a Python 3.12 virtual environment.
3. Copy `.env.example` to `.env` and set local values.
4. Build the common Spark image and start the base Compose services.
5. Connect from VS Code through Spark Connect.
6. Run a job through `spark-submit`.
7. Verify both execution paths in the Spark UI and History Server.

The intended Makefile interface is:

```bash
make help
make up
make down
```

## Roadmap

1. Infrastructure and VS Code connection.
2. Lakehouse foundation.
3. Distributed processing.
4. Spark optimization lab.
5. Spark internals and cluster tuning.
6. Orchestration with Airflow.
7. Workspace UI.
8. Final production challenge and case study.

See [`docs/roadmap.md`](docs/roadmap.md) for phase goals and acceptance criteria.

## Known limitations

This is a single-machine learning environment, not a production multi-node cluster. Workers share the host CPU and disk; there is no real inter-machine network or machine-failure isolation. The first version excludes cloud storage, Unity Catalog, Photon, ML and streaming.

Spark Connect does not expose the RDD API or `SparkContext`; use the submitted-job path for work that requires them. The Connect server is a long-running Spark application, so interactive runs appear under that application; use Spark tags or submitted jobs for cleaner benchmark attribution.

## Documentation

- [`docs/architecture.md`](docs/architecture.md) — components, execution paths and data layout.
- [`docs/roadmap.md`](docs/roadmap.md) — phases, checks and deliverables.
- [`docs/decisions.md`](docs/decisions.md) — architecture decision log.
- [`docs/baseline.md`](docs/baseline.md) — machine and first-run baseline.
- [`docs/case-study.md`](docs/case-study.md) — final portfolio case-study template.
- [`docs/internals/README.md`](docs/internals/README.md) — notes on Spark internals.

## Definition of success

The platform succeeds when you can build and rerun the pipeline, explain how Spark executes it, identify bottlenecks from plans and metrics, and justify optimizations with repeatable before/after measurements.
