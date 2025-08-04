
{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'track') }}

),

renamed as (

    select
        -- Primary Key
        "TrackId" as track_id,

        -- Foreign Keys
        "AlbumId" as album_id,
        "MediaTypeId" as media_type_id,
        "GenreId" as genre_id,

        -- Attributes
        "Name" as track_name,
        "Composer" as composer,
        "Milliseconds" as duration_ms,
        "Bytes" as bytes,
        "UnitPrice" as unit_price,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
