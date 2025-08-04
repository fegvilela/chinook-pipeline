{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'invoice_line') }}

),

renamed as (

    select
        -- Primary Key
        "InvoiceLineId" as invoice_line_id,
        {{ dbt_utils.generate_surrogate_key(['"InvoiceLineId"']) }} as invoice_line_key,

        -- Foreign Keys
        "InvoiceId" as invoice_id,
        "TrackId" as track_id,
        {{ dbt_utils.generate_surrogate_key(['"InvoiceId"']) }} as invoice_key,
        {{ dbt_utils.generate_surrogate_key(['"TrackId"']) }} as track_key,

        -- Measures
        "UnitPrice" as unit_price,
        "Quantity" as quantity,
        ("UnitPrice" * "Quantity") as line_item_amount,

        -- Metadata
        current_timestamp as dbt_loaded_at


    from source

),

deduped as (

    select
        *,
        row_number() over (
            partition by invoice_line_id
            order by dbt_loaded_at desc
        ) as row_num
    from renamed

)

select
    invoice_line_id,
    invoice_line_key,
    invoice_id,
    invoice_key,
    track_id,
    track_key,
    unit_price,
    quantity,
    line_item_amount,
    dbt_loaded_at
from deduped
where row_num = 1
