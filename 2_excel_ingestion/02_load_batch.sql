-- 02_load_batch.sql: Batch loading via PUT + COPY INTO

USE DATABASE KEELEY_DEMO;
USE SCHEMA RAW;
USE WAREHOUSE COMPUTE_WH;

-- Step 1: Upload file from local machine (run in SnowSQL or Snowflake CLI)
-- PUT file:///path/to/rent_roll_2026_04.csv @rent_roll_stage AUTO_COMPRESS=FALSE;

-- Step 2: List files in stage
LIST @rent_roll_stage;

-- Step 3: Preview before loading
SELECT
    $1  AS property_id,
    $2  AS property_name,
    $3  AS unit_number,
    $4  AS tenant_name,
    $5  AS lease_start_date,
    $6  AS lease_end_date,
    $7  AS square_feet,
    $8  AS monthly_base_rent,
    $9  AS monthly_cam_charges,
    $10 AS monthly_total_rent,
    $11 AS occupancy_status,
    $12 AS payment_status,
    $13 AS last_payment_date,
    METADATA$FILENAME AS source_file
FROM @rent_roll_stage
(FILE_FORMAT => 'csv_rent_roll_format')
LIMIT 10;

-- Step 4: Load the file
COPY INTO raw_rent_roll (
    property_id, property_name, unit_number, tenant_name,
    lease_start_date, lease_end_date, square_feet,
    monthly_base_rent, monthly_cam_charges, monthly_total_rent,
    occupancy_status, payment_status, last_payment_date, source_file
)
FROM (
    SELECT
        $1, $2, $3, $4,
        TRY_TO_DATE($5), TRY_TO_DATE($6),
        TRY_TO_NUMBER($7), TRY_TO_NUMBER($8),
        TRY_TO_NUMBER($9), TRY_TO_NUMBER($10),
        $11, $12, TRY_TO_DATE($13),
        METADATA$FILENAME
    FROM @rent_roll_stage
)
FILE_FORMAT = (FORMAT_NAME = 'csv_rent_roll_format')
ON_ERROR = CONTINUE
PURGE = FALSE;

-- Step 5: Check results
SELECT source_file, count(*) AS rows_loaded, max(loaded_at) AS last_loaded
FROM raw_rent_roll
GROUP BY source_file
ORDER BY last_loaded DESC;

-- Step 6: Occupancy summary
SELECT * FROM v_occupancy_summary ORDER BY occupancy_pct DESC;

-- Step 7: Auto-detect schema from new file
SELECT *
FROM TABLE(
    INFER_SCHEMA(
        LOCATION => '@rent_roll_stage',
        FILE_FORMAT => 'csv_rent_roll_format'
    )
);
