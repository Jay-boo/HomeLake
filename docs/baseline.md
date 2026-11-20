# Environment and Performance Baseline

Fill this document during Phase 1 and update it when the machine or pinned stack changes.

## Machine

| Item | Value |
|---|---|
| Host OS | TODO |
| WSL distribution/version | TODO |
| CPU model | TODO |
| Logical CPUs available to WSL | TODO |
| Physical RAM | TODO |
| WSL memory limit | TODO |
| Docker Desktop version | TODO |
| Available disk space | TODO |

## Software versions

| Component | Expected / actual version |
|---|---|
| Python | 3.12 / TODO |
| Java | 17 / TODO |
| Spark | 4.0.x / TODO |
| Delta Lake | 4.0.x / TODO |
| Docker Engine | TODO |
| Docker Compose | TODO |
| Git | TODO |

## Container resource configuration

| Service | Memory limit | CPU limit | Notes |
|---|---:|---:|---|
| Spark master | 384 MB (roadmap estimate) | TODO | |
| Spark worker 1 | 1.2 GB (roadmap estimate) | 2 cores | |
| Spark worker 2 | 1.2 GB (roadmap estimate) | 2 cores | |
| Spark Connect | 1 GB (roadmap estimate) | TODO | |
| History Server | 384 MB (roadmap estimate) | TODO | |
| Submit driver | 1 GB (roadmap estimate) | TODO | short-lived |
| PostgreSQL | 256 MB (roadmap estimate) | TODO | Phase 2 |

These values are initial planning figures from the project specification. Record actual Compose limits and observed use after implementation.

## First Spark smoke test

- **Date/time:** TODO
- **Git commit:** TODO
- **Execution path:** Spark Connect / spark-submit
- **Test:** `spark.range(10_000_000).selectExpr("sum(id)").show()`
- **Expected result:** TODO
- **Observed duration:** TODO
- **Workers visible:** TODO
- **Stages/tasks visible:** TODO
- **Spark application ID:** TODO
- **History Server link or screenshot path:** TODO

## Notes and anomalies

TODO
