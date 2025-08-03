-- Create a user for dbt with a secure password
CREATE USER dbt_user WITH PASSWORD 'your_secure_password';

-- Grant connection permission to the chinook database
GRANT CONNECT ON DATABASE chinook TO dbt_user;

-- Access to the schema
GRANT USAGE ON SCHEMA chinook TO dbt_user;

-- Permission to view existing tables
GRANT SELECT ON ALL TABLES IN SCHEMA chinook TO dbt_user;

-- Permission for future tables (optional)
ALTER DEFAULT PRIVILEGES IN SCHEMA chinook
GRANT SELECT ON TABLES TO dbt_user;

-- Create analytics schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS analytics;

-- Full access to analytics schema
GRANT ALL PRIVILEGES ON SCHEMA analytics TO dbt_user;

-- Permissions for all existing tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO dbt_user;

-- Permissions for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA analytics
GRANT ALL PRIVILEGES ON TABLES TO dbt_user;

-- Permission to create tables
GRANT CREATE ON SCHEMA analytics TO dbt_user;

-- Allows viewing tables with \dt command
GRANT USAGE ON SCHEMA information_schema TO dbt_user;
GRANT SELECT ON ALL TABLES IN SCHEMA information_schema TO dbt_user;

-- List user privileges
SELECT * FROM information_schema.role_table_grants
WHERE grantee = 'dbt_user';
