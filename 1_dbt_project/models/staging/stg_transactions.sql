with source as (
    select * from {{ source('raw', 'transactions') }}
),

renamed as (
    select
        transaction_id::varchar       as transaction_id,
        property_id::varchar          as property_id,
        lease_id::varchar             as lease_id,
        transaction_date::date        as transaction_date,
        transaction_type::varchar     as transaction_type,
        amount::number                as amount,
        payment_method::varchar       as payment_method,
        is_late_payment::boolean      as is_late_payment,
        late_fee_amount::number       as late_fee_amount,
        notes::varchar                as notes,
        loaded_at::timestamp_ntz      as loaded_at
    from source
    where transaction_date >= dateadd('year', -2, current_date())
)

select * from renamed
