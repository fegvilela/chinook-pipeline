{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'genre') }}

),

renamed as (

    select
        -- Primary Key
        "GenreId" as genre_id,

        -- Attributes
        trim("Name") as genre_name,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
