{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'customer') }}

),

renamed as (

    select
        -- Primary Key
        "CustomerId" as customer_id,

        -- Attributes
        trim("FirstName") as first_name,
        trim("LastName") as last_name,
        nullif(trim("Company"), '') as company,
        trim("Address") as address,
        trim("City") as city,
        nullif(trim("State"), '') as state,
        trim("Country") as country,
        trim("PostalCode") as postal_code,
        trim("Phone") as phone,
        nullif(trim("Fax"), '') as fax,
        lower(trim("Email")) as email,

        -- Foreign Keys
        "SupportRepId" as support_rep_id,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

),

deduped as (

    select
        *,
        row_number() over (
            partition by customer_id
            order by dbt_loaded_at desc
        ) as row_num
    from renamed

)

select
    customer_id,
    first_name,
    last_name,
    company,
    address,
    city,
    state,
    country,
    postal_code,
    phone,
    fax,
    email,
    support_rep_id,
    dbt_loaded_at
from deduped
where row_num = 1
