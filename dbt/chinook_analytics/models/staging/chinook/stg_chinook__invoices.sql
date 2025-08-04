{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'invoice') }}

),

renamed as (

    select
        -- Primary Key
        "InvoiceId" as invoice_id,

        -- Foreign Keys
        "CustomerId" as customer_id,

        -- Attributes
        "InvoiceDate" as invoice_date,
        trim("BillingAddress") as billing_address,
        trim("BillingCity") as billing_city,
        nullif(trim("BillingState"), '') as billing_state,
        trim("BillingCountry") as billing_country,
        trim("BillingPostalCode") as billing_postal_code,
        "Total" as total_amount,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
