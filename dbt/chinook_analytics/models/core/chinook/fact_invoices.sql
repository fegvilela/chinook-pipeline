{{
  config(
    materialized='incremental',
    unique_key='invoice_info_key',
    incremental_strategy='delete+insert'
  )
}}

with invoice_lines_source as (
    select
        il.invoice_line_id,
        il.invoice_id,
        il.track_id,
        il.quantity,
        il.unit_price,
        il.quantity * il.unit_price as total_amount,
        i.customer_id,
        i.invoice_date,
        c.support_rep_id as employee_id
    from {{ ref('stg_chinook__invoice_lines') }} il
    join {{ ref('stg_chinook__invoices') }} i using (invoice_id)
    join {{ ref('stg_chinook__customers') }} c using(customer_id)
    {% if is_incremental() %}
    where il.dbt_loaded_at >= (select max(dbt_loaded_at) from {{ this }})
    {% endif %}
),

final as (
    select
        -- surrogate keys
        {{ dbt_utils.generate_surrogate_key(['il.invoice_line_id', 'il.invoice_id']) }} as invoice_info_key,
        {{ dbt_utils.generate_surrogate_key(['il.customer_id']) }} as customer_key,
        {{ dbt_utils.generate_surrogate_key(['il.employee_id']) }} as employee_key,
        {{ dbt_utils.generate_surrogate_key(['il.invoice_date']) }} as date_key,
        {{ dbt_utils.generate_surrogate_key(['il.track_id']) }} as track_key,

        -- business keys
        il.invoice_line_id,
        il.invoice_id,

        -- measures
        il.quantity,
        il.unit_price,
        il.total_amount,

        -- metadata
        current_timestamp as dbt_loaded_at,
        '{{ invocation_id }}' as dbt_invocation_id
    from invoice_lines_source il
)

select * from final


