# PDF & Document Intelligence

Demonstrates extracting structured lease terms from unstructured PDFs using Snowflake Cortex AI functions.

## Snowflake Features Used

- `AI_PARSE_DOCUMENT` — OCR and text extraction from PDFs and images
- `AI_EXTRACT` — Extract named fields from unstructured text using a JSON schema  
- `AI_COMPLETE` — Flexible LLM calls for summarization and risk analysis

## Requirements

- Snowflake Enterprise or Business Critical with Cortex AI enabled
- Role with `CORTEX_USER` privilege

## Setup Order

1. Run `01_setup.sql`
2. Upload PDF lease files to `@lease_docs_stage` via Snowsight
3. Run `02_parse_documents.sql`
4. Run `03_extract_lease_terms.sql`
5. Run `04_analyze_and_alert.sql`
