#!/bin/bash
# install-curator-insights.sh — 一键安装 A1 自动评分系统
#
# 执行：在 cinder-499 仓根跑 ./scripts/install-curator-insights.sh
# 行为：
#   1. 检查 uv / claude CLI 是否就位（不主动装，只给提示）
#   2. 复制 templates/curator-insights/ 到 axon/curator-insights/
#   3. uv sync 拉起 .venv
#   4. 跑一次 --batch --dry-run --limit 3 验证
#   5. 提示用户接 instinct-counter.sh hook（可选）

set -e

# 仓根：脚本位置上一级
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/templates/curator-insights"
TARGET_DIR="$REPO_ROOT/axon/curator-insights"

echo "==> Cinder A1 自动评分系统安装"
echo "    仓根: $REPO_ROOT"
echo

# ============================================================
# 步骤 1: 前置检查
# ============================================================
echo "[1/5] 检查依赖..."

# uv
if ! command -v uv &>/dev/null; then
  echo "  ❌ uv 未安装"
  echo "     安装命令（macOS / Linux）："
  echo "       curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "     装完重新跑本脚本"
  exit 1
fi
echo "  ✅ uv: $(uv --version)"

# claude CLI
if ! command -v claude &>/dev/null; then
  echo "  ❌ claude CLI 未安装"
  echo "     安装命令: npm i -g @anthropic-ai/claude-code"
  echo "     装完后跑 'claude' 完成登录或配置三方 API（详见 docs/03-third-party-api.md）"
  exit 1
fi
echo "  ✅ claude: $(claude --version 2>&1 | head -1)"

# Python 3.13+
PY_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "  ℹ️  python3: $PY_VERSION（uv 会按 pyproject.toml 自动装 3.13+ 如果系统没有）"

# ============================================================
# 步骤 2: 检查 templates 是否存在
# ============================================================
echo
echo "[2/5] 检查 templates 源..."
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "  ❌ 找不到 $TEMPLATE_DIR"
  echo "     请确认你在 cinder-499 仓根，且 templates/curator-insights/ 存在"
  exit 1
fi
echo "  ✅ templates 完整"

# ============================================================
# 步骤 3: 复制到 axon/
# ============================================================
echo
echo "[3/5] 安装到 axon/curator-insights/..."

if [ -d "$TARGET_DIR" ]; then
  echo "  ⚠️  axon/curator-insights/ 已存在"
  read -p "     覆盖？[y/N] " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "     取消安装"
    exit 0
  fi
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$(dirname "$TARGET_DIR")"
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"
echo "  ✅ 已复制到 $TARGET_DIR"

# ============================================================
# 步骤 4: uv sync
# ============================================================
echo
echo "[4/5] 初始化 Python 虚拟环境（uv sync）..."
cd "$TARGET_DIR"
if uv sync 2>&1 | tail -5; then
  echo "  ✅ .venv 就绪"
else
  echo "  ⚠️  uv sync 可能有 warning，但 .venv 应已建立"
fi

# ============================================================
# 步骤 5: 验证（可选 dry-run）
# ============================================================
echo
echo "[5/5] 验证..."

INSIGHTS_DIR="$REPO_ROOT/brain/insights"
if [ -d "$INSIGHTS_DIR" ] && ls "$INSIGHTS_DIR"/consolidate-*.md &>/dev/null; then
  echo "  发现 consolidate 文件，跑 dry-run..."
  cd "$REPO_ROOT"
  uv run --directory "$TARGET_DIR" score_consolidate.py --batch --dry-run --limit 3 || \
    echo "  ⚠️  dry-run 失败，可能是 claude CLI 未登录。跑 'claude' 登录后再试"
else
  echo "  ℹ️  brain/insights/ 暂无 consolidate-*.md，跳过实测"
  echo "     未来 brain-curator sub-agent 写出 consolidate 时会自动触发"
fi

# ============================================================
# 完成
# ============================================================
echo
echo "✅ A1 安装完成"
echo
echo "下一步（可选）："
echo "  • 接入 PostToolUse hook 让 A1 自动驱动："
echo "    1. cp skeleton/axon/hooks/instinct-counter.sh.example axon/hooks/instinct-counter.sh"
echo "    2. chmod +x axon/hooks/instinct-counter.sh"
echo "    3. 在 ~/.claude/settings.local.json 的 hooks.PostToolUse 加一条"
echo "       command: $REPO_ROOT/axon/hooks/instinct-counter.sh"
echo "    4. 重启 Claude Code 会话"
echo
echo "  • 手动批量评分已有 insights："
echo "    uv run --directory axon/curator-insights score_consolidate.py --batch"
echo
echo "  • 完整文档：docs/06-curator-insights.md + axon/curator-insights/README.md"
