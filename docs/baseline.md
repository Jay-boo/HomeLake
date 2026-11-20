# Baseline --- Built-in Data Platform

> **Phase:** 1 --- Local Spark infrastructure\
> **Status:** Functional validation completed by the project owner\
> **Last updated:** 2026-11-20

This document records the initial local platform baseline: architecture,
runtime versions, resource configuration, access points and validation
status. Values not measured or confirmed are marked **To record** rather
than estimated.

## 1. Scope and acceptance

Phase 1 establishes a local Spark environment with two execution paths
against the same Spark Standalone cluster:

-   **Interactive --- Spark Connect:** develop, run and debug Python
    code from the host machine / VS Code.
-   **Batch --- Spark Submit:** submit a Python job to the same cluster
    as an independent Spark application.

The phase is complete when a script executes distributed tasks on both
workers through both paths, and both executions can be inspected in the
Spark History Server.

**Validation status:** the project owner has confirmed that Spark
Connect, Spark Submit, worker distribution, VS Code debugging and
platform controls have been tested successfully.

## 2. Architecture

``` text
Host machine (WSL2)
├── VS Code
│   ├── Python environment managed with uv
│   ├── .env
│   ├── .vscode/launch.json
│   ├── .vscode/tasks.json
│   └── Makefile
└── Docker Compose network: bdp-network
    ├── Spark Master       spark-master:7077  | UI: localhost:8080
    ├── Spark Worker 1                         | UI: localhost:8081
    ├── Spark Worker 2                         | UI: localhost:8082
    ├── Spark Connect                          | localhost:15002
    │                                          | UI: localhost:4040
    ├── Spark History Server                   | localhost:18080
    └── Submit service                         | short-lived batch container
```

All Spark services use the project image `dtp-spark:4.0.1`. Compose
configuration: `infra/docker-compose.yml`.

The host `data/` directory is mounted in Spark containers at
`/opt/data`. Spark event logs are written to `/opt/data/spark-events`,
which is also read by the History Server.

## 3. Runtime and versions

  Component                          Baseline
  ---------------------------------- ------------------------------------------
  Spark Docker image                 `dtp-spark:4.0.1`
  Apache Spark server                `4.0.1`
  Delta Lake                         `4.0.0` (Compose build-argument default)
  Java                               Java 17 (image baseline)
  Python in Spark image              Python 3.12 (image baseline)
  Host PySpark client                `4.0.3` (host `uv` environment)
  Host Python exact patch version    To record
  Docker Engine / Compose versions   To record
  WSL2 distribution and version      To record

The host PySpark client and Spark server versions are recorded
separately because they are not identical in the current setup.

## 4. Host machine and WSL2 resources

Observed from WSL2 during setup:

  Resource                                   Observed value
  ---------------------------------------- ----------------
  Logical CPUs visible to WSL2 (`nproc`)                 20
  RAM visible to WSL2 (`free -h`)                   7.6 GiB
  RAM available at measurement time                 3.2 GiB
  Swap                                                2 GiB
  Swap used at measurement time                     558 MiB

These are point-in-time observations, not fixed resource limits.
Available memory varies with workload and other running applications.

**Host CPU model / physical RAM:** To record.

## 5. Spark resource configuration

Current worker defaults and tuning:

  Setting                                   Configured value
  ------------------------------------ ---------------------
  Worker count                                             2
  `SPARK_WORKER_CORES`                    2 cores per worker
  `SPARK_WORKER_MEMORY`                   768 MiB per worker
  Total advertised worker capacity       4 cores / 1,536 MiB
  Spark Connect application core cap                  1 core
  Spark Connect executor cores                        1 core
  Spark Connect executor heap                        512 MiB
  Batch submit executor cores                         1 core
  Batch submit executor heap                         512 MiB

Worker settings describe capacity advertised to Spark; they do not
create or reserve physical CPU cores. Executor heap is not the same as
total process/container memory because JVM and process overhead consume
additional memory.

  Container              Memory limit / observed peak
  ---------------------- ------------------------------
  Spark Master           To record
  Spark Worker 1         To record
  Spark Worker 2         To record
  Spark Connect          To record
  Spark History Server   To record
  Submit job container   To record

## 6. Network endpoints

  --------------------------------------------------------------------------
  Service                 Address                    Purpose
  ----------------------- -------------------------- -----------------------
  Spark Master UI         `http://localhost:8080`    Cluster overview and
                                                     registered workers

  Worker 1 UI             `http://localhost:8081`    Worker details

  Worker 2 UI             `http://localhost:8082`    Worker details

  Spark Connect UI        `http://localhost:4040`    Active Connect
                                                     application UI

  Spark Connect endpoint  `sc://localhost:15002`     Host Python client
                                                     connection

  Spark History Server    `http://localhost:18080`   Application event logs
  --------------------------------------------------------------------------

## 7. Operational commands

The Makefile is the primary command interface:

``` bash
make help
make build
make up
make ps
make logs SERVICE=spark-connect
make follow SERVICE=spark-master
make submit JOB=jobs/hello_world.py
make down
```

The Makefile loads `.env` through Docker Compose. The submit target uses
its default executor arguments, overridable with `SUBMIT_ARGS`.

VS Code launch and task definitions are stored in `.vscode/`. They
improve the development experience but are not required to operate the
platform from a terminal.

## 8. Observability

Spark event logging is enabled and writes to:

``` text
file:/opt/data/spark-events
```

The History Server reads the shared directory `/opt/data/spark-events`.

The Connect server is long-running, so its application can remain listed
as incomplete in the History Server while its jobs and stages remain
inspectable. A submitted batch job appears as a separate Spark
application.

## 9. Validation record

The project owner has manually confirmed:

-   [x] Spark Master starts and registers two workers.
-   [x] Spark Connect accepts connections from the host Python
    environment.
-   [x] A Spark Connect script runs successfully.
-   [x] Python debugging works from VS Code.
-   [x] Spark Submit runs a batch job successfully.
-   [x] Jobs are visible in Spark UI / History Server.
-   [x] Distributed execution has been checked on both workers for both
    execution paths.
-   [x] Makefile commands and VS Code project tasks have been tested.

**First successful run duration:** To record if a repeatable timing is
desired.\
**Reference job and dataset size:** To record.\
**Evidence / screenshots:** Add if useful (Master UI, worker
registrations, application stages/tasks, History Server).

## 10. Notes and follow-up

This baseline describes Phase 1 infrastructure only. It does not claim
that later platform components are already installed. The next roadmap
phase introduces the lakehouse foundation, including persistent
catalog/metastore integration and Delta table workflows.

Update this document whenever a change materially affects
reproducibility: image versions, Spark configuration, worker capacity,
ports, storage mounts or execution behavior.
