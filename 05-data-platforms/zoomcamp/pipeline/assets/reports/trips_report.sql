/* @bruin

# Docs:
# - SQL assets: https://getbruin.com/docs/bruin/assets/sql
# - Materialization: https://getbruin.com/docs/bruin/assets/materialization
# - Quality checks: https://getbruin.com/docs/bruin/quality/available_checks

name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  incremental_key: pickup_date
  strategy: time_interval
  time_granularity: date

columns:
  - name: vendor_id
    type: INTEGER
    description: Unique identifier for taxi vendor
    primary_key: true
  - name: pickup_date
    type: DATE
    description: Date of trip pickup (grouped by date)
    primary_key: true
  - name: trip_count
    type: BIGINT
    description: Number of trips on this vendor/date
    checks:
      - name: non_negative
  - name: total_revenue
    type: DOUBLE
    description: Total fare + extra + tolls + tips for all trips
    checks:
      - name: non_negative
  - name: avg_trip_distance
    type: DOUBLE
    description: Average trip distance in miles
    checks:
      - name: non_negative
  - name: avg_fare
    type: DOUBLE
    description: Average fare amount per trip
    checks:
      - name: non_negative
  - name: avg_tip_amount
    type: DOUBLE
    description: Average tip amount per trip
    checks:
      - name: non_negative

@bruin */

-- Purpose of reports:
-- - Aggregate staging data for dashboards and analytics
-- Dimensions: vendor, date
-- Metrics: trip count, revenue, avg distance, avg fare, avg tip

SELECT
  vendor_id,
  CAST(pickup_datetime AS DATE) AS pickup_date,
  COUNT(*) AS trip_count,
  SUM(total_amount) AS total_revenue,
  AVG(trip_distance) AS avg_trip_distance,
  AVG(fare_amount) AS avg_fare,
  AVG(tip_amount) AS avg_tip_amount
FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY vendor_id, CAST(pickup_datetime AS DATE)
ORDER BY pickup_date DESC, vendor_id
