#!/bin/bash
set -e

echo "🚀 Initializing AI Team Environment and Document Tracking..."

# 1. 建立文檔目錄結構
mkdir -p .ai/docs/discussions
mkdir -p .ai/docs/conclusions
mkdir -p .ai/docs/feedback

# 2. 確保 user-feedback.md 存在
if [ ! -f .ai/docs/feedback/user-feedback.md ]; then
  cat <<'EOF' > .ai/docs/feedback/user-feedback.md
# User Feedback Log

| 日期 | 提出者 | 反饋類型 | 處理狀態 | 關聯文檔 | 反饋摘要 |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF
fi

# 3. 設定 Bash Alias 方便快速召喚 AI CLI
echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc
echo 'alias opencode="opencode --config .ai/SYSTEM_INSTRUCTIONS.md"' >> ~/.bashrc

echo "✅ AI Skills & Workflow setup complete!"

set -eo pipefail

echo "=================================================="
echo "🚀 Starting DevContainer Post-Create Setup"
echo "=================================================="

# 1. 安裝 全局 Go 工具與 AI CLI 套件 (Claude Code & OpenCode)
install_global_tools() {
    echo "📦 [1/3] Installing global CLI tools & AI engines..."
    go install github.com/air-verse/air@latest
    
    # 安裝 AI 開發 CLI 工具
    npm install -g @anthropic-ai/claude-code opencode
    
    echo "✅ Global CLI tools and AI engines installed."
}

# 2. 安裝 後端 NestJS 依賴
install_backend() {
    if [ -d "backend-nest" ]; then
        echo "📦 [2/3] Installing backend-nest dependencies..."
        (cd backend-nest && npm install)
        echo "✅ backend-nest dependencies installed."
    else
        echo "⏩ Skipping backend-nest (directory not found)."
    fi
}

# 3. 安裝 前端 Frontend 依賴
install_frontend() {
    if [ -d "frontend" ]; then
        echo "📦 [3/3] Installing frontend dependencies..."
        (cd frontend && npm install)
        echo "✅ frontend dependencies installed."
    else
        echo "⏩ Skipping frontend (directory not found)."
    fi
}

# 執行安裝流程
install_global_tools

# 前後端依賴平行安裝
install_backend &
pid_backend=$!

install_frontend &
pid_frontend=$!

wait $pid_backend $pid_frontend

echo "=================================================="
echo "🎉 DevContainer Setup Completed Successfully!"
echo "=================================================="