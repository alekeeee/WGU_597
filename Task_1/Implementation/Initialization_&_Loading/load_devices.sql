-- Create staging table for fitness trackers (all VARCHAR to handle formatting)
DROP TABLE IF EXISTS staging_fitness_trackers;
CREATE TABLE staging_fitness_trackers (
    brand_name VARCHAR(100),
    device_type VARCHAR(100),
    model_name VARCHAR(150),
    color VARCHAR(200),
    selling_price VARCHAR(50),
    original_price VARCHAR(50),
    display VARCHAR(100),
    rating VARCHAR(20),
    strap_material VARCHAR(100),
    battery_life VARCHAR(20),
    reviews VARCHAR(20)
);

-- Load CSV data
\copy staging_fitness_trackers FROM '/Users/alectorres/Projects/SQL/data management/Scenario 1/fitness_trackers.csv' WITH (FORMAT csv, HEADER true);

-- Show what we loaded
SELECT COUNT(*) AS rows_loaded FROM staging_fitness_trackers;

-- Insert unique devices into device_ref (brand_name -> manufacturer, device_type, model_name)
INSERT INTO device_ref (manufacturer, model_name, device_type)
SELECT DISTINCT
    TRIM(brand_name) AS manufacturer,
    TRIM(model_name) AS model_name,
    TRIM(device_type) AS device_type
FROM staging_fitness_trackers
WHERE brand_name IS NOT NULL
  AND model_name IS NOT NULL
  AND brand_name != ''
  AND model_name != ''
ON CONFLICT (manufacturer, model_name) DO NOTHING;

-- Show results
SELECT 'Total devices loaded:' AS status, COUNT(*) AS count FROM device_ref;

-- Show by manufacturer
SELECT manufacturer, COUNT(*) as models
FROM device_ref
GROUP BY manufacturer
ORDER BY models DESC;

-- Sample data
SELECT model_id, manufacturer, model_name, device_type
FROM device_ref
ORDER BY manufacturer, model_name
LIMIT 15;

-- Drop staging table
DROP TABLE staging_fitness_trackers;
