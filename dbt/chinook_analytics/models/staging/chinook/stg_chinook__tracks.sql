
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
        {{ dbt_utils.generate_surrogate_key(['"TrackId"']) }} as track_key,

        -- Foreign Keys
        "AlbumId" as album_id,
        {{ dbt_utils.generate_surrogate_key(['"AlbumId"']) }} as album_key,
        "MediaTypeId" as media_type_id,
        {{ dbt_utils.generate_surrogate_key(['"MediaTypeId"']) }} as media_type_key,
        "GenreId" as genre_id,
        {{ dbt_utils.generate_surrogate_key(['"GenreId"']) }} as genre_key,

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
