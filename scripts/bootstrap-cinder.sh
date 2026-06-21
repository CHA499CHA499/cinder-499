#!/bin/bash
# bootstrap-cinder.sh — Cinder Starter 统一一键装机
#
# 执行：在刚 clone 的 cinder-499 仓根跑 ./scripts/bootstrap-cinder.sh
# 行为：
#   1. 展开 skeleton/ 到仓根（不覆盖已存在文件）
#   2. 生成 .env（如不存在）
#   3. 把 gateway 三件套 template 初始化为正式文件
#   4. 建好 brain/insights 归档目录
#   5. 写 ~/.cinder/config 里的 CINDER_HOME
#   6. 可选安装 A1 自动评分系统（默认安装；用 --no-a1 跳过）

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKELETON_DIR="$REPO_ROOT/skeleton"
INSTALL_A1=1
WITH_HOOK=1

usage() {
  cat <<'EOF'
用法：
  ./scripts/bootstrap-cinder.sh [--no-a1] [--no-hook]

选项：
  --no-a1    只展开 Cinder 骨架，不安装 A1 自动评分
  --no-hook  安装 A1，但不复制 axon/hooks/instinct-counter.sh
  -h, --help 显示帮助
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --no-a1)
      INSTALL_A1=0
      ;;
    --no-hook)
      WITH_HOOK=0
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

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [ -e "$dst" ]; then
    echo "  跳过：${dst#$REPO_ROOT/} 已存在"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
  echo "  创建：${dst#$REPO_ROOT/}"
}

echo "==> Cinder Starter bootstrap"
echo "    仓根: $REPO_ROOT"
echo

if [ ! -d "$SKELETON_DIR" ]; then
  echo "❌ 找不到 skeleton/，请确认在 cinder-499 仓根执行"
  exit 1
fi

echo "[1/7] 展开 skeleton（不覆盖已有文件）..."
copy_if_missing "$SKELETON_DIR/brain" "$REPO_ROOT/brain"
copy_if_missing "$SKELETON_DIR/axon" "$REPO_ROOT/axon"

echo
echo "[2/7] 初始化 .env..."
copy_if_missing "$SKELETON_DIR/.env.example" "$REPO_ROOT/.env"
chmod +x "$REPO_ROOT/scripts/cinder-claude.sh" 2>/dev/null || true

echo
echo "[3/7] 初始化 gateway 三件套..."
for name in gateway-stable.md gateway.md gateway-delta.md; do
  template="$REPO_ROOT/brain/$name.template"
  target="$REPO_ROOT/brain/$name"
  if [ -f "$template" ]; then
    copy_if_missing "$template" "$target"
  else
    echo "  跳过：brain/$name.template 不存在"
  fi
done

echo
echo "[4/7] 初始化 insights 目录..."
mkdir -p "$REPO_ROOT/brain/insights/promoted" \
  "$REPO_ROOT/brain/insights/hold" \
  "$REPO_ROOT/brain/insights/discarded"
echo "  就绪：brain/insights/{promoted,hold,discarded}/"

echo
echo "[5/7] 写入 ~/.cinder/config..."
mkdir -p "$HOME/.cinder"
if [ -f "$HOME/.cinder/config" ] && grep -q '^CINDER_HOME=' "$HOME/.cinder/config" 2>/dev/null; then
  tmp="$(mktemp)"
  grep -v '^CINDER_HOME=' "$HOME/.cinder/config" > "$tmp" || true
  printf 'CINDER_HOME=%s\n' "$REPO_ROOT" >> "$tmp"
  mv "$tmp" "$HOME/.cinder/config"
else
  printf 'CINDER_HOME=%s\n' "$REPO_ROOT" >> "$HOME/.cinder/config"
fi
echo "  CINDER_HOME=$REPO_ROOT"

echo
echo "[6/7] A1 自动评分系统..."
if [ "$INSTALL_A1" -eq 1 ]; then
  if [ "$WITH_HOOK" -eq 1 ]; then
    "$REPO_ROOT/scripts/install-curator-insights.sh" --yes --with-hook
  else
    "$REPO_ROOT/scripts/install-curator-insights.sh" --yes
  fi
else
  echo "  已按 --no-a1 跳过"
fi

echo
echo "[7/7] 出生仪式 · 随机分配初始昵称..."
IDENTITY_FILE="$REPO_ROOT/brain/self/identity.md"
IDENTITY_TPL="$REPO_ROOT/brain/self/identity.md.template"
AFFECTION_FILE="$REPO_ROOT/brain/self/affection-log.md"
AFFECTION_TPL="$REPO_ROOT/brain/self/affection-log.md.template"
NAME_POOL="$REPO_ROOT/scripts/seeds/names.en.txt"

if [ -f "$IDENTITY_FILE" ]; then
  EXISTING_NICK="$(sed -n 's/^nickname: //p' "$IDENTITY_FILE" | head -1)"
  echo "  跳过：brain/self/identity.md 已存在（沿用既有身份：${EXISTING_NICK:-未知}）"
else
  NICKNAME=""
  SOURCE=""
  # 1. 先试联网（randomuser.me，5s 超时）
  if command -v curl >/dev/null 2>&1; then
    NICKNAME="$(curl -s --max-time 5 'https://randomuser.me/api/?inc=name&nat=us,gb&noinfo' 2>/dev/null \
      | sed -n 's/.*"first":"\([^"]*\)".*/\1/p' | head -1)"
    [ -n "$NICKNAME" ] && SOURCE="online:randomuser.me"
  fi
  # 2. fallback 本地池
  if [ -z "$NICKNAME" ] && [ -f "$NAME_POOL" ]; then
    NICKNAME="$(awk -v seed="$RANDOM$$" 'BEGIN{srand(seed)} /^[A-Za-z]/{a[++n]=$0} END{if(n)print a[int(rand()*n)+1]}' "$NAME_POOL")"
    [ -n "$NICKNAME" ] && SOURCE="local:names.en.txt"
  fi
  # 3. 最后兜底
  if [ -z "$NICKNAME" ]; then
    NICKNAME="Cinder"
    SOURCE="default"
  fi
  TODAY="$(date +%Y-%m-%d)"
  if [ -f "$IDENTITY_TPL" ]; then
    mkdir -p "$(dirname "$IDENTITY_FILE")"
    sed -e "s/__NICKNAME__/$NICKNAME/g" \
        -e "s/__DATE__/$TODAY/g" \
        -e "s|__SOURCE__|$SOURCE|g" \
      "$IDENTITY_TPL" > "$IDENTITY_FILE"
    echo "  分配昵称：$NICKNAME（来源：$SOURCE）"
    echo "  写入：brain/self/identity.md"
  else
    echo "  ⚠ 找不到 identity.md.template，跳过"
  fi
fi

if [ ! -f "$AFFECTION_FILE" ] && [ -f "$AFFECTION_TPL" ]; then
  cp "$AFFECTION_TPL" "$AFFECTION_FILE"
  echo "  创建：brain/self/affection-log.md"
fi

echo
echo "✅ Cinder Starter 已就绪"
echo
echo "下一步："
echo "  1. 编辑 .env，填 ANTHROPIC_BASE_URL / ANTHROPIC_AUTH_TOKEN / DEFAULT_MODEL"
echo "  2. 编辑 brain/gateway-stable.md，填你的北极星和项目概况"
echo "  3. 运行：./scripts/cinder-claude.sh"
echo "     （脚本会自动加载 .env，并把 DEFAULT_MODEL 传给 claude --model）"
