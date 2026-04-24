-- 03_extract_lease_terms.sql: Extract specific fields using AI_EXTRACT

USE DATABASE KEELEY_DEMO;
USE SCHEMA DOCUMENTS;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TEMPORARY TABLE lease_extraction_results AS
SELECT
    document_name,
    AI_EXTRACT(
        document_text,
        {
            'tenant_name':            'The name of the tenant or lessee',
            'property_address':       'The full address of the leased property',
            'lease_start_date':       'The lease commencement date in YYYY-MM-DD format',
            'lease_end_date':         'The lease expiration date in YYYY-MM-DD format',
            'base_rent_monthly':      'Monthly base rent in US dollars (number only)',
            'annual_escalation_pct':  'Annual rent escalation percentage (number only)',
            'security_deposit':       'Security deposit in US dollars (number only)',
            'has_renewal_option':     'Whether lease has a renewal option (true or false)',
            'renewal_term_years':     'Renewal option term in years (integer)',
            'has_termination_option': 'Whether tenant has a termination/kick-out clause (true or false)',
            'cam_cap_pct':            'Annual cap on CAM expense increases as a percentage (number only)'
        }
    )                                                         AS extracted_json
FROM parsed_documents;

SELECT
    document_name,
    extracted_json:tenant_name::VARCHAR          AS tenant_name,
    extracted_json:lease_start_date::DATE        AS lease_start_date,
    extracted_json:lease_end_date::DATE          AS lease_end_date,
    extracted_json:base_rent_monthly::NUMBER     AS base_rent_monthly,
    extracted_json:has_renewal_option::BOOLEAN   AS has_renewal_option
FROM lease_extraction_results
LIMIT 20;

INSERT INTO extracted_lease_terms (
    document_name, tenant_name, property_address,
    lease_start_date, lease_end_date, base_rent_monthly,
    annual_escalation_pct, security_deposit, has_renewal_option,
    renewal_term_years, has_termination_option, cam_cap_pct, raw_extracted_json
)
SELECT
    document_name,
    extracted_json:tenant_name::VARCHAR,
    extracted_json:property_address::VARCHAR,
    TRY_TO_DATE(extracted_json:lease_start_date::VARCHAR),
    TRY_TO_DATE(extracted_json:lease_end_date::VARCHAR),
    TRY_TO_NUMBER(extracted_json:base_rent_monthly::VARCHAR),
    TRY_TO_NUMBER(extracted_json:annual_escalation_pct::VARCHAR),
    TRY_TO_NUMBER(extracted_json:security_deposit::VARCHAR),
    IFF(extracted_json:has_renewal_option::VARCHAR ILIKE 'true', TRUE, FALSE),
    TRY_TO_NUMBER(extracted_json:renewal_term_years::VARCHAR)::INTEGER,
    IFF(extracted_json:has_termination_option::VARCHAR ILIKE 'true', TRUE, FALSE),
    TRY_TO_NUMBER(extracted_json:cam_cap_pct::VARCHAR),
    extracted_json
FROM lease_extraction_results;

SELECT tenant_name, property_address, lease_start_date, lease_end_date,
       base_rent_monthly, annual_escalation_pct, has_renewal_option, has_termination_option
FROM extracted_lease_terms
ORDER BY lease_end_date;
