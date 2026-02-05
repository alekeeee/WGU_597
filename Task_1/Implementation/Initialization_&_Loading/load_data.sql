-- 1. Add allergies column to user_info
ALTER TABLE user_info ADD COLUMN IF NOT EXISTS allergies TEXT;

-- 2. Create temp staging table for CSV import
DROP TABLE IF EXISTS staging_medical_records;
CREATE TABLE staging_medical_records (
    patient_id INT,
    name VARCHAR(255),
    date_of_birth VARCHAR(20),
    gender VARCHAR(10),
    medical_conditions VARCHAR(100),
    medications VARCHAR(10),
    allergies VARCHAR(255),
    last_appointment_date VARCHAR(20),
    tracker VARCHAR(150)
);

-- 3. Copy CSV data into staging table
\copy staging_medical_records FROM '/Users/alectorres/Projects/SQL/data management/Scenario 1/D597 Task 1 Dataset 3_medical_records.csv' WITH (FORMAT csv, HEADER true);

-- 4. Insert into User table (patient_id -> user_id, birthdate, gender)
INSERT INTO "User" (user_id, password_hash, gender, birthdate)
SELECT
    patient_id,
    'placeholder_hash',
    gender,
    TO_DATE(date_of_birth, 'MM/DD/YYYY')
FROM staging_medical_records
ON CONFLICT (user_id) DO NOTHING;

-- 5. Insert into user_info (split name, add allergies)
INSERT INTO user_info (user_id, effective_date, first_name, last_name, allergies)
SELECT
    patient_id,
    CURRENT_DATE,
    SPLIT_PART(name, ' ', 1) AS first_name,
    SUBSTRING(name FROM POSITION(' ' IN name) + 1) AS last_name,
    CASE WHEN allergies = 'None' THEN NULL ELSE allergies END
FROM staging_medical_records
ON CONFLICT (user_id, effective_date) DO NOTHING;

-- 6. Insert unique devices into device_ref
-- Determine manufacturer from tracker name
INSERT INTO device_ref (manufacturer, model_name, device_type)
SELECT DISTINCT
    CASE
        WHEN LOWER(tracker) LIKE 'amazfit%' THEN 'Amazfit'
        WHEN LOWER(tracker) LIKE 'band%' THEN 'Xiaomi'
        WHEN LOWER(tracker) LIKE '%magic%' OR LOWER(tracker) LIKE 'watch es%' THEN 'Huawei'
        WHEN LOWER(tracker) IN ('46 mm', '41mm', '2 pro', '2s', 's', 's pro') THEN 'Samsung'
        WHEN LOWER(tracker) IN ('storm', 'xplorer', 'delta', 'o2', 'z1', 'gs pro') THEN 'Zepp'
        WHEN LOWER(tracker) LIKE 'bip lite%' THEN 'Amazfit'
        ELSE 'Unknown'
    END AS manufacturer,
    tracker AS model_name,
    'Fitness Tracker' AS device_type
FROM staging_medical_records
WHERE tracker IS NOT NULL AND tracker != ''
ON CONFLICT (manufacturer, model_name) DO NOTHING;

-- 7. Show results
SELECT 'Users loaded:' AS status, COUNT(*) AS count FROM "User"
UNION ALL
SELECT 'User_info loaded:', COUNT(*) FROM user_info
UNION ALL
SELECT 'Devices loaded:', COUNT(*) FROM device_ref;
