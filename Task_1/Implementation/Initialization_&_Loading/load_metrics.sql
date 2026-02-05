-- Create staging table
DROP TABLE IF EXISTS staging_metrics;
CREATE TABLE staging_metrics (
    metric VARCHAR(100),
    metric_description TEXT,
    unit_of_measure VARCHAR(50),
    extra1 VARCHAR(10),
    extra2 VARCHAR(10)
);

-- Load CSV
\copy staging_metrics FROM '/Users/alectorres/Projects/SQL/data management/Scenario 1/health_metrics_table.csv' WITH (FORMAT csv, HEADER true);

-- Insert into metric_ref
INSERT INTO metric_ref (metric, metric_description, unit_of_measure)
SELECT
    TRIM(metric),
    TRIM(metric_description),
    TRIM(unit_of_measure)
FROM staging_metrics
WHERE metric IS NOT NULL AND metric != ''
ON CONFLICT (metric) DO NOTHING;

-- Show top 5
SELECT * FROM metric_ref ORDER BY metric LIMIT 5;

-- Show count
SELECT COUNT(*) AS total_metrics FROM metric_ref;

-- Drop staging
DROP TABLE staging_metrics;
