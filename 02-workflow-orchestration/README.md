# Module 2: Workflow Orchestration with Kestra

## Project Overview
Transitioned from manual data ingestion to an automated orchestration layer. The focus was on building resilient pipelines to move NYC Taxi data from various sources into Google Cloud Platform.

## Key Technical Shifts
* **Declarative Orchestration:** Replaced Python ingestion scripts with Kestra YAML flows.
* **SQL Integration:** Utilized SQL within the workflow to handle data movement and basic transformations, reducing script dependency.
* **Backfilling & Scheduling:** Implemented logic to process historical partitions of the dataset efficiently.

## Technologies Used
* **Orchestrator:** Kestra
* **Cloud Storage:** Google Cloud Storage (GCS)
* **Data Warehouse:** BigQuery
* **Database:** Postgres (Local development)
