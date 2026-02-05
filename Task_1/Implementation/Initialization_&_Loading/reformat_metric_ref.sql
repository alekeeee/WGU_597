-- ================================================
-- Reformat metric_ref to use metric_id as primary key
-- ================================================

BEGIN;

-- 1. Drop foreign key constraints
ALTER TABLE device_capabilities DROP CONSTRAINT IF EXISTS device_capabilities_metric_fkey;
ALTER TABLE user_device_config DROP CONSTRAINT IF EXISTS user_device_config_metric_fkey;
ALTER TABLE observation DROP CONSTRAINT IF EXISTS observation_metric_fkey;

-- 2. Drop primary key constraint on metric_ref
ALTER TABLE metric_ref DROP CONSTRAINT IF EXISTS metric_ref_pkey;

-- 3. Add metric_id column to metric_ref
ALTER TABLE metric_ref ADD COLUMN metric_id SERIAL;

-- 4. Set metric_id as primary key
ALTER TABLE metric_ref ADD PRIMARY KEY (metric_id);

-- 5. Add unique constraint on metric name (to preserve lookups)
ALTER TABLE metric_ref ADD CONSTRAINT metric_ref_metric_unique UNIQUE (metric);

-- 6. Add metric_id columns to referencing tables
ALTER TABLE device_capabilities ADD COLUMN metric_id INT;
ALTER TABLE user_device_config ADD COLUMN metric_id INT;
ALTER TABLE observation ADD COLUMN metric_id INT;

-- 7. Populate metric_id in referencing tables
UPDATE device_capabilities dc
SET metric_id = mr.metric_id
FROM metric_ref mr
WHERE dc.metric = mr.metric;

UPDATE user_device_config udc
SET metric_id = mr.metric_id
FROM metric_ref mr
WHERE udc.metric = mr.metric;

UPDATE observation o
SET metric_id = mr.metric_id
FROM metric_ref mr
WHERE o.metric = mr.metric;

-- 8. Drop old metric columns from referencing tables
ALTER TABLE device_capabilities DROP COLUMN metric;
ALTER TABLE user_device_config DROP COLUMN metric;
ALTER TABLE observation DROP COLUMN metric;

-- 9. Add foreign key constraints pointing to metric_id
ALTER TABLE device_capabilities
    ADD CONSTRAINT device_capabilities_metric_id_fkey
    FOREIGN KEY (metric_id) REFERENCES metric_ref(metric_id);

ALTER TABLE user_device_config
    ADD CONSTRAINT user_device_config_metric_id_fkey
    FOREIGN KEY (metric_id) REFERENCES metric_ref(metric_id);

ALTER TABLE observation
    ADD CONSTRAINT observation_metric_id_fkey
    FOREIGN KEY (metric_id) REFERENCES metric_ref(metric_id);

COMMIT;

-- Show updated metric_ref structure
\d metric_ref

-- Show sample data
SELECT metric_id, metric, unit_of_measure FROM metric_ref ORDER BY metric_id LIMIT 5;
