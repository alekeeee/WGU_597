-- Simulate 10 million observations (3 days of data)
-- Date range: 2025-06-01 to 2025-06-03

-- Create temp table for metric configurations
DROP TABLE IF EXISTS metric_config;
CREATE TEMP TABLE metric_config (
    metric_id INT,
    metric VARCHAR(100),
    is_hourly BOOLEAN,
    min_val DECIMAL,
    max_val DECIMAL,
    mean_val DECIMAL
);

-- Insert metric configurations with ranges
INSERT INTO metric_config VALUES
-- Hourly metrics
(28, 'heart_rate', TRUE, 50, 180, 72),
(7, 'HRV', TRUE, 20, 100, 50),
(9, 'SpO₂', TRUE, 94, 100, 98),
(36, 'respiration_rate', TRUE, 12, 20, 15),
(37, 'respiratory_rate', TRUE, 12, 20, 15),
(51, 'stress', TRUE, 1, 100, 35),
(19, 'body_temperature', TRUE, 36.0, 37.5, 36.6),
(54, 'temperature', TRUE, 36.0, 37.5, 36.6),
(3, 'Body_Battery', TRUE, 5, 100, 60),
(4, 'Body_Energy', TRUE, 5, 100, 60),
(20, 'cadence', TRUE, 60, 180, 160),
(34, 'pace', TRUE, 4, 12, 7),
(24, 'elevation', TRUE, 0, 500, 50),
-- Daily metrics
(50, 'steps', FALSE, 2000, 15000, 7500),
(12, 'active_minutes', FALSE, 0, 120, 30),
(13, 'active_zone_minutes', FALSE, 0, 90, 20),
(61, 'exercise_minutes', FALSE, 0, 90, 25),
(33, 'intensity_minutes', FALSE, 0, 100, 25),
(30, 'hourly_activity', FALSE, 0, 16, 8),
(32, 'intensity', FALSE, 1, 10, 5),
(22, 'distance', FALSE, 0, 15, 5),
(21, 'calories', FALSE, 1500, 3500, 2200),
(27, 'floors', FALSE, 0, 30, 8),
(40, 'sleep_duration', FALSE, 240, 600, 420),
(65, 'sleep_REM', FALSE, 45, 120, 90),
(66, 'sleep_light', FALSE, 150, 300, 210),
(67, 'sleep_deep', FALSE, 30, 120, 60),
(43, 'sleep_score', FALSE, 50, 100, 75),
(42, 'sleep_quality', FALSE, 1, 100, 70),
(39, 'sleep_breathing_quality', FALSE, 1, 100, 85),
(46, 'sleep_tracking', FALSE, 240, 600, 420),
(41, 'sleep_light_deep_awake', FALSE, 0, 60, 20),
(10, 'SpO₂_sleep', FALSE, 92, 99, 96),
(58, 'weight', FALSE, 50, 120, 75),
(18, 'body_fat_percentage', FALSE, 10, 40, 22),
(17, 'body_composition', FALSE, 10, 40, 22),
(2, 'BMR', FALSE, 1200, 2200, 1600),
(16, 'blood_pressure', FALSE, 90, 140, 120),
(29, 'heart_rate_zones', FALSE, 0, 60, 15),
(55, 'vascular_load', FALSE, 1, 100, 50),
(5, 'ECG', FALSE, 0, 1, 1),
(23, 'duration', FALSE, 15, 120, 45),
(60, 'workout_duration', FALSE, 15, 120, 45),
(59, 'workout_distance', FALSE, 0, 20, 5),
(26, 'fat_burn_time', FALSE, 0, 60, 15),
(62, 'training_load', FALSE, 0, 500, 150),
(63, 'training_readiness', FALSE, 1, 100, 70),
(64, 'training_status', FALSE, 1, 5, 3),
(35, 'recovery_time', FALSE, 0, 72, 24),
(11, 'VO₂_max', FALSE, 25, 60, 40),
(53, 'stride_length', FALSE, 0.5, 1.2, 0.75),
(52, 'stride_frequency', FALSE, 60, 180, 160),
(8, 'PAI', FALSE, 0, 150, 50),
(31, 'hydration', FALSE, 500, 3000, 2000),
(56, 'water_intake', FALSE, 500, 3000, 2000),
(57, 'water_retention', FALSE, 0, 5, 1.5),
(47, 'stand_hours', FALSE, 0, 12, 3),
(49, 'standing_time', FALSE, 0, 360, 180),
(48, 'standing_reminders', FALSE, 0, 12, 3),
(25, 'fall_detection', FALSE, 0, 2, 0);

-- Generate HOURLY observations
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT
    udp.user_id,
    udc.profile_id,
    udc.metric_id,
    d.day + (h.hour || ' hours')::INTERVAL AS date_time,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2) AS value
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = TRUE
CROSS JOIN generate_series('2025-06-01'::DATE, '2025-06-03'::DATE, '1 day') AS d(day)
CROSS JOIN generate_series(0, 23) AS h(hour);

-- Generate DAILY observations
INSERT INTO observation (user_id, profile_id, metric_id, date_time, value)
SELECT
    udp.user_id,
    udc.profile_id,
    udc.metric_id,
    d.day + '12:00:00'::TIME AS date_time,
    ROUND((mc.min_val + (mc.max_val - mc.min_val) * random())::NUMERIC, 2) AS value
FROM user_device_config udc
JOIN user_device_profile udp ON udc.profile_id = udp.profile_id
JOIN metric_config mc ON udc.metric_id = mc.metric_id AND mc.is_hourly = FALSE
CROSS JOIN generate_series('2025-06-01'::DATE, '2025-06-03'::DATE, '1 day') AS d(day);

-- Show results
SELECT 'Total observations:' AS status, COUNT(*) FROM observation;

-- Sample hourly data
SELECT 'Sample hourly (heart_rate):' AS info;
SELECT o.observation_id, o.user_id, o.date_time, o.value, mr.metric
FROM observation o
JOIN metric_ref mr ON o.metric_id = mr.metric_id
WHERE mr.metric = 'heart_rate'
ORDER BY o.user_id, o.date_time
LIMIT 5;

-- Sample daily data
SELECT 'Sample daily (steps):' AS info;
SELECT o.observation_id, o.user_id, o.date_time, o.value, mr.metric
FROM observation o
JOIN metric_ref mr ON o.metric_id = mr.metric_id
WHERE mr.metric = 'steps'
ORDER BY o.user_id, o.date_time
LIMIT 5;
