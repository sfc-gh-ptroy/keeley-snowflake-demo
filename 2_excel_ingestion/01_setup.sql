-- 01_setup.sql: Creates Snowflake objects for Excel/CSV ingestion

USE ROLE SYSADMIN;
CREATE DATABASE IF NOT EXISTS KEELEY_DEMO;
CREATE SCHEMA IF NOT EXISTS KEELEY_DEMO.RAW;
USE DATABASE KEELEY_DEMO;
USE SCHEMA RAW;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE STAGE rent_roll_stage
    COMMENT = 'Landing zone for monthly rent roll CSV files';

CREATE OR REPLACE FILE FORMAT csv_rent_roll_format
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    EMPTY_FIELD_AS_NULL = TRUE
    DATE_FORMAT = 'AUTO'
    TIMESTAMP_FORMAT = 'AUTO';

CREATE OR REPLACE TABLE raw_rent_roll (
    load_id             VARCHAR,
    property_id         VARCHAR,
    property_name       VARCHAR,
    unit_number         VARCHAR,
    tenant_name         VARCHAR,
    lease_start_date    DATE,
    lease_end_date      DATE,
    square_feet         NUMBER,
    monthly_base_rent   NUMBER(12,2),
    monthly_cam_charges NUMBER(12,2),
    monthly_total_rent  NUMBER(12,2),
    occupancy_status    VARCHAR,
    payment_status      VARCHAR,
    last_payment_date   DATE,
    source_file         VARCHAR,
    loaded_at           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE VIEW v_occupancy_summary AS
SELECT
    property_id,
    property_name,
    count(*)                                                     AS total_units,
    sum(square_feet)                                             AS total_sqft,
    count(CASE WHEN occupancy_status = 'occupied' THEN 1 END)    AS occupied_units,
    round(
        count(CASE WHEN occupancy_status = 'occupied' THEN 1 END)
        / nullif(count(*), 0) * 100, 2
    )                                                            AS occupancy_pct,
    sum(monthly_total_rent)                                      AS monthly_gross_rent
FROM raw_rent_roll
GROUP BY 1, 2;
