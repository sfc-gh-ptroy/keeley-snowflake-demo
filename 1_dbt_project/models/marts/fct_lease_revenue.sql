{{config(
    materialized='table',
    cluster_by=['property_id', 'transaction_date']
)}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

leases as (
    select * from {{ ref('stg_leases') }}
),

properties as (
    select * from {{ ref('stg_properties') }}
),

final as (
    select
        t.transaction_id,
        t.transaction_date,
        date_trunc('month', t.transaction_date)           as transaction_month,
        date_trunc('year',  t.transaction_date)           as transaction_year,
        p.property_id,
        p.property_name,
        p.property_type,
        p.city,
        p.state,
        l.lease_id,
        l.tenant_name,
        l.suite_number,
        l.leased_sqft,
        l.lease_type,
        t.transaction_type,
        t.amount,
        t.is_late_payment,
        t.late_fee_amount,
        t.amount + coalesce(t.late_fee_amount, 0)        as total_collected,
        l.base_rent_monthly,
        t.amount - l.base_rent_monthly                   as variance_from_base_rent
    from transactions t
    left join leases     l using (lease_id)
    left join properties p using (property_id)
)

select * from final
