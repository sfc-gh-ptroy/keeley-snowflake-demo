{{config(materialized='table')}}

with occupancy as (
    select * from {{ ref('int_property_occupancy') }}
),

final as (
    select
        property_id,
        property_name,
        property_type,
        city,
        state,
        rentable_sqft,
        total_leased_sqft,
        active_lease_count,
        total_annual_base_rent,
        critical_expiring_sqft,
        at_risk_sqft,
        occupancy_pct,
        case
            when occupancy_pct >= 95 then 'strong'
            when occupancy_pct >= 85 then 'healthy'
            when occupancy_pct >= 70 then 'watch'
            else 'at_risk'
        end                                              as occupancy_tier,
        case
            when critical_expiring_sqft > 0 then true
            else false
        end                                              as has_critical_expirations,
        round(total_annual_base_rent / nullif(total_leased_sqft, 0), 2) as rent_per_sqft
    from occupancy
)

select * from final
