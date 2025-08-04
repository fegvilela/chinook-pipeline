{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'album') }}

),

renamed as (

    select
        -- Primary Key
        "AlbumId" as album_id,

        -- Attributes
        trim("Title") as album_title,

        -- Foreign Keys
        "ArtistId" as artist_id,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
