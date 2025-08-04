
-- Use the `ref` function to select from other models

select *
from {{ ref('stg_chinook__artists') }}
where artist_id = 1
