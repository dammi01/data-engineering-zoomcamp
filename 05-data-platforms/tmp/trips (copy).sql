/* @bruin
name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table

custom_checks:
  - name: row_count_positive
    description: Ensures the table is not empty
    query: SELECT COUNT(*) > 0 FROM staging.trips
    value: 1

@bruin */

-- Staging SELECT: clean, normalize, deduplicate, enrich with lookups,
-- and filter the same `{{ start_datetime }}` / `{{ end_datetime }}` window.

WITH cleaned_trips AS (
  SELECT
    VendorID,
    tpep_pickup_datetime AS pickup_datetime,
    tpep_dropoff_datetime AS dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID,
    payment_type,
    pl.payment_type_name,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    total_amount,
    extracted_at,
    taxi_type,
    -- Add row number for deduplication
    ROW_NUMBER() OVER (
      PARTITION BY VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count
      ORDER BY extracted_at DESC
    ) AS dedup_row_num
  FROM ingestion.trips t
  LEFT JOIN ingestion.payment_lookup pl ON t.payment_type = pl.payment_type_id
  WHERE tpep_pickup_datetime >= '{{ start_datetime }}'
    AND tpep_pickup_datetime < '{{ end_datetime }}'
    -- Filter invalid records
    AND passenger_count > 0
    AND trip_distance >= 0
    AND fare_amount >= 0
    AND total_amount >= 0
    AND tpep_pickup_datetime <= tpep_dropoff_datetime
)

SELECT
  VendorID,
  pickup_datetime,
  dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  payment_type,
  payment_type_name,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  total_amount,
  extracted_at,
  taxi_type
FROM cleaned_trips
WHERE dedup_row_num = 1  -- Keep only latest version of each trip