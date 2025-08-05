# Chinook Data Pipeline

![Data Pipeline](https://img.shields.io/badge/architecture-ETL-orange)
![Tools](https://img.shields.io/badge/tools-dbt%20|%20Dagster%20|%20Docker-blue)

A complete data pipeline implementation for the Chinook database with dbt transformations and Dagster orchestration.

## 📂 Project Structure

```
chinook-pipeline/
├── dbt/                        # dbt project
│   ├── chinook_analytics/      # Main project
│   │   ├── models/             # Data models
│   │   │   ├── staging/       # Raw source models
│   │   │   └── core/          # Business transformations
│   │   ├── seeds/             # Reference data
│   │   ├── tests/             # Data tests
│   │   └── dbt_project.yml    # Project config
├── dagster/                   # Orchestration
│   ├── repository.py          # Pipeline definitions
│   ├── schedules.py           # Automation config
│   └── workspace.yaml         # Dev environment
├── docker-compose.yml         # Container setup
├── Dockerfile_dbt             # dbt environment
└── scripts/                   # Utility scripts
```

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+

### Installation

```bash
git clone https://github.com/fegvilela/chinook-pipeline.git
cd chinook-pipeline
```

### Running the Pipeline

```bash
# Start all services
docker-compose up -d --build

```

## 🛠️ Usage

### dbt Commands

```bash
# Run all models
docker-compose exec dbt_chinook dbt run

# Run specific model
docker-compose exec dbt_chinook dbt run --models <MODEL_NAME>

# Generate docs
docker-compose exec dbt_chinook dbt docs generate
```

### Access Services

| Service        | URL                   | Credentials         |
| -------------- | --------------------- | ------------------- |
| **Dagster UI** | http://localhost:3000 | None                |
| **dbt Docs**   | http://localhost:8080 | After docs generate |
| **PostgreSQL** | yugabyteDB            | -                   |

## 🔄 Daily Pipeline

The Dagster pipeline is configured to:

1. Load new data at 02:00 UTC daily
2. Run dbt transformations
3. Handle incremental updates

View scheduled runs in the Dagster UI.

## 🛡️ Testing

```bash
# Run dbt tests
docker-compose exec dbt_chinook dbt test

# Run unit tests
docker-compose exec dagster pytest
```

## 📝 Design Highlights

- **Incremental models** for fact tables
- **Dagster assets** for data lineage
- **Containerized** environment
- **Daily automation** with error handling

---

# Dimensional Star Schema Modeling - Chinook Database

## Central Fact Table

### fact_invoice

| Column           | Type    | Description                     | Relationship   |
| ---------------- | ------- | ------------------------------- | -------------- |
| invoice_line_key | PK      | Surrogate key for invoice line  | -              |
| customer_key     | FK      | Customer key                    | → dim_customer |
| employee_key     | FK      | Support rep key                 | → dim_employee |
| date_key         | FK      | Date key                        | → dim_date     |
| track_key        | FK      | Music track key                 | → dim_track    |
| invoice_line_id  | INT     | Original line ID (business key) | -              |
| invoice_id       | INT     | Original invoice ID             | -              |
| quantity         | INT     | Quantity sold                   | -              |
| unit_price       | DECIMAL | Unit price                      | -              |
| total_amount     | DECIMAL | Total (quantity × unit_price)   | -              |

## Implemented Changes:

1. **New PK for line-item granularity**:

   - `invoice_line_key` as surrogate primary key
   - Enables analysis of individual sale items

2. **Dual-key for traceability**:

   - Maintains `invoice_line_id` (original ID) as business key
   - Adds `invoice_id` for full document reference

3. **Optional self-relationship**:
   - `invoice_key` can create an invoice header dimension if needed

## Impact on Relationships:

1. Fact table now has **invoice line granularity** (not invoice-level)
2. All metrics (`quantity`, `unit_price`) are naturally line-items
3. Aggregate queries should use `invoice_id` for document-level analysis

## Usage Example:

```sql
-- Line-item analysis
SELECT
    f.invoice_line_id,
    t.track_name,
    f.quantity,
    f.total_amount
FROM fact_invoice f
JOIN dim_track t ON f.track_key = t.track_key

-- Complete invoice analysis
SELECT
    f.invoice_id,
    SUM(f.total_amount) as invoice_total
FROM fact_invoice f
GROUP BY f.invoice_id
```

## Dimension Tables

### dim_customer

| Column           | Type    | Description                     |
| ---------------- | ------- | ------------------------------- |
| customer_key     | PK      | Surrogate key                   |
| customer_id      | INT     | Original system ID              |
| first_name       | VARCHAR | Customer first name             |
| last_name        | VARCHAR | Customer last name              |
| company          | VARCHAR | Company (if applicable)         |
| city             | VARCHAR | City                            |
| country          | VARCHAR | Country                         |
| support_rep_name | VARCHAR | Support rep name (denormalized) |

### dim_employee

| Column          | Type    | Description                    |
| --------------- | ------- | ------------------------------ |
| employee_key    | PK      | Surrogate key                  |
| employee_id     | INT     | Original ID                    |
| first_name      | VARCHAR | First name                     |
| last_name       | VARCHAR | Last name                      |
| title           | VARCHAR | Job title                      |
| hire_date       | DATE    | Hire date                      |
| reports_to_name | VARCHAR | Supervisor name (denormalized) |

### dim_track

| Column      | Type    | Description              |
| ----------- | ------- | ------------------------ |
| track_key   | PK      | Surrogate key            |
| track_id    | INT     | Original ID              |
| track_name  | VARCHAR | Track name               |
| album_name  | VARCHAR | Album (denormalized)     |
| artist_name | VARCHAR | Artist (denormalized)    |
| genre_name  | VARCHAR | Music genre              |
| media_type  | VARCHAR | Format (MP3, AAC, etc.)  |
| duration_ms | INT     | Duration in milliseconds |

### dim_date

| Column    | Type | Description         |
| --------- | ---- | ------------------- |
| date_key  | PK   | YYYYMMDD format     |
| full_date | DATE | Complete date       |
| day       | INT  | Day of month (1-31) |
| month     | INT  | Month (1-12)        |
| year      | INT  | Year                |
| quarter   | INT  | Quarter (1-4)       |

## Relationships

1. `fact_invoice.customer_key` → `dim_customer.customer_key`
2. `fact_invoice.employee_key` → `dim_employee.employee_key`
3. `fact_invoice.date_key` → `dim_date.date_key`
4. `fact_invoice.track_key` → `dim_track.track_key`

## Mapped Business Rules

- Each row in `fact_invoice` represents a sale line item
- Calculated metrics: `total_amount = quantity × unit_price`
- Denormalized dimensions for query optimization

> **Note:** All primary keys (PK) are dbt-generated surrogate keys.

## Notes on fact implementation

The invoces fact is incremental, based on the `invoice_info_key` as unique key, that's a surrogate key composed by `invoice_id` and `invoice_line_id`. The incremental strategy chosen was the `delete+insert`, as `merge` option is not available for the yugabyte database ([link](https://docs.yugabyte.com/preview/develop/pg15-features/#coming-soon)), that would be the best one for this case, as we wanted to insert new rows and add the updates, but `delete+insert` ensures updated records are fully replaced.

`invoice_info_key` was chosen instead of `invoice_id` because it enables `1 - n` relationships with dimension tables, such as `dim_tracks`
