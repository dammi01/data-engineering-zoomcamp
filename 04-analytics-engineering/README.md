# Module 4: Analytics Engineering with dbt and DuckDB 🦆🛠️

This module focuses on the transformation layer of the data pipeline. After ingesting raw data (Modules 1-3), we now apply software engineering best practices to SQL development using **dbt (data build tool)**.

## 🎯 Objectives
- Transform raw NYC Taxi data into clean, dimensional models (Star Schema).
- Implement data quality tests and documentation.
- Leverage **DuckDB** for fast, local analytical processing.
- Manage Python environments efficiently using **uv**.

## 🛠️ Tech Stack
- **dbt-core**: Transformation logic and modeling.
- **DuckDB**: Fast in-process analytical database.
- **uv**: Extremely fast Python package and environment manager.
- **Jinja/SQL**: Modular code and macros.

## 📂 Project Structure
```text
04-analytics-engineering/
├── taxi_rides_ny/           # Main dbt project
│   ├── models/
│   │   ├── staging/         # Raw data cleaning (Views)
│   │   └── core/            # Fact and Dimension tables (Tables)
│   ├── seeds/               # Static data (taxi_zone_lookup)
│   ├── macros/              # Reusable SQL snippets
│   └── dbt_project.yml      # Project configuration
├── ny_taxi.duckdb           # Local analytical database
└── README.md


🚀 Setup and Execution
1. Environment Management
Using uv to ensure a clean, fast, and isolated environment:

Bash
uv venv
source .venv/bin/activate
uv pip install dbt-duckdb
2. Running the Pipeline
Bash
# Verify connection
dbt debug

# Load seed data (CSV to DuckDB)
dbt seed

# Build the entire project (run models + run tests)
dbt build
📊 Key Models Implemented
stg_green_tripdata / stg_yellow_tripdata: Initial cleaning, casting, and renaming.

dim_zones: Dimension table for taxi zones.

fact_trips: The core fact table combining Green and Yellow datasets.

fct_monthly_zone_revenue: Aggregated table for business intelligence reporting.

🧪 Data Quality & Testing
Automated tests were implemented to ensure data integrity:

unique and not_null constraints on primary keys.

accepted_values for categorical fields like payment_type.

Relationship tests between fact and dimension tables.

This project is part of the Data Engineering Zoomcamp.


