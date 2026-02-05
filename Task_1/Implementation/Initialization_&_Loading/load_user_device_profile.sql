-- Load user_device_profile from medical records

-- 1. Recreate staging table
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

-- 2. Load CSV
\copy staging_medical_records FROM '/Users/alectorres/Projects/SQL/data management/Scenario 1/D597 Task 1 Dataset 3_medical_records.csv' WITH (FORMAT csv, HEADER true);

-- 3. Check sample of tracker values vs device_ref
SELECT 'Sample trackers from CSV:' AS info;
SELECT DISTINCT tracker FROM staging_medical_records LIMIT 10;

SELECT 'Sample model names from device_ref:' AS info;
SELECT DISTINCT model_name FROM device_ref LIMIT 10;

-- 4. Check how many trackers match device_ref
SELECT 'Matching trackers:' AS info, COUNT(DISTINCT smr.tracker)
FROM staging_medical_records smr
JOIN device_ref dr ON TRIM(smr.tracker) = TRIM(dr.model_name);

-- 5. Check how many don't match
SELECT 'Non-matching trackers:' AS info, COUNT(DISTINCT smr.tracker)
FROM staging_medical_records smr
LEFT JOIN device_ref dr ON TRIM(smr.tracker) = TRIM(dr.model_name)
WHERE dr.model_id IS NULL;
