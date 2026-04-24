with source as (
    select * from {{ source('raw', 'properties') }}
),

renamed as (
    select
        property_id::varchar          as property_id,
        property_name::varchar        as property_name,
        property_type::varchar        as property_type,
        address::varchar              as address,
        city::varchar                 as city,
        state::varchar                as state,
        zip_code::varchar             as zip_code,
        total_sqft::number            as total_sqft,
        rentable_sqft::number         as rentable_sqft,
        year_built::integer           as year_built,
        acquisition_date::date        as acquisition_date,
        current_market_value::number  as current_market_value,
        is_active::boolean            as is_active,
        loaded_at::timestamp_ntz      as loaded_at
    from source
    where is_active = true
)

select * from renamed
