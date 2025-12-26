# Troubleshooting Guide

## Common Issues

### Docker Not Running

**Symptom**: `Cannot connect to the Docker daemon`

**Solutions**:
```bash
# macOS/Linux
open -a Docker  # or start Docker Desktop

# Linux (systemd)
sudo systemctl start docker

# Check status
docker info
```

### Insufficient Memory

**Symptom**: Containers crash, `OOMKilled` status

**Check memory**:
```bash
docker stats --no-stream
```

**Solutions**:
1. Increase Docker Desktop memory allocation (Settings → Resources)
2. Use LocalExecutor to reduce services
3. Stop unused containers: `docker system prune`

### Port Already in Use

**Symptom**: `port is already allocated`

**Find process using port**:
```bash
# macOS/Linux
lsof -i :8080

# Kill process
kill -9 <PID>
```

**Or change Airflow port** in `docker-compose.override.yaml`:
```yaml
services:
  airflow-webserver:
    ports:
      - "8081:8080"
```

### Permission Denied on Logs/DAGs

**Symptom**: `PermissionError` or `[Errno 13]`

**Solutions**:
```bash
# Check AIRFLOW_UID matches your user
echo "AIRFLOW_UID=$(id -u)" >> .env

# Fix directory permissions
chmod -R 755 ./dags ./logs ./plugins ./config

# Reset and reinitialize
docker compose down --volumes
docker compose up airflow-init
```

### Database Connection Failed

**Symptom**: `could not connect to server: Connection refused`

**Solutions**:
```bash
# Check if postgres is running
docker compose ps postgres

# Check postgres logs
docker compose logs postgres

# Restart postgres
docker compose restart postgres

# Wait and retry
sleep 10
docker compose up airflow-init
```

### DAGs Not Appearing

**Symptom**: DAGs folder has files but UI shows nothing

**Check DAG errors**:
```bash
docker compose run --rm airflow-cli airflow dags list-import-errors
```

**Common causes**:
1. Syntax errors in DAG files
2. Missing dependencies
3. DAG file doesn't have `dag` variable at module level

**Force DAG rescan**:
```bash
docker compose run --rm airflow-cli airflow dags reserialize
```

### Scheduler Not Processing

**Symptom**: Tasks stuck in "scheduled" or "queued"

**Solutions**:
```bash
# Check scheduler logs
docker compose logs airflow-scheduler

# Restart scheduler
docker compose restart airflow-scheduler

# If using Celery, check worker
docker compose logs airflow-worker
docker compose restart airflow-worker
```

## Reset Everything

Complete cleanup and fresh start:

```bash
# Stop and remove everything
docker compose down --volumes --rmi all

# Remove local data
rm -rf ./logs/* ./plugins/__pycache__

# Reinitialize
docker compose up airflow-init
docker compose up -d
```

## Logs Locations

| Service   | View Logs                              |
| --------- | -------------------------------------- |
| All       | `docker compose logs -f`               |
| Webserver | `docker compose logs airflow-webserver`|
| Scheduler | `docker compose logs airflow-scheduler`|
| Worker    | `docker compose logs airflow-worker`   |
| Task logs | `./logs/dag_id=X/run_id=X/task_id=X/`  |

## Health Checks

```bash
# Check all services
docker compose ps

# Check Airflow health
curl http://localhost:8080/health

# Check database connection
docker compose run --rm airflow-cli airflow db check
```
