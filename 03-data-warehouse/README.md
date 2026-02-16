## Module 3: Data Warehouse (BigQuery)

### Troubleshooting
Issue: 
Connection timeout (Port 443) during data download due to IPv6 misconfiguration in local environment (Linux Mint). 

Solution: 
Enforced IPv4 policy in wget and system-wide to ensure stable connectivity with Cloudfront/GCP.

### Setup
Execute shell script to download parquet files for thge 6 months:
for month in {01..06}; do
  echo "Baixando mês ${month} via IPv4..."
  # Forçando IPv4 explicitamente conforme diretrizes
  # A flag -4 resolve o erro 443 de conexão IPv6
  wget -4 -N "${URL_BASE}/yellow_tripdata_2024-${month}.parquet"
done

The data was uploaded to GCS using Google Cloud SDK:
`gcloud storage cp taxi_data_2024.parquet gs://my-bucket/`

### Homework Solutions

#### Question 1: What is count of records for the 2024 Yellow Taxi Data?
```sql
-- Query to create external table
CREATE OR REPLACE EXTERNAL TABLE `project.dataset.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://my-bucket/yellow_tripdata_2024-*.parquet']
);

-- Query to get count
SELECT COUNT(*) FROM `project.dataset.external_yellow_tripdata`;

## Module 3: Data Warehousing with BigQuery

This module focused on architecting efficient data storage and query optimization using Google Cloud Platform. 

### Key Technical Achievements
* **Storage Strategy**: Implemented both External Tables (referencing Parquet files on GCS) and Native Materialized Tables.
* **Optimization Proof**: 
    * **Partitioning**: Implemented daily partitioning on `tpep_dropoff_datetime`. 
    * **Clustering**: Organized data by `VendorID` within partitions.
    * **Performance Gain**: Reduced data scanning from **310.24 MB** (non-partitioned) to **26.84 MB** (partitioned) for a 15-day query—a ~91% efficiency increase.
* **Cost Management**: Verified that `SELECT count(*)` on native tables results in **0 bytes processed** by leveraging BigQuery's metadata layer.

### Lessons Learned (The "Skeptical Expert" View)
* **Metadata vs. Scan**: Metadata-only counts are a powerful cost-saving feature for native tables but are unreliable for External Tables.
* **Overhead Management**: Partitioning is only efficient when the partition column is used in the `WHERE` clause; otherwise, it creates unnecessary metadata overhead for the query coordinator.
* **Clustering Threshold**: Clustering is not a "silver bullet" for small tables (<1GB) as the management overhead can outweigh the performance gains.

### Infrastructure
* **Provisioning**: Entire environment (GCS Bucket + BigQuery Dataset) managed via **Terraform**.
* **Security**: Account secured with 2-Step Verification (2SV) as per GCP 2026 requirements.