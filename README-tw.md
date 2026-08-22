# 社區平台 - 全棧與 AI 開發環境 (Community Platform DevEnv)

本專案提供企業級、支援微服務架構且雲原生導向的開發環境。基於 **VS Code Devcontainers**、**Docker Compose** 與 **OpenTelemetry 觀測性（O11y）生態系**，為 TypeScript (React/NestJS)、Golang 開發者以及 AI 寫碼助手（Claude Code、OpenCode）提供全自動化、即時熱重載的開箱即用體驗。

---

## 🏗 架構與職責劃分

```
                          ┌────────────────────────────────────────────────────────┐
                          │               VS Code Devcontainer 開發主體            │
                          │                                                        │
┌──────────────────┐      │   ┌────────────────┐  ┌───────────────┐  ┌──────────┐  │
│    宿主機本機    │ ────►│   │  React 前端    │  │ NestJS API    │  │ Go Worker│  │
│  (Host Machine)  │      │   │   (Port 5173)  │  │  (Port 3000)  │  │ (Port 8080) │
└──────────────────┘      │   └────────────────┘  └───────────────┘  └──────────┘  │
                          │   ┌────────────────────────────────────────────────┐   │
                          │   │   AI 輔助工具 (Claude Code / OpenCode / Continue)   │   │
                          │   └────────────────────────────────────────────────┘   │
                          └────────────────────────────────────────────────────────┘
                                                       │
                                                       ▼
                          ┌────────────────────────────────────────────────────────┐
                          │            Docker Compose 背景基礎設施服務             │
                          │                                                        │
                          │  [ Postgres 高可用 ]   [ Valkey 快取 ]  [ Kafka 消息佇列 ]│
                          │   Patroni + HAProxy      (Port 6379)     (Port 9092)   │
                          │                                                        │
                          │  [ Casdoor 身份認證 ]  [ SeaweedFS S3 ]                 │
                          │   (Port 8000)            (Port 8333)                   │
                          │                                                        │
                          │  [ 觀測性 (O11y) 全家桶 ]                              │
                          │   Otel Collector (4317) -> ClickHouse -> Grafana(3001) │
                          └────────────────────────────────────────────────────────┘

```

---

## 🚀 快速開始

### 前置需求

* 安裝並啟動 [Docker Desktop](https://www.docker.com/products/docker-desktop/)。
* 安裝 [VS Code](https://code.visualstudio.com/) 及其官方擴充套件 **Dev Containers** (`ms-vscode-remote.remote-containers`)。

### 環境啟動步驟

1. 複製本專案至本地：
```bash
git clone https://github.com/your-org/community-platform.git
cd community-platform

```


2. *(可選)* 在宿主機環境變數中設定 AI API 金鑰，容器啟動時將自動帶入：
```bash
export ANTHROPIC_API_KEY="your-anthropic-key"
export OPENAI_API_KEY="your-openai-key"

```


3. 使用 VS Code 打開專案資料夾：
```bash
code .

```


4. 當 VS Code 右下角跳出提示時，點擊 **"Reopen in Container"**（或按下 `F1` 輸入 `Dev Containers: Reopen in Container`）。
* `initializeCommand` 會自動啟動背景 Docker Compose 基礎設施。
* `postCreateCommand` 會自動完成 Go 工具與 Node 模組的安裝。



---

## 🔌 服務 Port 映射與存取對照表

| 服務名稱 | 容器內 Port | 本地轉發 Port / 網址 | 說明與用途 |
| --- | --- | --- | --- |
| **React 前端** | `5173` | `http://localhost:5173` | Vite 預覽與熱重載前端環境 |
| **NestJS API** | `3000` | `http://localhost:3000` | 核心 REST API 與微服務 |
| **Grafana O11y** | `3000` | `http://localhost:3001` | 遙測與 APM 視覺化儀表板 (帳密：`admin`/`admin`) |
| **Casdoor IAM** | `8000` | `http://localhost:8000` | 身份驗證與權限管理系統 |
| **Go 微服務** | `8080` | `http://localhost:8080` | 高效能背景處理 Worker (搭配 `air` 熱重載) |
| **PostgreSQL HA** | `5432` | `localhost:5432` | HAProxy 對外入口 (後端為 Patroni 高可用叢集) |
| **HAProxy 儀表板** | `7000` | `http://localhost:7000` | 資料庫負載平衡器監控狀態 |
| **Valkey 快取** | `6379` | `localhost:6379` | 高效能 Redis 相容快取服務 |
| **ClickHouse HTTP** | `8123` | `http://localhost:8123` | O11y 遙測資料專用欄位式分析資料庫 |
| **SeaweedFS S3** | `8333` | `http://localhost:8333` | 相容 S3 協議的高效能物件儲存 API |
| **Kafka Broker** | `9092` | `localhost:9092` | 事件驅動消息佇列 (KRaft 模式) |
| **Otel Collector** | `4317` | `localhost:4317` | OpenTelemetry gRPC 數據接收端 |

---

## 🛠 多視窗開發工作流 (Multi-Terminal Layout)

進 Devcontainer 後，所有背景資料庫與基礎設施已經自動運行。您可以直接在 VS Code 開啟多個 Terminal 分割視窗進行開發與 AI 協作：

* **視窗 1 (前端開發)**:
```bash
cd frontend && npm run dev

```


* **視窗 2 (NestJS 後端)**:
```bash
cd backend-nest && npm run start:dev

```


* **視窗 3 (Golang Worker)**:
```bash
cd backend-go && air

```


* **視窗 4 (AI 工具與 Agent 視窗)**:
```bash
claude
# 或使用 opencode

```



---

## 📊 觀測性與 APM 機制 (Observability Stack)

本環境內建完整的 OpenTelemetry 觀測鏈：

1. **資料收集**：應用程式（NestJS / Go）透過 OTLP (gRPC) 將 Trace 和 Log 推送至 `localhost:4317`。
2. **儲存與批處理**：**OpenTelemetry Collector** 接收數據後批次寫入 **ClickHouse** (`otel_db`)。
3. **視覺化與分析**：打開 **Grafana** (`http://localhost:3001`)，系統已預設配置好 Data Source，並預載入二個實用 Dashboard：
* **`OTEL - Application APM & Traces`**：即時分析 RPS、P95 延遲變化曲線與慢 Trace 檢視。
* **`OTEL - Realtime Logs Explorer`**：跨服務 Log 聚合分析與等級分佈圖。



---

## 📂 專案結構說明

```
.
├── .devcontainer/
│   ├── devcontainer.json         # Devcontainer 核心設定、擴充套件與環境變數
│   ├── docker-compose.dev.yml    # 背景基礎設施服務 (DB, Valkey, Kafka, O11y)
│   └── scripts/
│       ├── init-host.sh          # 宿主機啟動前置自動化腳本
│       └── post-create.sh        # 容器建立後的工具與依賴安裝腳本
├── frontend/                     # React + Vite 前端專案
├── backend-nest/                 # NestJS 後端 REST API 專案
├── backend-go/                   # Golang 微服務 Worker 專案
└── README.md                     # 本開發環境說明文件

```