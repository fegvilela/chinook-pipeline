#!/bin/bash
# entrypoint.sh - Enhanced dbt initialization with .env support

set -euo pipefail  # Strict error handling

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="${PROJECT_NAME}"

# Set default if PROJECT_DIR not defined
export PROJECT_DIR="${CONTAINER_PROJECT_DIR}"/"${PROJECT_NAME}"

main() {
    echo "🟢 Starting in PROJECT_DIR: ${PROJECT_DIR}"
    cd "$PROJECT_DIR" || { echo "🔴 Failed to enter PROJECT_DIR"; exit 1; }

    if [ ! -f "dbt_project.yml" ]; then
        echo "🟠 Initializing dbt project..."
        dbt init ${PROJECT_NAME} --skip-profile-setup  --use-colors
        echo "✅ dbt project initialized in ${PROJECT_DIR}"
    else
        echo "🔍 dbt_project.yml found - skipping initialization"
    fi

    # Execute subsequent commands
    if [ "$#" -gt 0 ]; then
        echo "🚀 Executing: $@"
        exec "$@"
    else
        echo "🟢 Ready - container kept alive"
        tail -f /dev/null
    fi
}

main "$@"
