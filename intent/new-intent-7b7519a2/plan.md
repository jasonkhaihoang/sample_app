# Plan: Rebuild fork-parent workspace

## Tasks

### Task 1: Seed raw_order_line_items and build dbt models

- [x] **Step 1: Seed raw data** — `dbt seed --target dev` to load 70 rows into `raw_order_line_items`
- [x] **Step 2: Sandbox run** — `dbt build --select +fct_order_revenue --target dev`

## Execution evidence

- [x] Task 1 Step 1: `dbt seed --target dev` — exit 0 — INSERT 70 rows into `main_main.raw_order_line_items`
- [x] Task 1 Step 2: `dbt build --select +fct_order_revenue --target dev` — exit 0 — 7/7 PASS (2 models, 5 tests), enforced contract on `fct_order_revenue`, 20 orders

