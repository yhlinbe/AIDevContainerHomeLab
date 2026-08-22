# Community Platform - Full Stack & AI DevEnv

An enterprise-grade, microservice-ready cloud-native development environment. Powered by **VS Code Devcontainers**, **Docker Compose**, and **OpenTelemetry Observability**, this repository provides a seamless experience for developing modern TypeScript (React/NestJS) and Golang applications alongside AI coding assistants.

# 編輯 ~/.zshrc 或 ~/.bashrc

export GEMINI_API_KEY="AIzaSy..."
export OPENAI_API_KEY="sk-proj-..."
export DEEPSEEK_API_KEY="sk-..." # 用於 OpenCode / DeepSeek
export ANTHROPIC_API_KEY="sk-ant-..." # 用於 Claude Code CLI
export DASHSCOPE_API_KEY="sk-..." # 用於通義千問 (DashScope)

---

## 🏗 Architecture Overview

```
                          ┌────────────────────────────────────────────────────────┐
                          │               VS Code Devcontainer Environment         │
                          │                                                        │
┌──────────────────┐      │   ┌────────────────┐  ┌───────────────┐  ┌──────────┐  │
│   Host Machine   │ ────►│   │  React Frontend│  │ NestJS API    │  │ Go Worker│  │
│                  │      │   │   (Port 5173)  │  │  (Port 3000)  │  │ (Port 8080) │
└──────────────────┘      │   └────────────────┘  └───────────────┘  └──────────┘  │
                          │   ┌────────────────────────────────────────────────┐   │
                          │   │   AI Coding Agents (Claude Code / OpenCode)    │   │
                          │   └────────────────────────────────────────────────┘   │
                          └────────────────────────────────────────────────────────┘
                                                       │
                                                       ▼
                          ┌────────────────────────────────────────────────────────┐
                          │               Docker Compose Services                  │
                          │                                                        │
                          │  [ Postgres HA ]      [ Valkey Cache ]  [ Kafka MQ ]   │
                          │   Patroni + HAProxy      (Port 6379)     (Port 9092)   │
                          │                                                        │
                          │  [ Casdoor IAM ]      [ SeaweedFS S3 ]                 │
                          │   (Port 8000)            (Port 8333)                   │
                          │                                                        │
                          │  [ Observability (O11y) Stack ]                        │
                          │   Otel Collector (4317) -> ClickHouse -> Grafana(3001) │
                          └────────────────────────────────────────────────────────┘

```

---

## 🚀 Quick Start

For the complete Dev Container startup, service, shutdown, and troubleshooting instructions, see [HOWTO-STARTUP.md](HOWTO-STARTUP.md).

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`) installed.

### Environment Setup

1. Clone the repository to your local machine:

```bash
git clone https://github.com/your-org/community-platform.git
cd community-platform

```

2. _(Optional)_ Set your AI API keys on your host environment:

```bash
export ANTHROPIC_API_KEY="your-anthropic-key"
export OPENAI_API_KEY="your-openai-key"

```

3. Open the project folder in VS Code:

```bash
code .

```

4. When prompted by VS Code with **"Reopen in Container"**, click it.
   _(Or press `F1`, type `Dev Containers: Reopen in Container`)_.

---

## 🔌 Service Port Map

| Service Name          | Container Port | Local/Forwarded Port    | Description                                 |
| --------------------- | -------------- | ----------------------- | ------------------------------------------- |
| **React Frontend**    | `5173`         | `http://localhost:5173` | Vite Hot Reload Frontend                    |
| **NestJS API**        | `3000`         | `http://localhost:3000` | Core Backend REST API                       |
| **Grafana O11y**      | `3000`         | `http://localhost:3001` | Telemetry & APM Dashboard (`admin`/`admin`) |
| **Casdoor IAM**       | `8000`         | `http://localhost:8000` | Identity & Access Management                |
| **Go Microservice**   | `8080`         | `http://localhost:8080` | High-performance Go Background Worker       |
| **PostgreSQL HA**     | `5432`         | `localhost:5432`        | HAProxy entrypoint to Patroni Cluster       |
| **HAProxy Dashboard** | `7000`         | `http://localhost:7000` | Postgres Cluster Load Balancer Stats        |
| **Valkey Cache**      | `6379`         | `localhost:6379`        | High-performance Redis-compatible Cache     |
| **ClickHouse HTTP**   | `8123`         | `http://localhost:8123` | Columnar Analytical Database for O11y       |
| **SeaweedFS S3**      | `8333`         | `http://localhost:8333` | S3-Compatible Object Storage Endpoint       |
| **Kafka Broker**      | `9092`         | `localhost:9092`        | Event-driven Messaging Queue (KRaft Mode)   |
| **Otel Collector**    | `4317`         | `localhost:4317`        | OpenTelemetry gRPC Ingestion Port           |

---

## 🛠 Concurrent Multi-Terminal Workflow

Inside the Devcontainer, all background infrastructure runs automatically. You can split your VS Code integrated terminals to run your active development servers and AI CLI tools side by side:

- **Terminal 1 (Frontend)**:

```bash
cd frontend && npm run dev

```

- **Terminal 2 (NestJS API)**:

```bash
cd backend-nest && npm run start:dev

```

- **Terminal 3 (Go Worker)**:

```bash
cd backend-go && air

```

- **Terminal 4 (AI Assistants)**:

```bash
claude
# or
opencode

```

---

## 📊 Observability & APM (O11y)

The environment includes a pre-configured OpenTelemetry stack:

1. Applications send telemetry data via **OTLP (gRPC)** to `localhost:4317`.
2. **OpenTelemetry Collector** batches and streams metrics, logs, and traces into **ClickHouse**.
3. **Grafana** (`http://localhost:3001`) automatically provisions ClickHouse as its primary data source with two pre-built dashboards:

- **`OTEL - Application APM & Traces`**: Real-time RPS, P95 Latency, and Slow Trace Inspector.
- **`OTEL - Realtime Logs Explorer`**: Aggregated log feed with severity distribution.

---

## 📂 Project Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json         # Devcontainer specs, extensions & environment
│   ├── docker-compose.dev.yml    # Infrastructure containers (DBs, Kafka, O11y)
│   └── scripts/
│       ├── init-host.sh          # Host initialization hook
│       └── post-create.sh        # Dependency installation inside container
├── frontend/                     # React + Vite Application
├── backend-nest/                 # NestJS REST API Microservice
├── backend-go/                   # Golang Processing Worker
└── README.md                     # Project Documentation

```
