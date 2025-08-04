{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'media_type') }}

),

renamed as (

    select
        -- Primary Key
        "MediaTypeId" as media_type_id,
        {{ dbt_utils.generate_surrogate_key(['"MediaTypeId"']) }} as media_type_key,

        -- Attributes
        trim("Name") as media_type_name,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
