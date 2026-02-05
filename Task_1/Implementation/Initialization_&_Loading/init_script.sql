{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww18580\viewh19520\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ==========================================\
-- 1. CORE ENTITIES (Users & Providers)\
-- ==========================================\
\
CREATE TABLE Practitioner (\
    npi VARCHAR(20) PRIMARY KEY,\
    first_name VARCHAR(100),\
    last_name VARCHAR(100),\
    specialty VARCHAR(100),\
    gender VARCHAR(50),\
    phone_number VARCHAR(20),\
    email_address VARCHAR(150)\
);\
\
-- ==========================================\
-- 2. REFERENCE TABLES (Catalogs & Dictionaries)\
-- ==========================================\
\
CREATE TABLE Condition_Ref (\
    code VARCHAR(50) PRIMARY KEY,\
    condition_description TEXT\
);\
\
CREATE TABLE Medication_Ref (\
    medication_id SERIAL PRIMARY KEY,\
    generic_name VARCHAR(150),\
    brand_name VARCHAR(150),\
    dose_form VARCHAR(100),\
    strength_value DECIMAL(10,2),\
    strength_unit VARCHAR(50)\
);\
\
CREATE TABLE Metric_Ref (\
    metric VARCHAR(100) PRIMARY KEY,\
    metric_description TEXT,\
    unit_of_measure VARCHAR(50)\
);\
\
CREATE TABLE Device_Ref (\
    model_id SERIAL PRIMARY KEY,\
    manufacturer VARCHAR(100),\
    model_name VARCHAR(100),\
    device_type VARCHAR(50),\
    UNIQUE (manufacturer, model_name)\
);\
\
-- ==========================================\
-- 3. USER PROFILE & HISTORY\
-- ==========================================\
\
CREATE TABLE "User" (\
    user_id SERIAL PRIMARY KEY,\
    password_hash VARCHAR(255) NOT NULL,\
    gender VARCHAR(50),\
    race VARCHAR(100),\
    ethnicity VARCHAR(100),\
    birthdate DATE\
);\
\
CREATE TABLE User_Info (\
    user_id INT REFERENCES "User"(user_id),\
    effective_date DATE,\
    first_name VARCHAR(100),\
    last_name VARCHAR(100),\
    address_1 VARCHAR(255),\
    address_2 VARCHAR(255),\
    city VARCHAR(100),\
    state VARCHAR(100),\
    zip_code VARCHAR(20),\
    country VARCHAR(100),\
    email_address VARCHAR(150),\
    phone_number VARCHAR(20),\
    alternate_phone VARCHAR(20),\
    PRIMARY KEY (user_id, effective_date)\
);\
\
-- ==========================================\
-- 4. CLINICAL TRANSACTIONS\
-- ==========================================\
\
CREATE TABLE Appointment (\
    appointment_id SERIAL,\
    user_id INT REFERENCES "User"(user_id),\
    npi VARCHAR(20) REFERENCES Practitioner(npi),\
    start_datetime TIMESTAMP,\
    end_datetime TIMESTAMP,\
    reason TEXT,\
    status VARCHAR(50),\
    outcome TEXT,\
    PRIMARY KEY (appointment_id)\
);\
\
CREATE TABLE Patient_Condition (\
    user_id INT REFERENCES "User"(user_id),\
    condition_code VARCHAR(50) REFERENCES Condition_Ref(code),\
    effective_date DATE,\
    clinical_status VARCHAR(50),\
    severity VARCHAR(50),\
    onset_datetime TIMESTAMP,\
    resolved_datetime TIMESTAMP,\
    notes TEXT,\
    attachments TEXT,\
    PRIMARY KEY (user_id, condition_code, effective_date)\
);\
\
CREATE TABLE Medication_Request (\
    medication_request_id SERIAL,\
    user_id INT REFERENCES "User"(user_id),\
    request_date DATE,\
    medication_id INT REFERENCES Medication_Ref(medication_id),\
    npi VARCHAR(20) REFERENCES Practitioner(npi),\
    status VARCHAR(50),\
    start_date DATE,\
    end_date DATE,\
    instructions TEXT,\
    PRIMARY KEY (medication_request_id, user_id, request_date)\
);\
\
-- ==========================================\
-- 5. DEVICE CONFIGURATION LAYER\
-- ==========================================\
\
CREATE TABLE Device_Capabilities (\
    model_id INT REFERENCES Device_Ref(model_id),\
    metric VARCHAR(100) REFERENCES Metric_Ref(metric),\
    PRIMARY KEY (model_id, metric)\
);\
\
CREATE TABLE User_Device_Profile (\
    profile_id SERIAL PRIMARY KEY,\
    user_id INT NOT NULL REFERENCES "User"(user_id),\
    model_id INT REFERENCES Device_Ref(model_id),\
    custom_device_name VARCHAR(150),\
    date_added DATE DEFAULT CURRENT_DATE,\
    is_active BOOLEAN DEFAULT TRUE,\
    CONSTRAINT check_device_source CHECK (\
        (model_id IS NOT NULL AND custom_device_name IS NULL) OR\
        (model_id IS NULL AND custom_device_name IS NOT NULL)\
    )\
);\
\
CREATE TABLE User_Device_Config (\
    config_id SERIAL PRIMARY KEY,\
    profile_id INT REFERENCES User_Device_Profile(profile_id),\
    metric VARCHAR(100) REFERENCES Metric_Ref(metric),\
    UNIQUE (profile_id, metric)\
);\
\
-- ==========================================\
-- 6. TELEMETRY DATA (Vertical Storage)\
-- ==========================================\
\
CREATE TABLE Observation (\
    observation_id BIGSERIAL PRIMARY KEY,\
    user_id INT REFERENCES "User"(user_id),\
    profile_id INT REFERENCES User_Device_Profile(profile_id),\
    metric VARCHAR(100) REFERENCES Metric_Ref(metric),\
    date_time TIMESTAMP NOT NULL,\
    value DECIMAL(10,4),\
    comments TEXT,\
    attachments TEXT\
);\
\
```}