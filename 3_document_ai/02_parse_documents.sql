-- 02_parse_documents.sql: Extract raw text from PDFs with AI_PARSE_DOCUMENT

USE DATABASE KEELEY_DEMO;
USE SCHEMA DOCUMENTS;
USE WAREHOUSE COMPUTE_WH;

LS @lease_docs_stage;

-- Parse a single document
SELECT
    'lease_001.pdf'                                           AS document_name,
    AI_PARSE_DOCUMENT(
        TO_FILE('@lease_docs_stage', 'lease_001.pdf'),
        {'mode': 'LAYOUT'}
    )['content']::VARCHAR                                     AS extracted_text;

-- Parse all PDFs in the stage
CREATE OR REPLACE TEMPORARY TABLE parsed_documents AS
SELECT
    RELATIVE_PATH                                             AS document_name,
    AI_PARSE_DOCUMENT(
        BUILD_SCOPED_FILE_URL(@lease_docs_stage, RELATIVE_PATH),
        {'mode': 'LAYOUT'}
    )['content']::VARCHAR                                     AS document_text
FROM DIRECTORY(@lease_docs_stage)
WHERE RELATIVE_PATH ILIKE '%.pdf';

SELECT count(*) AS documents_parsed FROM parsed_documents;
SELECT document_name, left(document_text, 500) AS preview FROM parsed_documents;
