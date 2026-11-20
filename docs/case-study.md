# Case Study — Built-in Data Platform

> Complete this document during Phase 8. Replace every TODO with measured evidence; do not invent results.

## Executive summary

- **Problem / objective:** TODO
- **Platform built:** TODO
- **Dataset scale:** TODO
- **Main result:** TODO
- **Most important lesson:** TODO

## Architecture

Describe the local environment, Spark execution paths, storage, catalog, orchestration and workspace.

- Diagram: TODO
- Main technology choices: TODO
- Important architecture decisions: link to `decisions.md`.

## Data and pipeline

- Source datasets and formats: TODO
- Bronze ingestion approach: TODO
- Silver cleaning/deduplication/merge approach: TODO
- Gold business tables: TODO
- Incremental processing approach: TODO
- Data-quality rules and outcomes: TODO

## Performance experiments

For each experiment, document the hypothesis, controlled variable, variants, repetitions, median result and explanation.

| Experiment | Baseline | Variant | Metric | Result / interpretation |
|---|---|---|---|---|
| Join strategy | TODO | TODO | TODO | TODO |
| Skew handling | TODO | TODO | TODO | TODO |
| Shuffle partitions | TODO | TODO | TODO | TODO |
| AQE | TODO | TODO | TODO | TODO |
| File compaction | TODO | TODO | TODO | TODO |
| Python execution | TODO | TODO | TODO | TODO |

## Bottleneck analysis

### Bottleneck 1

- Evidence (plan/UI/metrics): TODO
- Root cause: TODO
- Change applied: TODO
- Before/after measurement: TODO

### Bottleneck 2

TODO

### Bottleneck 3

TODO

## Reliability and data quality

- Idempotency tests: TODO
- Failure/retry demonstration: TODO
- Data-quality findings: TODO

## Limitations

Document the limitations of a single-machine environment, resource constraints and any unimplemented features.

## What I learned

TODO

## Next steps

TODO
