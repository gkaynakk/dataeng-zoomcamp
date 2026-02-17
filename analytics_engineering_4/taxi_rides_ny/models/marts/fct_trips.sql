{{
  config(
    materialized='incremental',
    unique_key='trip_id',
    on_schema_change='fail'
  )
}}

select
    -- Trip identifiers
    trips.trip_id,
    trips.vendor_id,
    trips.service_type,
    trips.rate_code_id,

    -- Location details
    trips.pickup_location_id,
    pz.borough as pickup_borough,
    pz.zone as pickup_zone,
    trips.dropoff_location_id,
    dz.borough as dropoff_borough,
    dz.zone as dropoff_zone,

    -- Trip timing
    trips.pickup_datetime,
    trips.dropoff_datetime,
    trips.store_and_fwd_flag,

    -- Trip metrics
    trips.passenger_count,
    cast(trips.trip_distance as decimal(18,3)) as trip_distance,
    trips.trip_type,
    date_diff('minute', trips.pickup_datetime::timestamp, trips.dropoff_datetime::timestamp) as trip_duration_minutes,

    -- Payment breakdown
    cast(trips.fare_amount as decimal(18,3)) as fare_amount,
    cast(trips.extra as decimal(18,3)) as extra,
    cast(trips.mta_tax as decimal(18,3)) as mta_tax,
    cast(trips.tip_amount as decimal(18,3)) as tip_amount,
    cast(trips.tolls_amount as decimal(18,3)) as tolls_amount,
    cast(trips.ehail_fee as decimal(18,3)) as ehail_fee,
    cast(trips.improvement_surcharge as decimal(18,3)) as improvement_surcharge,
    cast(trips.total_amount as decimal(18,3)) as total_amount,
    trips.payment_type,
    trips.payment_type_description

from {{ ref('int_trips_unioned') }} as trips
left join {{ ref('dim_zones') }} as pz
    on trips.pickup_location_id = pz.location_id
left join {{ ref('dim_zones') }} as dz
    on trips.dropoff_location_id = dz.location_id

{% if is_incremental() %}
where not exists (
  select 1
  from {{ this }} t
  where t.trip_id = trips.trip_id
)
{% endif %}
