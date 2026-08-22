# How to Start the Project with the Dev Container

This repository provides the development environment and background infrastructure for a React/Vite, NestJS, and Go project. The application directories are optional in the current checkout, so the Dev Container and infrastructure can be started independently.

## Prerequisites

Install and start:

- Docker Desktop or Docker Engine with Compose v2
- VS Code
- The VS Code Dev Containers extension (`ms-vscode-remote.remote-containers`)
- Git

For AI tools, export only the keys you use in the host shell before opening the container:

```bash
export GEMINI_API_KEY="..."
export OPENAI_API_KEY="..."
export DEEPSEEK_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export DASHSCOPE_API_KEY="..."
```

Do not commit real API keys or passwords to the repository.

## First Startup

1. Clone the repository and open it in VS Code:

   ```bash
   git clone <repository-url>
   cd AIDevContainerHomeLab
   code .
   ```

2. Run `Dev Containers: Reopen in Container` from the VS Code Command Palette.

3. Wait for the image and features to finish installing. The Dev Container configuration installs Node.js 20, Go 1.22, and Docker-outside-of-Docker.

4. During startup, VS Code runs:

   - `.devcontainer/scripts/init-host.sh`: creates the local HAProxy configuration and starts the infrastructure Compose project.
   - `.devcontainer/scripts/post-create.sh`: installs Go/AI CLI tools and runs `npm install` only when `backend-nest` or `frontend` exists.

5. Open a terminal inside the container and check the infrastructure:

   ```bash
   docker compose --env-file .devcontainer/.env \
     -f .devcontainer/docker-compose.dev.yml ps
   ```

   Services may take a short time to become healthy on the first run.

## Run Two Projects on One Computer

Open each project in its own VS Code window and Dev Container. Docker Compose keeps containers and named volumes separate when each project has a unique `COMPOSE_PROJECT_NAME`, but host ports must also be unique.

Keep the defaults for Project A. For Project B, edit `.devcontainer/.env` before reopening its Dev Container:

```dotenv
COMPOSE_PROJECT_NAME=community-platform-b
HOST_PG_PORT=5433
HOST_VALKEY_PORT=6380
HOST_GRAFANA_PORT=3002
HOST_CLICKHOUSE_PORT=8124
HOST_CASDOOR_PORT=8001
HOST_KAFKA_PORT=9093
HOST_SEAWEED_PORT=8334
HOST_HAPROXY_STATS_PORT=7001
HOST_OTEL_GRPC_PORT=4319
HOST_OTEL_HTTP_PORT=4320
```

Project B then uses these host URLs:

| Service | Project A | Project B |
| --- | --- | --- |
| Grafana | `http://localhost:3001` | `http://localhost:3002` |
| Casdoor | `http://localhost:8000` | `http://localhost:8001` |
| PostgreSQL | `localhost:5432` | `localhost:5433` |
| Valkey | `localhost:6379` | `localhost:6380` |
| ClickHouse | `http://localhost:8123` | `http://localhost:8124` |
| Kafka | `localhost:9092` | `localhost:9093` |
| SeaweedFS S3 | `http://localhost:8333` | `http://localhost:8334` |
| HAProxy status | `http://localhost:7000` | `http://localhost:7001` |
| OTLP gRPC | `localhost:4317` | `localhost:4319` |

Start Project B normally after changing `.env`:

```bash
sh .devcontainer/scripts/init-host.sh
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.dev.yml ps
```

The application ports (`5173`, `3000`, and `8080`) are forwarded by VS Code from each Dev Container. If VS Code detects a collision, open the Ports panel and use the automatically assigned local port, or configure the second project's application servers to use `5174`, `3002`, and `8081` and update its `devcontainer.json` forwarding list.

Do not reuse the same `COMPOSE_PROJECT_NAME` between projects. Reusing it can make `docker compose down` from one project affect the other project's containers and volumes.

## Start Application Services

Start each application only when its directory exists.

### React/Vite frontend

```bash
cd frontend
npm run dev -- --host 0.0.0.0
```

Open <http://localhost:5173>.

### NestJS API

```bash
cd backend-nest
npm run start:dev
```

Open <http://localhost:3000> or call the API endpoint provided by the application.

### Go worker or service

```bash
cd backend-go
air
```

The Dev Container forwards port `8080` for the Go service. If the project does not include an `air` configuration, use the project’s documented Go command instead, such as `go run .`.

## Useful Service URLs

| Service | URL | Default credentials |
| --- | --- | --- |
| React/Vite | <http://localhost:5173> | None |
| NestJS API | <http://localhost:3000> | Application-specific |
| Grafana | <http://localhost:3001> | `admin` / `admin` |
| Casdoor | <http://localhost:8000> | Application-specific |
| HAProxy status | <http://localhost:7000> | None |
| ClickHouse HTTP API | <http://localhost:8123> | `default` |
| SeaweedFS S3 API | <http://localhost:8333> | Application-specific |

Other forwarded ports include PostgreSQL/HAProxy `5432`, Valkey `6379`, Kafka `9092`, and OpenTelemetry OTLP gRPC `4317`.

## Stop and Restart

Stop the infrastructure while keeping its named volumes:

```bash
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.dev.yml down
```

Start it again:

```bash
sh .devcontainer/scripts/init-host.sh
```

To remove containers and development data, use this destructive command only when a clean reset is intended:

```bash
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.dev.yml down -v
```

## Troubleshooting

### A port is already in use

Edit the corresponding `HOST_*_PORT` value in `.devcontainer/.env`, then run the `down` and startup commands again. Update the URL or forwarded-port expectation accordingly.

### Infrastructure is still starting

Inspect the logs:

```bash
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.dev.yml logs -f --tail=100
```

Check one service directly:

```bash
docker compose --env-file .devcontainer/.env \
  -f .devcontainer/docker-compose.dev.yml ps <service-name>
```

### Dependencies were not installed

The post-create script skips missing application directories. After adding a project, run its dependency installation manually:

```bash
(cd backend-nest && npm install)
(cd frontend && npm install)
```

Then run `Dev Containers: Rebuild Container` if the global tools or container features need to be reinstalled.

### Reopen the project outside the container

Use the Command Palette command `Dev Containers: Reopen Folder Locally`. The host must still have Docker running if you want to manage the Compose infrastructure.

## Daily Startup Checklist

1. Start Docker.
2. Open the repository in VS Code.
3. Reopen in the Dev Container if it is not already active.
4. Confirm Compose services with `docker compose ... ps`.
5. Start the frontend, NestJS API, and Go service in separate terminals when those directories are present.
6. Open the forwarded URLs listed above.
