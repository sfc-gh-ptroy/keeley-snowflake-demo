-- 03_snowpipe_setup.sql: Event-driven auto-ingest with Snowpipe

USE DATABASE KEELEY_DEMO;
USE SCHEMA RAW;

CREATE OR REPLACE PIPE rent_roll_pipe
    AUTO_INGEST = TRUE
    COMMENT = 'Auto-ingests rent roll CSVs dropped into rent_roll_stage'
AS
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
ON_ERROR = CONTINUE;

SHOW PIPES;
SELECT SYSTEM$PIPE_STATUS('rent_roll_pipe');

SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW_RENT_ROLL',
    START_TIME => DATEADD('hour', -24, CURRENT_TIMESTAMP())
))
ORDER BY last_load_time DESC;
