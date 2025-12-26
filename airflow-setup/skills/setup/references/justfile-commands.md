# Justfile Commands

Append these commands to the project's justfile:

```just
# === Airflow Commands ===

# Start Airflow services
airflow-up:
    docker compose up -d

# Stop Airflow services
airflow-down:
    docker compose down

# View Airflow logs
airflow-logs:
    docker compose logs -f

# Complete Airflow cleanup (removes data)
airflow-clean:
    docker compose down --volumes --rmi all

# Run Airflow CLI command
airflow-cli *args:
    docker compose run --rm airflow-cli airflow {{args}}

# List DAGs
airflow-dags:
    docker compose run --rm airflow-cli airflow dags list

# Airflow info
airflow-info:
    docker compose run --rm airflow-cli airflow info
```
