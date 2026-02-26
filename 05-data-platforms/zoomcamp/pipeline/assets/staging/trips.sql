/* @bruin
name: staging.trips
type: duckdb.sql
depends:
  - ingestion.trips
materialization:
  type: table
  strategy: delete+insert
  incremental_key: pickup_datetime
@bruin */

WITH cleaned_trips AS (
  SELECT
    vendor_id AS vendor_id,
    tpep_pickup_datetime AS pickup_datetime,
    tpep_dropoff_datetime AS dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount,
    tip_amount,
    total_amount,
    -- Deduplicação simples
    ROW_NUMBER() OVER (
      PARTITION BY vendor_id, tpep_pickup_datetime, passenger_count
      ORDER BY tpep_pickup_datetime DESC
    ) AS dedup_row_num
  FROM ingestion.trips
  WHERE tpep_pickup_datetime >= '2025-01-01'
    AND tpep_pickup_datetime < '2025-02-01'
)

SELECT
  * EXCLUDE (dedup_row_num)
FROM cleaned_trips
WHERE dedup_row_num = 1