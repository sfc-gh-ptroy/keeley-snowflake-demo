with properties as (
    select * from {{ ref('stg_properties') }}
),

leases as (
    select * from {{ ref('stg_leases') }}
),

property_leased_sqft as (
    select
        property_id,
        sum(leased_sqft)                                    as total_leased_sqft,
        count(lease_id)                                     as active_lease_count,
        sum(annual_base_rent)                               as total_annual_base_rent,
        sum(case when expiration_status = 'critical'
            then leased_sqft else 0 end)                    as critical_expiring_sqft,
        sum(case when expiration_status in ('critical', 'warning')
            then leased_sqft else 0 end)                    as at_risk_sqft
    from leases
    group by property_id
),

final as (
    select
        p.property_id,
        p.property_name,
        p.property_type,
        p.city,
        p.state,
        p.rentable_sqft,
        coalesce(l.total_leased_sqft, 0)                   as total_leased_sqft,
        coalesce(l.active_lease_count, 0)                  as active_lease_count,
        coalesce(l.total_annual_base_rent, 0)              as total_annual_base_rent,
        coalesce(l.critical_expiring_sqft, 0)              as critical_expiring_sqft,
        coalesce(l.at_risk_sqft, 0)                        as at_risk_sqft,
        case
            when p.rentable_sqft > 0
            then round(coalesce(l.total_leased_sqft, 0) / p.rentable_sqft * 100, 2)
            else 0
        end                                                 as occupancy_pct
    from properties p
    left join property_leased_sqft l using (property_id)
)

select * from final
