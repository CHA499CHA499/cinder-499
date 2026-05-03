# A1 自动评分 · curator-insights（可选模块）

> 解决 `brain/insights/` 候选堆积无人审核的瓶颈：用 Claude Haiku 给每份 consolidate 打三维分（novelty / evidence / actionability），按总分自动归档到 `promoted/` `hold/` `discarded/`。

## 这是什么 / 解决什么

`brain/insights/consolidate-*.md` 是「提炼记忆」/ Dream 自动整合产出的"候选方法论"。本来设计是「等用户审核 → 升 methodology」——但审核环节几乎不会主动触发，候选很快堆到几十份没人看。

A1 做的事：

| verdict | 总分 | 去向 | 含义 |
|---|---|---|---|
| `promote` | ≥ 7 | `brain/insights/promoted/` | 候选合入 methodology，等用户拍板 |
| `hold` | 4-6 | `brain/insights/hold/` | 一周后再评，看是否复现 |
| `discard` | ≤ 3 | `brain/insights/discarded/` | 重复/空话，归档不再触达 |

每维 0-3 分：
- **novelty**：与已有 methodology 是否重复 / 带来新视角
- **evidence**：sources 数量 + 实证密度 + 是否跨周复现
- **actionability**：能否写成 if-then / 检查表 / 脚本

## 安装（一键）

```bash
# 在 cinder-499 仓根执行
./scripts/install-curator-insights.sh
```

脚本会做：

1. 检查 `uv` 是否安装（没装则给出 `curl` 安装命令，不自动跑）
2. 检查 `claude` CLI 是否在 PATH（A1 用 `claude --print` 调 Haiku）
3. 把 `templates/curator-insights/` 复制到 `axon/curator-insights/`
4. `cd axon/curator-insights && uv sync`
5. 跑一次 `--dry-run`（如果 `brain/insights/` 里有 consolidate 文件）
6. 提示用户在 `axon/hooks/instinct-counter.sh` 末尾接入评分调用（参考 `skeleton/axon/hooks/instinct-counter.sh.example`）

## 让 Claude Code 帮你装

如果你在 Claude Code 会话里，直接说：

> "帮我装一下 A1 自动评分系统"

AI 会读本文档 + 跑脚本，然后告诉你接下来要做什么（一般是手动接 `instinct-counter.sh` hook，或 ~/.claude/settings.local.json 的 PostToolUse）。

## 用法（装完后）

```bash
# 单文件评分（dry-run 不写回不移动）
uv run --directory axon/curator-insights \
  score_consolidate.py --dry-run \
  brain/insights/consolidate-2026-05-02-2016.md

# 批量评分所有 consolidate-*.md
uv run --directory axon/curator-insights \
  score_consolidate.py --batch

# 批量但只跑前 5 份（验证用）
uv run --directory axon/curator-insights \
  score_consolidate.py --batch --limit 5
```

## 写出能拿 ≥ 7 分的 consolidate

提炼记忆时，AI（或你自己）按以下原则写，更容易自动 promote：

1. 至少 2 周内有复现的实证（不是单事件深度复盘）
2. 写出"反模式 vs 正模式"对照
3. 给出可执行的检查表 / 脚本 / Hook 草案

## 接入 PostToolUse hook（自动驱动）

A1 配套的"自动驱动器"是 `axon/hooks/instinct-counter.sh`：每 N 次 tool-call 触发 brain-curator sub-agent 跑提炼，写完立即调 A1 评分。

模板见 `skeleton/axon/hooks/instinct-counter.sh.example`。接入步骤：

1. 复制模板到 `axon/hooks/instinct-counter.sh` 并 `chmod +x`
2. 编辑 `~/.claude/settings.local.json`：
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "*",
           "hooks": [{"type": "command", "command": "/path/to/your-cinder/axon/hooks/instinct-counter.sh"}]
         }
       ]
     }
   }
   ```
3. 重启 Claude Code 会话验证：每跑 15 个 tool call 应触发一次后台提炼

## 限制 / 已知问题

- **依赖 `claude` CLI**：用 `claude --print` 跑评分（不用 ANTHROPIC_API_KEY）。三方 API 用户也能跑，因为 CLI 自己读 `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN`
- **Haiku 偶发输出非 JSON**：脚本有正则兜底
- **冷静评分偏严**：高质量稿子也常拿 5 分进 hold，第一次跑批量 promote 比例 5-30% 是正常的
- **不评分早期人工 insights**：只处理 `consolidate-*.md` 文件名

## 卸载

```bash
rm -rf axon/curator-insights/
# 把 axon/hooks/instinct-counter.sh 末尾对 score_consolidate.py 的调用删掉
# 或整个删 hook，并在 ~/.claude/settings.local.json 里去掉 PostToolUse 配置
```

`brain/insights/` 已分类的文件保持原样（评分写在 frontmatter 里，不再触发也无副作用）。

## 完整文档

装完后看 `axon/curator-insights/{README,INTERFACE,CHANGELOG,ROLLBACK}.md`。
