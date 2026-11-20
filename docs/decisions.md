# Architecture Decision Log

Record significant technical decisions here. Add new decisions at the top. Keep entries short and explain the context, decision, consequences and status.

## Decision template

### ADR-XXX — Short title

- **Status:** proposed / accepted / superseded
- **Date:** YYYY-MM-DD
- **Context:** What problem or constraint led to this decision?
- **Decision:** What are we choosing?
- **Consequences:** What becomes easier or harder?
- **Alternatives considered:** What else could we have done?

---

## Initial decisions from the project specification

### ADR-001 — Run the platform locally with Docker Compose

- **Status:** accepted
- **Context:** The project is a learning environment intended to run on one laptop and be reproducible.
- **Decision:** Run platform services in Docker Compose, with optional services enabled through profiles.
- **Consequences:** The environment is portable and code-defined, but resource usage must be managed on the host.

### ADR-002 — Use one common Spark image

- **Status:** accepted
- **Context:** Spark services and both execution paths must use compatible Spark, Java, Python and dependency versions.
- **Decision:** Build one `bdp-spark` image and vary the service start command.
- **Consequences:** Version drift is reduced; image build and dependency management become explicit.

### ADR-003 — Provide interactive and submitted-job execution paths

- **Status:** accepted
- **Context:** Interactive development is useful for debugging, while independent applications are needed for pipeline runs and benchmark attribution.
- **Decision:** Use Spark Connect for Path A and `spark-submit` for Path B. Reuse the same job code where possible.
- **Consequences:** Developers get an interactive workflow and isolated job applications. Spark Connect limitations (no RDD API / `SparkContext`) remain.

### ADR-004 — Use Delta Lake for lakehouse tables

- **Status:** accepted
- **Context:** The project needs transactional tables, schema enforcement, history and incremental processing.
- **Decision:** Store Bronze, Silver and Gold as Delta tables.
- **Consequences:** Delta transaction logs and table maintenance become part of the learning scope.

### ADR-005 — Use PostgreSQL for the shared Hive metastore

- **Status:** accepted
- **Context:** The Connect server and submitted jobs must access the same catalog concurrently; embedded Derby is not suitable for this.
- **Decision:** Back the Hive metastore with PostgreSQL.
- **Consequences:** PostgreSQL becomes an infrastructure dependency, but table metadata is shared across Spark processes.

### ADR-006 — Keep data and event logs on a shared local volume

- **Status:** accepted
- **Context:** Containers must share raw data, Delta tables, warehouse files and Spark event logs.
- **Decision:** Mount the project data directory into containers at `/opt/data`.
- **Consequences:** The local filesystem is simple and inspectable; data is machine-local and must be backed up separately if needed.

### ADR-007 — Use Airflow for orchestration in a later phase

- **Status:** accepted
- **Context:** Pipeline scheduling and retry behavior are part of the target experience but are not needed to validate the initial Spark cluster.
- **Decision:** Introduce Airflow in Phase 6, using the same Path-B job entry points.
- **Consequences:** Initial development stays lighter; orchestration is added after the jobs exist.

### ADR-008 — Build a local workspace in a later phase

- **Status:** accepted
- **Context:** A browser interface should provide catalog, SQL, jobs and compute views without replacing VS Code.
- **Decision:** Build a FastAPI backend and React + TypeScript frontend in Phase 7.
- **Consequences:** The workspace remains a single-user local application in v1; authentication and multi-user permissions are excluded.

### Open decisions to revisit

- Exact catalog/metastore implementation details and compatibility.
- Exact pinned patch versions when implementation begins.
- Final Compose resource limits based on the actual host.
- Whether post-v1 object storage should use MinIO.
