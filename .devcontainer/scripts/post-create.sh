#!/bin/bash
set -eo pipefail

echo "=================================================="
echo "🚀 Starting DevContainer Post-Create Setup"
echo "=================================================="

# 1. 建立 OpenCode 全局多 Provider 設定 (金鑰一律吃環境變數，絕不寫死)
setup_opencode_config() {
    echo "⚙️ Configuring OpenCode multi-provider config..."
    mkdir -p ~/.config/opencode

    cat <<'EOF' > ~/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-3-7-sonnet",
  "smallModel": "google/gemini-2.5-flash",
  "providers": {
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    },
    "openai": {
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      }
    },
    "google": {
      "options": {
        "apiKey": "{env:GEMINI_API_KEY}"
      }
    },
    "openrouter": {
      "options": {
        "apiKey": "{env:OPENROUTER_API_KEY}"
      }
    }
  }
}
EOF
}

# 2. 建立 AI 團隊文檔目錄與初始化檔案 + 自動鏈結專案系統指令
setup_ai_docs() {
    echo "📁 Initializing AI Team Documentation Directories..."
    mkdir -p .ai/docs/discussions .ai/docs/conclusions .ai/docs/feedback

    if [ ! -f .ai/docs/feedback/user-feedback.md ]; then
        cat <<'EOF' > .ai/docs/feedback/user-feedback.md
# User Feedback Log

| 日期 | 提出者 | 反饋類型 | 處理狀態 | 關聯文檔 | 反饋摘要 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF
    fi

    # 讓 OpenCode 自動吃專案內的系統指令規範
    if [ -f .ai/SYSTEM_INSTRUCTIONS.md ]; then
        ln -sf .ai/SYSTEM_INSTRUCTIONS.md OPENCODE.md
    fi

    # 寫入 PATH 與常用 Alias
    {
        echo 'export PATH="$(npm config get prefix)/bin:$PATH"'
        echo 'alias claude="claude --dangerously-skip-permissions"'
        echo 'alias opencode="opencode"'
    } >> ~/.bashrc
}

# 3. 安裝 全局 CLI 工具與 AI Engines
install_global_tools() {
    echo "📦 [1/3] Installing global CLI tools & AI engines..."
    go install github.com/air-verse/air@latest || true
    
    npm install -g @anthropic-ai/claude-code opencode-ai
    
    echo "✅ Global CLI tools and AI engines installed."
}

# 4. 安裝 後端 NestJS 依賴
install_backend() {
    if [ -d "backend/nestjs" ]; then
        echo "📦 [2/3] Installing NestJS dependencies..."
        (cd backend/nestjs && npm install)
        echo "✅ NestJS dependencies installed."
    elif [ -d "backend-nest" ]; then
        echo "📦 [2/3] Installing backend-nest dependencies..."
        (cd backend-nest && npm install)
        echo "✅ backend-nest dependencies installed."
    else
        echo "⏩ Skipping backend dependencies (directory not found)."
    fi
}

# 5. 安裝 前端 Frontend 依賴
install_frontend() {
    if [ -d "frontend/react" ]; then
        echo "📦 [3/3] Installing React dependencies..."
        (cd frontend/react && npm install)
        echo "✅ React dependencies installed."
    elif [ -d "frontend" ]; then
        echo "📦 [3/3] Installing frontend dependencies..."
        (cd frontend && npm install)
        echo "✅ Frontend dependencies installed."
    else
        echo "⏩ Skipping frontend dependencies (directory not found)."
    fi
}

# 6. 生成 VS Code 多分頁 Terminal Tasks
generate_vscode_tasks() {
    echo "⚙️ Generating .vscode/tasks.json..."
    mkdir -p .vscode

    cat <<'EOF' > .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "🚀 Open Dev Workspaces",
      "type": "shell",
      "command": "echo 'Workspaces Initialized!'",
      "runOptions": {
        "runOn": "folderOpen"
      },
      "presentation": {
        "reveal": "silent"
      },
      "dependsOn": [
        "Terminal: OpenCode (Multi-Model)",
        "Terminal: Claude Code CLI",
        "Terminal: NestJS Backend",
        "Terminal: Go Service",
        "Terminal: React Frontend",
        "Terminal: Qwen & ChatGPT Workspace",
        "Terminal: Infrastructure Logs"
      ]
    },
    {
      "label": "Terminal: OpenCode (Multi-Model)",
      "type": "shell",
      "command": "echo '=== OpenCode Ready ===' && opencode",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    },
    {
      "label": "Terminal: Claude Code CLI",
      "type": "shell",
      "command": "echo '=== Claude Code CLI Ready ===' && claude --dangerously-skip-permissions",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": true }
    },
    {
      "label": "Terminal: NestJS Backend",
      "type": "shell",
      "command": "echo '=== NestJS App ===' && cd backend/nestjs && npm run start:dev",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    },
    {
      "label": "Terminal: Go Service",
      "type": "shell",
      "command": "echo '=== Go Service ===' && cd backend/golang && go run main.go",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    },
    {
      "label": "Terminal: React Frontend",
      "type": "shell",
      "command": "echo '=== React App ===' && cd frontend/react && npm run dev",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    },
    {
      "label": "Terminal: Qwen & ChatGPT Workspace",
      "type": "shell",
      "command": "echo '=== Qwen & ChatGPT Workspace ==='",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    },
    {
      "label": "Terminal: Infrastructure Logs",
      "type": "shell",
      "command": "docker compose --env-file .devcontainer/.env -f .devcontainer/docker-compose.dev.yml logs -f --tail=50",
      "problemMatcher": [],
      "presentation": { "group": "dev-layout", "focus": false }
    }
  ]
}
EOF
}

# 執行主要工作流程
setup_opencode_config
setup_ai_docs
install_global_tools

# 平行執行依賴套件安裝
install_backend &
pid_backend=$!

install_frontend &
pid_frontend=$!

wait $pid_backend $pid_frontend

# 確保產出 tasks.json
generate_vscode_tasks

echo "=================================================="
echo "🎉 DevContainer Setup Completed Successfully!"
echo "=================================================="

source ~/.bashrc

# 3. 測試指令
claude --version
opencode --version