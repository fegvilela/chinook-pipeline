-- Create a user for dbt with a secure password
CREATE USER dbt_user WITH PASSWORD 'your_secure_password';

grant connect on database chinook to dbt_user;

-- Grant read permissions on the source schema
grant usage on schema chinook to dbt_user;
grant select on all tables in schema chinook to dbt_user;
alter default privileges in schema chinook grant select on tables to dbt_user;

-- Create destination schema and make dbt_user the owner
create schema if not exists analytics;
alter schema analytics owner to dbt_user;

-- Grant write permissions on the destination schema
grant usage on schema analytics to dbt_user;
grant create on schema analytics to dbt_user;
grant insert, update, delete, truncate on all tables in schema analytics to dbt_user;
alter default privileges in schema analytics grant insert, update, delete, truncate on tables to dbt_user;
