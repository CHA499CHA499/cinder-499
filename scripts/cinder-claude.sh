#!/bin/bash
# cinder-claude.sh — 从仓根 .env 启动 Claude Code
#
# 用法：
#   ./scripts/cinder-claude.sh
#   ./scripts/cinder-claude.sh --print "say hi"
#
# 作用：让使用三方 Anthropic 兼容 API 的用户不用手动 source .env。

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "⚠️  未找到 .env，请先运行 ./scripts/bootstrap-cinder.sh 或复制 skeleton/.env.example" >&2
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ 找不到 claude CLI，请先安装：npm i -g @anthropic-ai/claude-code" >&2
  exit 1
fi

cd "$REPO_ROOT"

has_model_arg=0
for arg in "$@"; do
  if [ "$arg" = "--model" ] || [ "$arg" = "-m" ] || [[ "$arg" == --model=* ]]; then
    has_model_arg=1
    break
  fi
done

if [ -n "$DEFAULT_MODEL" ] && [ "$has_model_arg" -eq 0 ]; then
  exec claude --model "$DEFAULT_MODEL" "$@"
fi

exec claude "$@"
