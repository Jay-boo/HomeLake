# Spark Internals Notes

Create one focused note per topic. Prefer a small reproducible example, the physical plan or UI evidence, and a short explanation of what was observed.

Suggested notes:

- `execution-model.md` — driver, executor, master, worker; application, job, stage and task.
- `spark-connect.md` — client/server split, sessions, tags, interrupts and API limitations.
- `query-plans.md` — parsed, analyzed, optimized and physical plans; predicate pushdown and column pruning.
- `shuffles-and-joins.md` — narrow/wide transformations, join strategies and shuffle costs.
- `aqe-and-skew.md` — adaptive query execution, skew joins, hot keys and salting.
- `memory-and-spill.md` — execution/storage memory, disk spill and garbage collection.
- `serialization.md` — Java serialization, Kryo, Arrow and Python UDF overhead.
- `files-and-layout.md` — partitions, small files, OPTIMIZE, Z-order and data skipping.
- `scheduling.md` — task scheduling, locality, retries and speculation.

## Note template

1. **Question:** What are you trying to understand?
2. **Setup:** Dataset, code, Spark version and relevant configuration.
3. **Observation:** Physical plan, Spark UI screenshot or metrics.
4. **Explanation:** What happened and why?
5. **Takeaway:** What would you change in a real pipeline?
6. **Reproduction:** Exact command or test to repeat the observation.
