# Keeley Companies — Snowflake Demo Package

This repository contains working demo code for three Snowflake capability areas demonstrated for Keeley Companies.

## Topics

1. **dbt Projects on Snowflake** — A dbt project modeling property, lease, and transaction data with staging, intermediate, and mart layers.
2. **Excel Data from Shared Locations** — SQL scripts for ingesting rent roll and ops data from CSV/Excel files placed in cloud storage using Snowflake external stages and Snowpipe.
3. **PDF & Document Intelligence** — SQL scripts using Snowflake Cortex AI functions to extract structured lease terms from unstructured PDFs.

## Repository Structure

```
keeley-snowflake-demo/
├── 1_dbt_project/           # dbt project for property data
│   ├── dbt_project.yml
│   ├── profiles/
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   └── seeds/               # Sample CSV data
├── 2_excel_ingestion/       # Excel/CSV auto-ingestion
│   ├── 01_setup.sql
│   ├── 02_load_batch.sql
│   ├── 03_snowpipe_setup.sql
│   └── sample_data/
└── 3_document_ai/           # PDF extraction with Cortex AI
    ├── 01_setup.sql
    ├── 02_parse_documents.sql
    ├── 03_extract_lease_terms.sql
    └── 04_analyze_and_alert.sql
```
