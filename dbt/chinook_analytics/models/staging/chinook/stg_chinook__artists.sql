
{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'artist') }}

),

renamed as (

    select
        -- Primary Key
        "ArtistId" as artist_id,
        {{ dbt_utils.generate_surrogate_key(['"ArtistId"']) }} as artist_key,

        -- Attributes
        "Name" as artist_name,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
