# axon/curator-insights · A1 自动评分 + 归档

> Cinder Harness Upgrade A1 — 解决 `brain/insights/` consolidate 文件全部 status:draft 悬空、无人审核的瓶颈。

## 定位

`instinct-counter.sh` 每 N 次 tool-call 触发 brain-curator sub-agent 跑提炼，但提炼出来的 consolidate 全是 draft，等"人工审核"——而审核环节几乎从不触发。本工具用 Claude Haiku 做**冷静评分**（比作者自评更严），按门槛自动归档：

| verdict | total | 去向 | 含义 |
|---|---|---|---|
| `promote` | ≥ 7 | `brain/insights/promoted/` | 候选合入 methodology，等用户拍板 |
| `hold` | 4-6 | `brain/insights/hold/` | 一周后再评一次，看是否有新证据复现 |
| `discard` | ≤ 3 | `brain/insights/discarded/` | 重复/空话/拆得过碎，归档不再触达 |

## 评分维度（每维 0-3 分）

- **novelty** (新颖度): 与现有 methodology 是否重复 / 是否带来新视角
- **evidence** (证据强度): sources 数量 + 实证密度 + **是否跨周复现**
- **actionability** (可执行性): 是否能写成 if-then 规则、检查表、脚本

## 用法

> 假设你在仓根。脚本会自动定位仓根（CINDER_HOME env > ~/.cinder/config > 脚本位置推导），并自动读取仓根 `.env`。

```bash
# 一键安装（推荐）
./scripts/install-curator-insights.sh --with-hook

# 单文件评分（dry-run 不写回不移动）
uv run --directory axon/curator-insights \
  score_consolidate.py --dry-run \
  brain/insights/consolidate-2026-05-02-2016.md

# 批量评分所有 brain/insights/consolidate-*.md
uv run --directory axon/curator-insights \
  score_consolidate.py --batch

# 批量但只跑前 5 份（验证用）
uv run --directory axon/curator-insights \
  score_consolidate.py --batch --limit 5

# 批量 dry-run（看分布不写回）
uv run --directory axon/curator-insights \
  score_consolidate.py --batch --dry-run
```

## 写回 frontmatter 字段

评分后给文件 frontmatter 追加：

```yaml
score_novelty: 2          # 0-3
score_evidence: 1         # 0-3
score_actionability: 2    # 0-3
score_total: 5            # 0-9
verdict: hold             # promote | hold | discard
score_reason: "≤120字中文 reasoning"
scored_at: 2026-05-02 21:00
scored_by: axon/curator-insights v0.1
```

原有字段（title / type / status / sources / created / permalink）全部保留。

## 约束（红线）

1. **禁动 methodology.md** —— 评分只在 `brain/insights/` 内移动，永不写 `brain/cortex/methodology.md`
2. **只动 consolidate-* 文件** —— 不评分早期人工写的 insights（如 `2026-04-27-*-rationality.md`）
3. **冷静严苛** —— prompt 明确"宁可低分也不要给 7 分以上注水分"，第一次跑高质量样本只给 5 分 hold 是预期行为

## 与 instinct-counter.sh 的接力

```
PostToolUse hook 触发 instinct-counter.sh
  → 每 N 次 tool-call spawn brain-curator sub-agent
  → sub-agent 写新 consolidate-YYYY-MM-DD-HHMM.md（status:draft）
  → 末尾接：uv run score_consolidate.py <new_file>
  → 文件被评分写回 + 移动到 promoted/hold/discarded
  → 用户只需周期性 review brain/insights/promoted/ 决定升 methodology
```

## 不依赖

- 无 PyPI 依赖（pure stdlib + subprocess）
- 无 ANTHROPIC_API_KEY（走 claude CLI 已登录的 OAuth / 三方中转）
- 无新增 MCP server
- 无 Web UI

## 可配置项

| env | 默认值 | 说明 |
|---|---|---|
| `CINDER_HOME` | `~/.cinder/config` 或脚本位置推导 | Cinder 仓根 |
| `CINDER_A1_SCORE_MODEL` | `claude-haiku-4-5-20251001` | 评分模型；三方供应商不支持默认 Haiku 时改这里 |
| `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` | `.env` | 三方 Anthropic 兼容 API 配置 |

## 故障排查

| 现象 | 原因 | 处理 |
|---|---|---|
| `claude --print failed (code 1)` | `.env` 未填 / OAuth 过期 / 模型名不匹配 | 先跑 `./scripts/cinder-claude.sh --print "hi"` 验证 |
| `Cannot parse JSON from claude output` | Haiku 偶发输出非 JSON | 兜底正则已抽 `{...}`；持续失败检查 prompt |
| 评分偏严（高质量也只 5 分） | 跨周复现弱是真相 | 不是 bug；让稿子在 hold/ 待第二次复现 |

更多见 `ROLLBACK.md`。
