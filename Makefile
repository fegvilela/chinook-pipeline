# Makefile for dbt project with Docker (Chinook -> Analytics)

# Variables
# Carrega as variáveis do .env (se existir)
ifneq (,$(wildcard ./.env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

DOCKER_COMPOSE := docker-compose
DBT_SERVICE := dbt_chinook
DAGSTER_SERVICE := dagster_user_code
DAGSTER_PROJECT_NAME := dagster_chinook
DBT_DIR := ../dbt/chinook_analytics

# Phony targets
.PHONY: docker-setup \
        dbt-init dbt-run dbt-test dbt-docs dbt-serve dbt-clean dbt-debug \
        dbt-run-model dbt-seed \
        docker-rebuild dbt-docker-shell \
        dagster-init \
        help

docker-setup:
	@echo "Setting up Docker image and permissions for apple-silicon..."
	chmod +x dbt/scripts/dbt_entrypoint.sh
	docker build --tag dbt_chinook_image --target dbt-postgres . --platform linux/arm64/v8 --file Dockerfile_dbt
	docker compose build dagster_user_code
	$(DOCKER_COMPOSE) up -d
	@echo "✅ Setup is done!"

# Access container for interactive commands
dbt-docker-shell:
	$(DOCKER_COMPOSE) exec -it $(DBT_SERVICE)  /bin/bash

# Rebuild Docker image
docker-rebuild:
	$(DOCKER_COMPOSE) build --no-cache

# Initialize a new dbt project
dbt-init:
	@echo "Initializing dbt project..."
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt init $(PROJECT_NAME) --skip-profile-setup --use-colors"
	@echo "Project initialized. Configure your profiles.yml before proceeding."



# Run all models
dbt-run:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt run"

# Test all models
dbt-test:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt test"

# Generate documentation
dbt-docs:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt docs generate"

# Serve documentation (http://localhost:8080)
dbt-serve:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt docs serve"

# Clean build artifacts
dbt-clean:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt clean"
# 	rm -rf target/

# Verify database connection
dbt-debug:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt debug"

# Run specific model (make run-model MODEL=models/staging/chinook/stg_customers.sql)
dbt-run-model:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt run --models $(MODEL)"

# Run seeds (if any)
dbt-seed:
	$(DOCKER_COMPOSE) exec $(DBT_SERVICE) sh -c "dbt seed"



dagster-init:
	$(DOCKER_COMPOSE) exec $(DAGSTER_SERVICE) sh -c "dagster-dbt project scaffold --project-name $(DAGSTER_PROJECT_NAME) --dbt-project-dir $(DBT_DIR)"

# List all available commands
help:
	@echo "Available commands:"
	@echo "  make docker-setup      - Set up Docker environment (build images and start containers)"
	@echo "  make dbt-init         - Initialize a new dbt project"
	@echo "  make dbt-run          - Run all dbt models"
	@echo "  make dbt-test         - Run all dbt tests"
	@echo "  make dbt-docs         - Generate dbt documentation"
	@echo "  make dbt-serve        - Start dbt documentation server (port 8080)"
	@echo "  make dbt-clean        - Clean dbt build artifacts"
	@echo "  make dbt-debug        - Verify database connection"
	@echo "  make dbt-run-model    - Run specific model (MODEL=path/to/model.sql)"
	@echo "  make dbt-seed         - Run dbt seeds"
	@echo "  make docker-rebuild   - Rebuild Docker images"
	@echo "  make dbt-docker-shell - Access dbt container for interactive commands"
	@echo "  make dagster-init     - Initialize Dagster project scaffolding"
	@echo ""
	@echo "Note: All dbt commands are prefixed with 'dbt-' to distinguish them from Docker or Dagster commands"



