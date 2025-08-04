{{
  config(
    materialized='view'
  )
}}

with source as (

    select * from {{ source('chinook', 'employee') }}

),

renamed as (

    select
        -- Primary Key
        "EmployeeId" as employee_id,
        {{ dbt_utils.generate_surrogate_key(['"EmployeeId"']) }} as employee_key,

        -- Attributes
        trim("LastName") as last_name,
        trim("FirstName") as first_name,
        trim("Title") as title,
        "ReportsTo" as reports_to,
        "BirthDate" as birth_date,
        "HireDate" as hire_date,
        trim("Address") as address,
        trim("City") as city,
        trim("State") as state,
        trim("Country") as country,
        trim("PostalCode") as postal_code,
        trim("Phone") as phone,
        trim("Fax") as fax,
        lower(trim("Email")) as email,

        -- Metadata
        current_timestamp as dbt_loaded_at

    from source

)

select * from renamed
