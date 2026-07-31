# Verify: Revenue-per-order data mart

## Certification

`certified` — All `## Coverage` rows covered, all deterministic gates pass (golden-replay: skipped/no baseline, project-audit: pass, dev-artifact scan: pass, contract-enforcement: pass), both reviewer verdicts `APPROVE`. Advisory (non-blocking): staging view `stg_orders__order_line_items` lacks a `schema.yml` entry — deferred per explicit "just the mart" scope.

## Coverage

| Source | Item | Covered by | Evidence |
| --- | --- | --- | --- |
| `intent.md` success criteria | One row per order with `order_id` PK | `unique` + `not_null` tests on `order_id` | `dbt build` 7/7 PASS (exit 0) |
| `intent.md` success criteria | `total_revenue` = gross SUM(line_total) | `dbt build` model materialization + data validation | `dbt build` 7/7 PASS; 20 rows, $41,497.98 total |
| `intent.md` success criteria | `not_null` + `unique` on `order_id` | dbt generic tests | `dbt build` tests PASS (exit 0) |
| `intent.md` success criteria | Daily refresh cadence | Model materialized as table, refreshable | Table `fct_order_revenue` materialized in ephemeral DuckDB |
| `design.md` inventory | `stg_orders__order_line_items` | dbt view creation | `dbt build` — view model OK (exit 0) |
| `design.md` inventory | `fct_order_revenue` | dbt table + contract + 5 tests | `dbt build` 7/7 PASS (exit 0), enforced contract `data_type` validated |

## Gate results

| Gate | Command | Exit | Outcome |
| --- | --- | --- | --- |
| golden-replay | `validating-against-baseline` | — | `skipped` — no baseline declared in design.md |
| project-audit | manual audit (naming, descriptions, grain tests, control columns) | 0 | `pass` — all checks green |
| dev-artifact scan | `grep dev_mode/add_limit/target-prod` | 0 | `pass` — no pinned hacks |

| contract-enforcement | `dbt build --select +fct_order_revenue --target dev` | 0 | `pass` — 7/7 PASS, enforced `contract: { enforced: true }` validates all 8 `data_type` declarations |

## Reviewer verdicts

Design-stage:
```json
{
  "verdict": "APPROVE",
  "issues": [],
  "next_step": null
}
```

Code-stage:
```json
{
  "verdict": "APPROVE",
  "issues": [],
  "next_step": null
}
```

## Approvals
