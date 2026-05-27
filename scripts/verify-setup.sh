#!/bin/bash
# verify-setup.sh — Cinder Starter 环境自检
#
# 用法：
#   ./scripts/verify-setup.sh          # 静态检查（不联网、不消耗 API）
#   ./scripts/verify-setup.sh --probe  # 末尾额外做一次真实 API 连通性测试（消耗极少 token）
#
# 退出码：全部通过 = 0；有 ❌ 失败项 = 1。⚠️ 警告不影响退出码。
#
# 注意：本脚本故意不用 set -e —— 要把所有检查项跑完再汇总，而不是一遇错就退。

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"
PROBE=0
[ "$1" = "--probe" ] && PROBE=1

fail=0
warn=0
ok()   { echo "  ✅ $1"; }
bad()  { echo "  ❌ $1"; fail=$((fail + 1)); }
note() { echo "  ⚠️  $1"; warn=$((warn + 1)); }

echo "==> Cinder 环境自检"
echo "    仓根: $REPO_ROOT"
echo

# --- 1. Claude Code CLI ---
echo "[1] Claude Code CLI"
if command -v claude >/dev/null 2>&1; then
  ok "claude 已安装（$(command -v claude)）"
else
  bad "找不到 claude，安装：npm i -g @anthropic-ai/claude-code"
fi

# --- 2. .env 配置 ---
echo "[2] .env 配置"
if [ -f "$ENV_FILE" ]; then
  ok ".env 存在"
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
  if [ -n "$ANTHROPIC_BASE_URL" ]; then
    ok "ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
  else
    bad "ANTHROPIC_BASE_URL 未填"
  fi
  case "$ANTHROPIC_AUTH_TOKEN$ANTHROPIC_API_KEY" in
    "")          bad "ANTHROPIC_AUTH_TOKEN / ANTHROPIC_API_KEY 都没填" ;;
    *REPLACE_ME*) bad "API token 还是占位值（REPLACE_ME），请填真实 token" ;;
    *)           ok "API token 已填（值已隐藏）" ;;
  esac
  if [ -n "$DEFAULT_MODEL" ]; then
    ok "DEFAULT_MODEL=$DEFAULT_MODEL"
  else
    note "DEFAULT_MODEL 未填，启动时需手动 --model"
  fi
else
  bad ".env 不存在：先跑 ./scripts/bootstrap-cinder.sh，或 cp skeleton/.env.example .env"
fi

# --- 3. gateway 三件套 ---
echo "[3] gateway 三件套"
for f in gateway-stable.md gateway.md gateway-delta.md; do
  if [ -f "$REPO_ROOT/brain/$f" ]; then
    ok "brain/$f"
  else
    note "brain/$f 缺失（跑 bootstrap 初始化）"
  fi
done

# --- 4. A1 归档目录 ---
echo "[4] A1 归档目录"
if [ -d "$REPO_ROOT/brain/insights/promoted" ]; then
  ok "brain/insights/{promoted,hold,discarded}/ 就绪"
else
  note "brain/insights/ 子目录缺失（装 A1 时会自动建）"
fi

# --- 5. uv（A1 可选依赖）---
echo "[5] uv（A1 自动评分用，可选）"
if command -v uv >/dev/null 2>&1; then
  ok "uv 已安装"
else
  note "未装 uv；不用 A1 可忽略，要用则：curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# --- 6. API 连通性测试（仅 --probe）---
if [ "$PROBE" -eq 1 ]; then
  echo "[6] API 连通性测试（--probe）"
  if command -v claude >/dev/null 2>&1; then
    model_arg=""
    [ -n "$DEFAULT_MODEL" ] && model_arg="--model $DEFAULT_MODEL"
    # shellcheck disable=SC2086
    if out=$(claude --print $model_arg "只回复 ok 两个字" 2>&1); then
      ok "API 可达，返回：$(echo "$out" | head -1)"
    else
      bad "API 调用失败：$(echo "$out" | head -2 | tr '\n' ' ')"
    fi
  else
    bad "claude 未安装，跳过连通性测试"
  fi
fi

echo
echo "==> 结果：$fail 个失败 / $warn 个警告"
if [ "$fail" -gt 0 ]; then
  echo "   ❌ 有阻塞项，按上面提示修复后重跑"
  exit 1
else
  echo "   ✅ 可以启动：./scripts/cinder-claude.sh"
fi
