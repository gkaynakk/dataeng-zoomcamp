/* @bruin

name: staging.trips
type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: time_interval
  strategy: delete+insert
  incremental_key: pickup_datetime

columns:
  - name: pickup_datetime
    type: timestamp
    description: "When the meter was engaged"
    primary_key: true
  - name: dropoff_datetime
    type: timestamp
    description: "When the meter was disengaged"
    primary_key: true
  - name: passenger_count
    type: integer
    description: "Number of passengers in the trip"
  - name: trip_distance
    type: float
    description: "Distance of the trip in miles"
  - name: fare_amount
    type: float
    description: "Fare amount for the trip"
  - name: payment_type
    type: string
    description: "Payment type name"
    checks:
      - name: not_null

custom_checks:
  - name: row_count_positive
    description: "Check that the number of rows in staging.trips is greater than 0"
    query: "SELECT COUNT(*) > 0 AS result FROM staging.trips"
    value: 1

@bruin */

-- Clean, deduplicate, and enrich raw trip data
WITH trips_raw AS (
  SELECT 
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount,
    payment_type
  FROM ingestion.trips
  WHERE pickup_datetime >= '{{ start_datetime }}'
    AND pickup_datetime < '{{ end_datetime }}'
),
trips_deduplicated AS (
  SELECT 
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    fare_amount,
    payment_type,
    ROW_NUMBER() OVER (
      PARTITION BY pickup_datetime, dropoff_datetime, fare_amount
      ORDER BY pickup_datetime
    ) AS rn
  FROM trips_raw
)
SELECT 
  pickup_datetime,
  dropoff_datetime,
  COALESCE(passenger_count, 1) AS passenger_count,
  COALESCE(trip_distance, 0) AS trip_distance,
  fare_amount,
  payment_type
FROM trips_deduplicated
WHERE rn = 1
  AND fare_amount > 0
  AND trip_distance >= 0
  AND passenger_count > 0;