# Concurrent Index Creation in PostgreSQL

## Overview

When creating indexes on large tables, PostgreSQL offers two approaches:

| Method | Locks Table | Speed | Use Case |
|--------|-------------|-------|----------|
| `CREATE INDEX` | Yes (blocks writes) | Faster | Maintenance windows, dev environments |
| `CREATE INDEX CONCURRENTLY` | No | Slower | Production, live databases |

---

## How `CREATE INDEX CONCURRENTLY` Works

Standard `CREATE INDEX` acquires a lock that blocks INSERT, UPDATE, and DELETE operations until the index is built. On a table with 1 billion rows, this could mean minutes of downtime.

`CREATE INDEX CONCURRENTLY` builds the index in three phases:

1. **First scan**: Reads the table and builds a temporary index structure
2. **Wait**: Waits for all transactions that started before phase 1 to complete
3. **Second scan**: Catches up on any rows that changed during phase 1

This allows writes to continue during the build, but takes roughly 2-3x longer.

### Limitations

- Cannot run inside a `BEGIN`/`COMMIT` transaction block
- If it fails, leaves behind an "invalid" index (must be dropped manually)
- Only one `CONCURRENTLY` operation per index at a time

---

## Running Multiple Index Builds in Parallel

PostgreSQL executes statements sequentially within a single connection. To build multiple indexes simultaneously, you need **separate database connections**.

### Using Background Processes

```bash
# The & symbol runs each command in a background process
psql -d health_tracker -c "CREATE INDEX CONCURRENTLY idx_one ON table(col1);" &
psql -d health_tracker -c "CREATE INDEX CONCURRENTLY idx_two ON table(col2);" &
psql -d health_tracker -c "CREATE INDEX CONCURRENTLY idx_three ON table(col3);" &

# wait pauses the script until all background jobs complete
wait
```

Each `psql` command opens its own connection to the database, so all three indexes build at the same time.

---

## Running Bash Scripts from Zsh

Zsh can run bash scripts directly. You have several options:

### Option 1: Use the Shebang (Recommended)

Add `#!/bin/bash` as the first line of your script. This tells the system to use bash regardless of your current shell.

```bash
#!/bin/bash
echo "This runs in bash"
```

Run it with:
```zsh
./script.sh
```

### Option 2: Explicitly Call Bash

```zsh
bash script.sh
```

### Option 3: Run Inline with Bash

```zsh
bash -c 'echo "This runs in bash"'
```

### Making a Script Executable

```zsh
chmod +x script.sh
./script.sh
```

---

## Example: Test Query Without Indexes

This script drops custom indexes, runs EXPLAIN ANALYZE, then recreates indexes concurrently in parallel.

### The Script

```bash
#!/bin/bash
# test_without_indexes.sh
# Tests query performance without custom indexes on observation table

set -e  # Exit on any error

DATABASE="health_tracker"

echo "========================================"
echo "Dropping custom indexes on observation..."
echo "========================================"

psql -d $DATABASE -c "
DROP INDEX IF EXISTS idx_obs_datetime;
DROP INDEX IF EXISTS idx_obs_metric;
DROP INDEX IF EXISTS idx_obs_user_metric_time;
"

echo ""
echo "========================================"
echo "Running EXPLAIN ANALYZE without indexes..."
echo "========================================"

psql -d $DATABASE -c "
EXPLAIN ANALYZE
SELECT
    u.user_id,
    ui.first_name,
    ui.last_name,
    o.value AS sleep_score,
    o.date_time
FROM observation o
JOIN \"User\" u ON o.user_id = u.user_id
JOIN user_info ui ON u.user_id = ui.user_id
WHERE o.metric_id = 43
  AND o.date_time >= NOW() - INTERVAL '24 hours'
  AND o.value < 60
ORDER BY o.value ASC;
"

echo ""
echo "========================================"
echo "Recreating indexes concurrently..."
echo "========================================"

# Each runs in a separate background process (parallel execution)
psql -d $DATABASE -c "CREATE INDEX CONCURRENTLY idx_obs_datetime ON observation(date_time);" &
PID1=$!

psql -d $DATABASE -c "CREATE INDEX CONCURRENTLY idx_obs_metric ON observation(metric_id);" &
PID2=$!

psql -d $DATABASE -c "CREATE INDEX CONCURRENTLY idx_obs_user_metric_time ON observation(user_id, metric_id, date_time);" &
PID3=$!

echo "Building indexes in parallel (PIDs: $PID1, $PID2, $PID3)..."
echo "This may take several minutes for large tables..."

# Wait for all background jobs to complete
wait $PID1 $PID2 $PID3

echo ""
echo "========================================"
echo "Indexes restored. Verifying..."
echo "========================================"

psql -d $DATABASE -c "
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'observation'
ORDER BY indexname;
"

echo ""
echo "Done!"
```

### How to Run

```zsh
# Make executable (one time)
chmod +x test_without_indexes.sh

# Run the script
./test_without_indexes.sh
```

---

## Key Concepts Summary

| Concept | Syntax | Purpose |
|---------|--------|---------|
| `&` | `command &` | Run command in background |
| `wait` | `wait` or `wait $PID` | Pause until background jobs finish |
| `$!` | `PID=$!` | Capture PID of last background process |
| `set -e` | `set -e` | Exit script if any command fails |
| Shebang | `#!/bin/bash` | Specify interpreter for script |

---

## Monitoring Progress

While indexes are building, you can check progress in another terminal:

```sql
-- See active index builds
SELECT pid, phase, blocks_total, blocks_done,
       round(100.0 * blocks_done / nullif(blocks_total, 0), 1) AS percent_done
FROM pg_stat_progress_create_index;
```

Or check for invalid indexes (failed concurrent builds):

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
    SELECT indexrelid::regclass::text
    FROM pg_index
    WHERE NOT indisvalid
  );
```
