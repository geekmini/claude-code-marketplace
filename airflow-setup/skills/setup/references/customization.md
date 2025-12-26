# Customization Options

## Environment Variables

Add to `.env` file to customize Airflow:

### Core Settings

```bash
# Airflow image version
AIRFLOW_IMAGE_NAME=apache/airflow:2.8.0

# User ID for file permissions
AIRFLOW_UID=50000

# Disable example DAGs
AIRFLOW__CORE__LOAD_EXAMPLES=false

# Set Fernet key for encryption
AIRFLOW__CORE__FERNET_KEY=your-fernet-key

# Webserver secret key
AIRFLOW__WEBSERVER__SECRET_KEY=your-secret-key
```

### Executor Configuration

```bash
# Use LocalExecutor for simpler setup (no Celery)
AIRFLOW__CORE__EXECUTOR=LocalExecutor

# Or keep CeleryExecutor for distributed
AIRFLOW__CORE__EXECUTOR=CeleryExecutor
```

### Database (External)

```bash
# Use external PostgreSQL
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://user:pass@host:5432/airflow
```

## Using LocalExecutor (Simpler Setup)

For local development, you can use LocalExecutor instead of CeleryExecutor:

1. Create `docker-compose.override.yaml`:

```yaml
services:
  airflow-worker:
    profiles:
      - disabled
  redis:
    profiles:
      - disabled
  flower:
    profiles:
      - disabled
```

2. Add to `.env`:
```bash
AIRFLOW__CORE__EXECUTOR=LocalExecutor
```

This reduces resource usage significantly.

## Adding Python Dependencies

### Option 1: Requirements file

Create `requirements.txt` in project root:

```txt
apache-airflow-providers-amazon
apache-airflow-providers-google
pandas
```

Add to `.env`:
```bash
_PIP_ADDITIONAL_REQUIREMENTS="-r /opt/airflow/requirements.txt"
```

### Option 2: Custom Dockerfile

Create `Dockerfile`:

```dockerfile
FROM apache/airflow:2.8.0
USER airflow
RUN pip install --no-cache-dir \
    apache-airflow-providers-amazon \
    pandas
```

Update `docker-compose.override.yaml`:

```yaml
x-airflow-common:
  &airflow-common
  build: .
```

## Volume Mounts

Default mounts in docker-compose.yaml:

| Local Path  | Container Path      |
| ----------- | ------------------- |
| ./dags      | /opt/airflow/dags   |
| ./logs      | /opt/airflow/logs   |
| ./plugins   | /opt/airflow/plugins|
| ./config    | /opt/airflow/config |

### Adding Custom Mounts

In `docker-compose.override.yaml`:

```yaml
x-airflow-common:
  &airflow-common
  volumes:
    - ./data:/opt/airflow/data
    - ./scripts:/opt/airflow/scripts
```

## Port Customization

Change default ports in `docker-compose.override.yaml`:

```yaml
services:
  airflow-webserver:
    ports:
      - "8081:8080"  # Use port 8081 instead
```
