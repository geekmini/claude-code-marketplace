# Airflow Setup Plugin

Setup local Apache Airflow environment with Docker Compose.

## Installation

```sh
claude plugins add geekmini-claude-code-plugins/airflow-setup
```

## Usage

The skill triggers automatically when you ask Claude to:
- "setup airflow"
- "install airflow locally"
- "create airflow environment"
- "configure airflow docker"

## What It Does

1. Downloads official Airflow docker-compose.yaml
2. Creates directories (`dags/`, `logs/`, `plugins/`, `config/`)
3. Configures `AIRFLOW_UID` in `.env`
4. Initializes Airflow database
5. Integrates with project (justfile, documentation)

## After Setup

- Start: `just airflow-up` or `docker compose up -d`
- URL: http://localhost:8080
- Credentials: `airflow` / `airflow`

## Requirements

- Docker (running, 4GB+ RAM)
