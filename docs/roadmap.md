# Project Roadmap

Work through phases in order. Each phase must leave a working, tested result. The durations are estimates (about 10–11 weeks overall), not deadlines.

## Before starting

- [ ] Allocate about 10 GB of memory to WSL2 as a starting target; verify with `free -h`.
- [ ] Check Docker sees the intended memory and CPU resources.
- [ ] Create `~/projects/built-in-data-platform` on the Linux filesystem.
- [ ] Initialize Git and create a Python 3.12 virtual environment.
- [ ] Install VS Code extensions: WSL, Python, Docker and Ruff.
- [ ] Open the repository through WSL.

## Phase 1 — Infrastructure and VS Code connection (about 1 week)

**Goal:** a Spark cluster in Docker that VS Code can use through both execution paths, with runs retained in the History Server.

- [ ] Create repository skeleton: folders, README, `.gitignore`, `pyproject.toml`, Makefile.
- [ ] Pin versions in `.env` and document them in README.
- [ ] Build `bdp-spark`: Java 17, Spark 4.0, Python 3.12, Delta and PostgreSQL JDBC JARs, `spark-defaults.conf`.
- [ ] Compose: Spark master and two workers, configured from `.env`, with memory limits.
- [ ] Mount shared `./data` as `/opt/data`; mount project code read-only as `/opt/project`.
- [ ] Add History Server reading the event-log directory.
- [ ] Add Spark Connect server with `spark://spark-master:7077`.
- [ ] Configure laptop `pyspark-client` and `get_spark()` helper.
- [ ] Verify a Spark range aggregation runs on both workers through Spark Connect.
- [ ] Add VS Code debug configuration and step through a script.
- [ ] Add submit service, VS Code task and `make submit`.
- [ ] Write `docs/baseline.md` with machine, versions, container memory and first-run time.

**Acceptance:** a script started from VS Code runs tasks on both workers in both paths, and both runs can be inspected in the History Server.

**Learn:** driver, executor, master, worker; client vs cluster deployment; Spark Connect; application/job/stage/task.

**Evidence:** Master UI screenshot, job stages/tasks screenshot, baseline document.

## Phase 2 — Lakehouse foundation (about 1 week)

**Goal:** raw files become clean, checked Delta tables visible to every container.

- [ ] Add PostgreSQL and `hive-site.xml` so the Hive metastore is backed by PostgreSQL.
- [ ] Build the Spark-based data generator for five datasets, three file formats, seed, scale and planted data issues.
- [ ] Define explicit `StructType` schemas for all sources; no `inferSchema`.
- [ ] Implement Bronze ingestion with `_ingested_at`, `_source_file`, `_batch_id`.
- [ ] Make ingestion idempotent: reprocessing a loaded batch must not duplicate rows.
- [ ] Build Silver customers and products with cleaning, deduplication and `MERGE`.
- [ ] Add quality-check functions, `run_checks`, `ops.dq_results` and `silver.rejects`.
- [ ] Add pytest unit tests using small hand-made DataFrames.

**Acceptance:** Bronze and Silver customers/products are built from raw files; rerunning the same batch does not change row counts; quality checks detect planted issues; tests pass.

**Learn:** Delta transaction log, commits, time travel, managed vs external tables, metastore, schema enforcement/evolution.

**Evidence:** one `_delta_log` commit explained, `DESCRIBE HISTORY`, initial quality results.

## Phase 3 — Distributed processing (about 1 week)

**Goal:** all Silver and Gold tables are built and updated incrementally.

- [ ] Build Silver orders and `order_items` (explode nested items), payments and events.
- [ ] Build Gold: `revenue_daily`, `customer_ltv`, `product_sales`, `payment_reconciliation`, `funnel_daily`.
- [ ] Generate incremental batches and implement incremental Silver `MERGE`.
- [ ] Rewrite only changed Gold dates using `replaceWhere`.
- [ ] Partition orders and events by date; verify partition pruning in plans.
- [ ] Add a `run_all` job to build raw-to-Gold in one command.

**Acceptance:** one job builds all Gold tables; incremental batches produce the same result as a full rebuild, without duplicate keys.

**Learn:** narrow vs wide transformations, joins, windows, shuffles, MERGE file rewrites.

**Evidence:** Gold physical plan with shuffles identified; runtime per batch.

## Phase 4 — Spark optimization lab (about 2 weeks)

**Goal:** experiments for joins, skew, partitions, AQE and files, each with recorded numbers and an explanation.

- [ ] Build benchmark recorder using History Server REST API.
- [ ] Add repeatable benchmark command; run each variant three times.
- [ ] Compare join strategies: auto, broadcast, sort-merge and shuffle-hash.
- [ ] Experiment with skew and hot keys; compare AQE and salting.
- [ ] Compare shuffle partition counts and repartition/coalesce choices.
- [ ] Compare AQE on/off and file compaction/OPTIMIZE.
- [ ] Generate Markdown reports with median metrics and physical plans.
- [ ] Apply proven improvements to the pipeline and measure again.

**Acceptance:** each experiment has a baseline and at least two controlled variants; reports include repeatable evidence.

**Learn:** broadcast, sort-merge and shuffle-hash joins; skew; AQE; small files; OPTIMIZE and Z-order.

**Evidence:** `ops.bench_runs`, experiment reports and before/after screenshots.

## Phase 5 — Spark internals and cluster tuning (about 1–2 weeks)

**Goal:** explain Spark's execution internals and tune the cluster using evidence.

- [ ] Inspect `explain("extended")` from parsed through physical plan.
- [ ] Inspect `explain("codegen")` and generated operator fusion.
- [ ] Enable GC logs and executor metrics.
- [ ] Run memory and Python serialization experiments.
- [ ] Compare executor layouts with equal total resources (1×4, 2×2, 4×1).
- [ ] Document each topic under `docs/internals/`.

**Acceptance:** experiments are repeatable and notes explain observed behavior with metrics.

**Learn:** unified memory, spill, serialization, Arrow, scheduling, locality and retries.

**Evidence:** tuning-grid results and internals notes.

## Phase 6 — Orchestration with Airflow (about 1 week)

**Goal:** the pipeline runs on a schedule and recovers from failures.

- [ ] Build `bdp-airflow` image with Airflow 3, Python 3.12, Java 17, PySpark and Spark provider.
- [ ] Add Compose `orchestration` profile: API server, scheduler, DAG processor, LocalExecutor and PostgreSQL database.
- [ ] Build `daily_lakehouse` DAG using SparkSubmitOperator and existing job files.
- [ ] Add retries, timeouts and failure callback writing to ops.
- [ ] Add `weekly_maintenance` DAG for OPTIMIZE and VACUUM.
- [ ] Enable Airflow REST API access for the workspace.

**Acceptance:** scheduled DAG runs successfully; a forced failure retries and can be repaired; each Spark task appears as an application in History Server.

**Learn:** scheduling, data intervals, catchup, idempotent tasks, retries and why Spark work runs on Spark rather than Airflow workers.

**Evidence:** DAG graph and failed-then-repaired run.

## Phase 7 — Workspace UI (about 2 weeks)

**Goal:** MVP of four workspace pages in one container.

- [ ] Build FastAPI backend and health endpoint using Spark Connect.
- [ ] Build React + TypeScript frontend with sidebar and four pages.
- [ ] Compute page: Spark master state, workers, cores, memory and recent apps.
- [ ] Catalog page: schemas, tables, details, sample rows and Delta history.
- [ ] SQL editor: run, cancel, explain and show result grid.
- [ ] Jobs page: list DAGs, start run with configuration, inspect task states/logs.
- [ ] Add API tests and one end-to-end Playwright test.

**Acceptance:** from the browser, find a Gold table, query it, trigger a job and watch it complete.

**Learn:** Spark Connect sessions/tags/interrupts, Arrow result transfer, Airflow REST API.

**Evidence:** screenshots of four pages and a short query-to-job demo recording.

## Phase 8 — Final production challenge (about 1 week)

**Goal:** full-size run, diagnosis and measured improvement, documented as a case study.

- [ ] Generate the largest data scale the machine can handle (aim for ×1).
- [ ] Run daily pipeline plus five incremental batches.
- [ ] Identify the three slowest stages and explain each using UI, plan and metrics.
- [ ] Apply targeted fixes and measure again using the benchmark method.
- [ ] Write `docs/case-study.md` and link it from README.

**Acceptance:** the portfolio case study includes architecture, decisions, results, limitations and next steps.

## Completion standard

Every phase is complete only when:
- you understand the new components and why they are needed;
- code and configuration are in Git;
- a repeatable test or check proves the result;
- decisions and rationale are documented;
- evidence (plans, screenshots, metrics or reports) is saved.
