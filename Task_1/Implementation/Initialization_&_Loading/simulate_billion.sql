-- Simulate 1 billion observations
-- Date range: 2025-06-01 to 2026-02-15 (259 days)
-- Running in monthly batches for stability

-- Create metric config table
DROP TABLE IF EXISTS metric_config;
CREATE TABLE metric_config (
    metric_id INT,
    is_hourly BOOLEAN,
    min_val DECIMAL,
    max_val DECIMAL
);

INSERT INTO metric_config VALUES
-- Hourly metrics
(28, TRUE, 50, 180), (7, TRUE, 20, 100), (9, TRUE, 94, 100),
(36, TRUE, 12, 20), (37, TRUE, 12, 20), (51, TRUE, 1, 100),
(19, TRUE, 36.0, 37.5), (54, TRUE, 36.0, 37.5), (3, TRUE, 5, 100),
(4, TRUE, 5, 100), (20, TRUE, 60, 180), (34, TRUE, 4, 12), (24, TRUE, 0, 500),
-- Daily metrics
(50, FALSE, 2000, 15000), (12, FALSE, 0, 120), (13, FALSE, 0, 90),
(61, FALSE, 0, 90), (33, FALSE, 0, 100), (30, FALSE, 0, 16),
(32, FALSE, 1, 10), (22, FALSE, 0, 15), (21, FALSE, 1500, 3500),
(27, FALSE, 0, 30), (40, FALSE, 240, 600), (65, FALSE, 45, 120),
(66, FALSE, 150, 300), (67, FALSE, 30, 120), (43, FALSE, 50, 100),
(42, FALSE, 1, 100), (39, FALSE, 1, 100), (46, FALSE, 240, 600),
(41, FALSE, 0, 60), (10, FALSE, 92, 99), (58, FALSE, 50, 120),
(18, FALSE, 10, 40), (17, FALSE, 10, 40), (2, FALSE, 1200, 2200),
(16, FALSE, 90, 140), (29, FALSE, 0, 60), (55, FALSE, 1, 100),
(5, FALSE, 0, 1), (23, FALSE, 15, 120), (60, FALSE, 15, 120),
(59, FALSE, 0, 20), (26, FALSE, 0, 60), (62, FALSE, 0, 500),
(63, FALSE, 1, 100), (64, FALSE, 1, 5), (35, FALSE, 0, 72),
(11, FALSE, 25, 60), (53, FALSE, 0.5, 1.2), (52, FALSE, 60, 180),
(8, FALSE, 0, 150), (31, FALSE, 500, 3000), (56, FALSE, 500, 3000),
(57, FALSE, 0, 5), (47, FALSE, 0, 12), (49, FALSE, 0, 360),
(48, FALSE, 0, 12), (25, FALSE, 0, 2);

\echo 'Starting batch generation...'
\echo 'Batch 1/9: June 2025'

-- Batch 1: June 2025 (30 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-06-01'::DATE, '2025-06-30'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-06-01'::DATE, '2025-06-30'::DATE, '1 day') AS d(day);

SELECT 'Batch 1 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 2/9: July 2025'

-- Batch 2: July 2025 (31 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-07-01'::DATE, '2025-07-31'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-07-01'::DATE, '2025-07-31'::DATE, '1 day') AS d(day);

SELECT 'Batch 2 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 3/9: August 2025'

-- Batch 3: August 2025 (31 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-08-01'::DATE, '2025-08-31'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-08-01'::DATE, '2025-08-31'::DATE, '1 day') AS d(day);

SELECT 'Batch 3 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 4/9: September 2025'

-- Batch 4: September 2025 (30 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-09-01'::DATE, '2025-09-30'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-09-01'::DATE, '2025-09-30'::DATE, '1 day') AS d(day);

SELECT 'Batch 4 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 5/9: October 2025'

-- Batch 5: October 2025 (31 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-10-01'::DATE, '2025-10-31'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-10-01'::DATE, '2025-10-31'::DATE, '1 day') AS d(day);

SELECT 'Batch 5 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 6/9: November 2025'

-- Batch 6: November 2025 (30 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-11-01'::DATE, '2025-11-30'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-11-01'::DATE, '2025-11-30'::DATE, '1 day') AS d(day);

SELECT 'Batch 6 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 7/9: December 2025'

-- Batch 7: December 2025 (31 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-12-01'::DATE, '2025-12-31'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-12-01'::DATE, '2025-12-31'::DATE, '1 day') AS d(day);

SELECT 'Batch 7 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 8/9: January 2026'

-- Batch 8: January 2026 (31 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2026-01-01'::DATE, '2026-01-31'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2026-01-01'::DATE, '2026-01-31'::DATE, '1 day') AS d(day);

SELECT 'Batch 8 complete' AS status, COUNT(*) FROM observation;

\echo 'Batch 9/9: February 2026 (1-15)'

-- Batch 9: February 2026 (15 days)
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2026-02-01'::DATE, '2026-02-15'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT udp.user_id, udc.profile_id, udc.metric_id, d.day + '12:00:00'::TIME,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2)
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2026-02-01'::DATE, '2026-02-15'::DATE, '1 day') AS d(day);

\echo 'All batches complete!'
SELECT 'TOTAL OBSERVATIONS' AS status, COUNT(*) FROM observation;

-- Cleanup
DROP TABLE metric_config;
