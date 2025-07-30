# Makefile for dbt project with Docker (Chinook -> Analytics)

# Variables
# Carrega as variáveis do .env (se existir)
ifneq (,$(wildcard ./.env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

DOCKER_COMPOSE := docker-compose
DBT_SERVICE := dbt
PROFILES_DIR := $(shell pwd)/profiles

# Main commands
.PHONY: init run test docs serve clean debug

setup:
	@echo "Setting up Docker image and permissions for apple-silicon..."
	chmod +x scripts/entrypoint.sh
	docker build --tag dbt-apple --target dbt-postgres . --platform linux/arm64/v8
	$(DOCKER_COMPOSE) up -d
	@echo "✅ Setup is done!"

# Initialize a new dbt project
init:
	@echo "Initializing dbt project..."
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) init $(PROJECT_NAME)
	@echo "Project initialized. Configure your profiles.yml before proceeding."

# Run all models
run:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) run

# Test all models
test:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) test

# Generate documentation
docs:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) docs generate

# Serve documentation (http://localhost:8080)
serve:
	$(DOCKER_COMPOSE) run --rm -p 8080:8080 $(DBT_SERVICE) docs serve

# Clean build artifacts
clean:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) clean
	rm -rf target/

# Verify database connection
debug:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) debug

# Run specific model (make run-model MODEL=models/staging/chinook/stg_customers.sql)
run-model:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) run --models $(MODEL)

# Run seeds (if any)
seed:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) seed

# Rebuild Docker image
rebuild:
	$(DOCKER_COMPOSE) build --no-cache

# Access container for interactive commands
shell:
	$(DOCKER_COMPOSE) run --rm $(DBT_SERVICE) /bin/bash

# List all available commands
help:
	@echo "Available commands:"
	@echo "  make init       - Initialize a new dbt project"
	@echo "  make run        - Run all models"
	@echo "  make test       - Run all tests"
	@echo "  make docs       - Generate documentation"
	@echo "  make serve      - Start documentation server (port 8080)"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make debug      - Verify database connection"
	@echo "  make run-model  - Run specific model (MODEL=path/to/model.sql)"
	@echo "  make seed       - Run seeds"
	@echo "  make rebuild    - Rebuild Docker image"
	@echo "  make shell      - Access container for interactive commands"
