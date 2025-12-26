# Docker Requirements

## System Requirements

### Minimum
- Docker Engine 20.10+
- Docker Compose v2.0+
- 4GB RAM allocated to Docker
- 10GB free disk space

### Recommended
- 8GB+ RAM allocated to Docker
- 20GB+ free disk space
- SSD storage

## Verifying Docker Resources

### Check Docker Info

```bash
docker info --format '{{.MemTotal}}'
```

### macOS (Docker Desktop)

1. Open Docker Desktop
2. Go to Settings → Resources
3. Set Memory to at least 4GB (8GB recommended)
4. Set CPUs to at least 2
5. Apply & Restart

### Linux

Docker uses host resources directly. Ensure:

```bash
# Check available memory
free -h

# Check disk space
df -h
```

### Windows (Docker Desktop)

1. Open Docker Desktop
2. Go to Settings → Resources → Advanced
3. Set Memory to at least 4GB
4. Apply & Restart

## Services Started

The default docker-compose.yaml starts:

| Service           | Purpose                      | Port  |
| ----------------- | ---------------------------- | ----- |
| airflow-webserver | Web UI                       | 8080  |
| airflow-scheduler | DAG scheduling               | -     |
| airflow-worker    | Task execution (CeleryExecutor) | -  |
| airflow-triggerer | Async task triggers          | -     |
| postgres          | Metadata database            | 5432  |
| redis             | Celery message broker        | 6379  |
| flower            | Celery monitoring (optional) | 5555  |

## Resource Allocation

Approximate resource usage per service:

| Service   | Memory  | CPU   |
| --------- | ------- | ----- |
| Webserver | 500MB   | 0.5   |
| Scheduler | 500MB   | 0.5   |
| Worker    | 1GB+    | 1.0   |
| Triggerer | 256MB   | 0.25  |
| Postgres  | 256MB   | 0.25  |
| Redis     | 128MB   | 0.1   |

**Total minimum**: ~3GB RAM, 2.5 CPU cores
