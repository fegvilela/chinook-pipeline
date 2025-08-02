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
