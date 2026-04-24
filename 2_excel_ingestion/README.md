# Excel / CSV Data Ingestion from Shared Storage

Demonstrates automated ingestion of Excel and CSV files from cloud-hosted shared folders.

## Setup Order

1. Run `01_setup.sql` — creates database, schema, stage, file format, and target table
2. Upload `sample_data/rent_roll_sample.csv` to the stage via Snowsight or SnowSQL
3. Run `02_load_batch.sql` — COPY INTO (manual/scheduled batch load)
4. Run `03_snowpipe_setup.sql` — Snowpipe (automatic event-driven load)
