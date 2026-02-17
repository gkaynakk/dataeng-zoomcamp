with source as (
    select *
    from {{ source('taxi', 'fhv_tripdata') }}
)

select
    dispatching_base_num,
    affiliated_base_number,

    -- rename: TLC naming -> project naming
    PUlocationID    as pickup_location_id,
    DOlocationID    as dropoff_location_id,

    -- timestamps
    pickup_datetime,
    dropoff_datetime,

    sr_flag
from source
where dispatching_base_num is not null
