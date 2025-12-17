# Docker Compose Templates

Reusable docker-compose templates for common development services.

## Usage

Copy the desired template to your project and customize as needed:

```bash
cp templates/docker-compose/postgres.yml ./docker-compose.yml
```

Or include multiple services by merging templates.

## Available Templates

| Template | Description |
|----------|-------------|
| `ngrok.yml` | ngrok tunnel for exposing local services |
| `postgres.yml` | PostgreSQL database with persistent storage |
| `mongodb-cluster.yml` | MongoDB replica set cluster |
| `redis.yml` | Redis cache server |

## Environment Variables

Most templates use environment variables for configuration. Create a `.env` file in your project:

```bash
# Example .env
POSTGRES_USER=myapp
POSTGRES_PASSWORD=secret
POSTGRES_DB=myapp_dev
```
