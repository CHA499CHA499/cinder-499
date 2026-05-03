#!/bin/bash
# install-curator-insights.sh — 一键安装 A1 自动评分系统
#
# 执行：在 cinder-499 仓根跑 ./scripts/install-curator-insights.sh
# 行为：
#   1. 检查 uv / claude CLI 是否就位（不主动装，只给提示）
#   2. 复制 templates/curator-insights/ 到 axon/curator-insights/
#   3. 初始化 brain/insights/{promoted,hold,discarded}/
#   4. uv sync 拉起 .venv
#   5. 跑一次 --batch --dry-run --limit 3 验证
#   6. 可选复制 instinct-counter.sh hook

set -e

# 仓根：脚本位置上一级
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/templates/curator-insights"
TARGET_DIR="$REPO_ROOT/axon/curator-insights"
HOOK_TEMPLATE="$REPO_ROOT/skeleton/axon/hooks/instinct-counter.sh.example"
HOOK_TARGET="$REPO_ROOT/axon/hooks/instinct-counter.sh"
ASSUME_YES=0
WITH_HOOK=0

usage() {
  cat <<'EOF'
用法：
  ./scripts/install-curator-insights.sh [--yes] [--with-hook]

选项：
  --yes       非交互模式：已存在 axon/curator-insights/ 时直接覆盖
  --with-hook 同步安装 axon/hooks/instinct-counter.sh（仍需手动注册到 Claude Code hooks）
  -h, --help  显示帮助
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y)
      ASSUME_YES=1
      ;;
    --with-hook)
      WITH_HOOK=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

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
  echo "     装完后填 .env，并用 ./scripts/cinder-claude.sh 启动（详见 docs/03-third-party-api.md）"
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
  if [ "$ASSUME_YES" -ne 1 ]; then
    read -p "     覆盖？[y/N] " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "     取消安装"
      exit 0
    fi
  fi
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$(dirname "$TARGET_DIR")"
cp -r "$TEMPLATE_DIR" "$TARGET_DIR"
echo "  ✅ 已复制到 $TARGET_DIR"

INSIGHTS_DIR="$REPO_ROOT/brain/insights"
mkdir -p "$INSIGHTS_DIR/promoted" "$INSIGHTS_DIR/hold" "$INSIGHTS_DIR/discarded"
echo "  ✅ insights 归档目录已就绪"

if [ "$WITH_HOOK" -eq 1 ]; then
  mkdir -p "$(dirname "$HOOK_TARGET")"
  if [ -f "$HOOK_TEMPLATE" ]; then
    cp "$HOOK_TEMPLATE" "$HOOK_TARGET"
    chmod +x "$HOOK_TARGET"
    echo "  ✅ 已安装 hook: $HOOK_TARGET"
  else
    echo "  ⚠️  找不到 hook 模板，跳过: $HOOK_TEMPLATE"
  fi
fi

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

if [ -d "$INSIGHTS_DIR" ] && ls "$INSIGHTS_DIR"/consolidate-*.md &>/dev/null; then
  echo "  发现 consolidate 文件，跑 dry-run..."
  cd "$REPO_ROOT"
  uv run --directory "$TARGET_DIR" score_consolidate.py --batch --dry-run --limit 3 || \
    echo "  ⚠️  dry-run 失败，可能是 .env / claude CLI 配置未就绪。填好 .env 后再试"
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
if [ "$WITH_HOOK" -eq 1 ]; then
  echo "    1. 在 ~/.claude/settings.local.json 的 hooks.PostToolUse 加一条"
  echo "       command: $REPO_ROOT/axon/hooks/instinct-counter.sh"
  echo "    2. 重启 Claude Code 会话"
else
  echo "    1. ./scripts/install-curator-insights.sh --with-hook"
  echo "    2. 在 ~/.claude/settings.local.json 的 hooks.PostToolUse 加一条"
  echo "       command: $REPO_ROOT/axon/hooks/instinct-counter.sh"
  echo "    3. 重启 Claude Code 会话"
fi
echo
echo "  • 手动批量评分已有 insights："
echo "    uv run --directory axon/curator-insights score_consolidate.py --batch"
echo
echo "  • 完整文档：docs/06-curator-insights.md + axon/curator-insights/README.md"
