with source as (
    select * from {{ source('raw', 'leases') }}
),

renamed as (
    select
        lease_id::varchar             as lease_id,
        property_id::varchar          as property_id,
        tenant_name::varchar          as tenant_name,
        suite_number::varchar         as suite_number,
        leased_sqft::number           as leased_sqft,
        lease_start_date::date        as lease_start_date,
        lease_end_date::date          as lease_end_date,
        base_rent_monthly::number     as base_rent_monthly,
        annual_escalation_pct::float  as annual_escalation_pct,
        has_renewal_option::boolean   as has_renewal_option,
        renewal_term_years::integer   as renewal_term_years,
        lease_type::varchar           as lease_type,
        loaded_at::timestamp_ntz      as loaded_at
    from source
),

with_calculated_fields as (
    select
        *,
        datediff('day', current_date(), lease_end_date) as days_to_expiration,
        case
            when datediff('day', current_date(), lease_end_date) <= 90  then 'critical'
            when datediff('day', current_date(), lease_end_date) <= 180 then 'warning'
            when datediff('day', current_date(), lease_end_date) <= 365 then 'watch'
            else 'healthy'
        end as expiration_status,
        base_rent_monthly * 12 as annual_base_rent
    from renamed
    where lease_end_date >= current_date()
)

select * from with_calculated_fields
