-- 04_analyze_and_alert.sql: AI-powered risk flags and lease summaries

USE DATABASE KEELEY_DEMO;
USE SCHEMA DOCUMENTS;
USE WAREHOUSE COMPUTE_WH;

-- Summarize each lease in plain English
SELECT
    lt.tenant_name,
    lt.lease_end_date,
    AI_COMPLETE(
        'mistral-large2',
        'You are a commercial real estate analyst. Summarize this lease in 2 sentences, '
        || 'highlighting key financial terms and any notable risk factors. '
        || 'Tenant: '              || coalesce(lt.tenant_name, 'Unknown')           || '. '
        || 'Monthly rent: $'       || coalesce(lt.base_rent_monthly::varchar, '?')  || '. '
        || 'Lease expires: '       || coalesce(lt.lease_end_date::varchar, '?')     || '. '
        || 'Annual escalation: '   || coalesce(lt.annual_escalation_pct::varchar, '?') || '%. '
        || 'Renewal option: '      || coalesce(lt.has_renewal_option::varchar, 'unknown') || '. '
        || 'Termination clause: '  || coalesce(lt.has_termination_option::varchar, 'unknown') || '.'
    )                                                          AS lease_summary
FROM extracted_lease_terms lt
ORDER BY lt.lease_end_date
LIMIT 10;

-- Flag leases expiring in next 180 days
CREATE OR REPLACE VIEW v_lease_expiration_alerts AS
SELECT
    tenant_name,
    property_address,
    lease_end_date,
    datediff('day', current_date(), lease_end_date)          AS days_to_expiration,
    base_rent_monthly,
    base_rent_monthly * 12                                   AS annual_rent_at_risk,
    has_renewal_option,
    has_termination_option,
    CASE
        WHEN datediff('day', current_date(), lease_end_date) <= 90  THEN 'CRITICAL — 90 days'
        WHEN datediff('day', current_date(), lease_end_date) <= 180 THEN 'WARNING — 180 days'
        ELSE 'WATCH'
    END                                                      AS alert_level
FROM extracted_lease_terms
WHERE lease_end_date BETWEEN current_date() AND dateadd('day', 180, current_date())
ORDER BY lease_end_date;

SELECT * FROM v_lease_expiration_alerts;

-- Portfolio risk summary
SELECT
    count(*)                                                 AS total_leases_extracted,
    sum(base_rent_monthly * 12)                              AS total_annual_rent,
    count(CASE WHEN has_renewal_option THEN 1 END)           AS leases_with_renewal,
    count(CASE WHEN has_termination_option THEN 1 END)       AS leases_with_termination_clause,
    sum(CASE WHEN datediff('day', current_date(), lease_end_date) <= 180
        THEN base_rent_monthly * 12 ELSE 0 END)              AS annual_rent_expiring_180d
FROM extracted_lease_terms;
