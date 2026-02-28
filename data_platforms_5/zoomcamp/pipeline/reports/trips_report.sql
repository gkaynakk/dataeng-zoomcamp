/* @bruin

name: reports.trips_report
type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: time_interval
  strategy: delete+insert
  incremental_key: pickup_datetime


columns:
  - name: pickup_date
    type: DATE
    description: "Pickup date (UTC window based on start/end datetime)"
    primary_key: true
  - name: payment_type
    type: VARCHAR
    description: "Payment type"
    primary_key: true

  - name: trips_count
    type: BIGINT
    description: "Number of trips"
    checks:
      - name: non_negative

  - name: total_fare_amount
    type: DOUBLE
    description: "Total fare amount"
    checks:
      - name: non_negative

  - name: avg_fare_amount
    type: DOUBLE
    description: "Average fare amount"
    checks:
      - name: non_negative

  - name: total_trip_distance
    type: DOUBLE
    description: "Total trip distance"
    checks:
      - name: non_negative

  - name: avg_trip_distance
    type: DOUBLE
    description: "Average trip distance"
    checks:
      - name: non_negative

custom_checks:
  - name: row_count_positive
    description: "Ensure report has rows for the interval"
    query: |
      SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS result
      FROM reports.trips_report
      WHERE pickup_date >= DATE('{{ start_datetime }}')
        AND pickup_date <  DATE('{{ end_datetime }}')
    value: 1

@bruin */

WITH base AS (
  SELECT
    CAST(pickup_datetime AS DATE) AS pickup_date,
    payment_type,
    fare_amount,
    trip_distance
  FROM staging.trips
  WHERE pickup_datetime >= '{{ start_datetime }}'
    AND pickup_datetime <  '{{ end_datetime }}'
)
SELECT
  pickup_date,
  payment_type,
  COUNT(*)                          AS trips_count,
  SUM(fare_amount)                  AS total_fare_amount,
  AVG(fare_amount)                  AS avg_fare_amount,
  SUM(trip_distance)                AS total_trip_distance,
  AVG(trip_distance)                AS avg_trip_distance
FROM base
GROUP BY 1, 2;