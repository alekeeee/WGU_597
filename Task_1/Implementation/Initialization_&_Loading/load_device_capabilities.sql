-- Load device_metrics_filtered.csv into device_capabilities

-- 1. Create staging table
DROP TABLE IF EXISTS staging_device_metrics;
CREATE TABLE staging_device_metrics (
    brand VARCHAR(100),
    model VARCHAR(150),
    device_type VARCHAR(100),
    metric VARCHAR(100)
);

-- 2. Load CSV (skip the empty first row by using HEADER)
\copy staging_device_metrics FROM '/Users/alectorres/Projects/SQL/data management/Scenario 1/device_metrics_filtered.csv' WITH (FORMAT csv, HEADER true);

-- 3. Remove empty/header rows
DELETE FROM staging_device_metrics WHERE brand IS NULL OR brand = '' OR brand = 'Brand';

-- 4. Show what we loaded
SELECT COUNT(*) AS rows_loaded FROM staging_device_metrics;

-- 5. Insert into device_capabilities by cross-referencing device_ref and metric_ref
INSERT INTO device_capabilities (model_id, metric_id)
SELECT DISTINCT
    dr.model_id,
    mr.metric_id
FROM staging_device_metrics sdm
JOIN device_ref dr
    ON TRIM(sdm.brand) = TRIM(dr.manufacturer)
    AND TRIM(sdm.model) = TRIM(dr.model_name)
JOIN metric_ref mr
    ON TRIM(sdm.metric) = TRIM(mr.metric)
ON CONFLICT (model_id, metric_id) DO NOTHING;

-- 6. Show results
SELECT 'Device capabilities loaded:' AS status, COUNT(*) AS count FROM device_capabilities;

-- 7. Show sample data with names
SELECT
    dc.model_id,
    dr.manufacturer,
    dr.model_name,
    dc.metric_id,
    mr.metric
FROM device_capabilities dc
JOIN device_ref dr ON dc.model_id = dr.model_id
JOIN metric_ref mr ON dc.metric_id = mr.metric_id
ORDER BY dr.manufacturer, dr.model_name, mr.metric
LIMIT 10;

-- 8. Drop staging table
DROP TABLE staging_device_metrics;
