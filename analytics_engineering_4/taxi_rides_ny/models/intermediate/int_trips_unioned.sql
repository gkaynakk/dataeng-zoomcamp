with green as (
    select
        'Green' as service_type,
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        case try_cast(payment_type as integer)
          when 1 then 'Credit card'
          when 2 then 'Cash'
          when 3 then 'No charge'
          when 4 then 'Dispute'
          when 5 then 'Unknown'
          when 6 then 'Voided trip'
          else 'Other'
        end as payment_type_description
    from {{ ref('stg_green_tripdata') }}
),

yellow as (
    select
        'Yellow' as service_type,
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        null::integer as trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        null::double as ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        case try_cast(payment_type as integer)
          when 1 then 'Credit card'
          when 2 then 'Cash'
          when 3 then 'No charge'
          when 4 then 'Dispute'
          when 5 then 'Unknown'
          when 6 then 'Voided trip'
          else 'Other'  
        end as payment_type_description
    from {{ ref('stg_yellow_tripdata') }}
),

trips_unioned as (
    select * from green
    union all
    select * from yellow
)

select
    md5(
      concat_ws('|',
        cast(service_type as varchar),
        cast(vendor_id as varchar),
        cast(rate_code_id as varchar),
        cast(pickup_datetime as varchar),
        cast(dropoff_datetime as varchar),
        cast(pickup_location_id as varchar),
        cast(dropoff_location_id as varchar),
        cast(store_and_fwd_flag as varchar),
        cast(passenger_count as varchar),
        cast(trip_distance as varchar),
        cast(fare_amount as varchar),
        cast(total_amount as varchar),
        cast(payment_type as varchar)
      )
    ) as trip_id,
    *
from trips_unioned
