-- 01_setup.sql: Creates Snowflake objects for PDF document intelligence

USE ROLE SYSADMIN;
USE DATABASE KEELEY_DEMO;
USE WAREHOUSE COMPUTE_WH;

CREATE SCHEMA IF NOT EXISTS KEELEY_DEMO.DOCUMENTS;
USE SCHEMA KEELEY_DEMO.DOCUMENTS;

CREATE OR REPLACE STAGE lease_docs_stage
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Storage for lease PDFs and other property documents';

CREATE OR REPLACE TABLE extracted_lease_terms (
    document_name           VARCHAR,
    tenant_name             VARCHAR,
    property_address        VARCHAR,
    lease_start_date        DATE,
    lease_end_date          DATE,
    base_rent_monthly       NUMBER(12,2),
    annual_escalation_pct   NUMBER(5,2),
    security_deposit        NUMBER(12,2),
    has_renewal_option      BOOLEAN,
    renewal_term_years      INTEGER,
    has_termination_option  BOOLEAN,
    cam_cap_pct             NUMBER(5,2),
    raw_extracted_json      VARIANT,
    extracted_at            TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SYSADMIN;
