---
name: setup
description: Setup local Apache Airflow environment with Docker Compose. Use when user asks to "setup airflow", "install airflow locally", "create airflow environment", "configure airflow docker", "init airflow", or needs a local workflow orchestration tool.
---

# Airflow Setup

Setup Apache Airflow locally using Docker Compose.

## Process

### 1. Verify Docker

```bash
docker info > /dev/null 2>&1
```

If not running, inform user and stop.

### 2. Check Existing Setup

If `docker-compose.yaml` exists, ask user to confirm overwrite.

### 3. Download Configuration

```bash
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml'
mkdir -p ./dags ./logs ./plugins ./config
```

### 4. Configure Environment

Append to `.env` if `AIRFLOW_UID` not present:

```bash
echo "AIRFLOW_UID=$(id -u)" >> .env
```

### 5. Initialize Database

```bash
docker compose up airflow-init
```

Wait for exit code 0.

### 6. Project Integration (Optional)

**If justfile exists**: Append Airflow commands from `references/justfile-commands.md`.

**If README.md exists**: Add Airflow to Local URLs table.

**If CLAUDE.md exists**: Add Airflow commands section.

### 7. Completion

Report to user:
- Start: `docker compose up -d` (or `just airflow-up` if justfile configured)
- URL: http://localhost:8080
- Credentials: `airflow` / `airflow`

## Error Handling

| Error | Solution |
|-------|----------|
| Docker not running | Start Docker Desktop |
| Download fails | Check network |
| Init fails | Increase Docker memory to 4GB+ |

## References

- `references/justfile-commands.md` - Commands to add to justfile
- `references/docker-requirements.md` - Docker resource requirements
- `references/customization.md` - Environment variables and config options
- `references/troubleshooting.md` - Common issues and solutions
