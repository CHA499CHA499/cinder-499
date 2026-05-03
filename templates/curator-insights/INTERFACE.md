# curator-insights · INTERFACE

> 这个工具与外部世界的契约。改任何一项必须更新本文件 + 对应 CHANGELOG。

---

## 调用方

| 调用方 | 触发时机 | 命令 |
|---|---|---|
| `axon/hooks/instinct-counter.sh` | brain-curator sub-agent 写完新 consolidate 后 | `uv run --directory <repo>/axon/curator-insights score_consolidate.py <file>` |
| 用户手动 | 周期性批量复评 | `uv run ... score_consolidate.py --batch [--dry-run] [--limit N]` |

---

## 读取的路径（输入）

| 路径 | 用途 | 写入？ |
|---|---|---|
| `brain/insights/consolidate-*.md` | 评分目标（含 frontmatter + 正文） | ❌ 只读 |
| `.env` | 读取 Claude Code / 三方 API / A1 模型配置 | ❌ |
| `$CINDER_HOME` env | 仓根定位（第 1 层 fallback） | ❌ |
| `$CINDER_A1_SCORE_MODEL` env | 覆盖评分模型（可选） | ❌ |
| `~/.cinder/config` | 仓根定位（第 2 层 fallback，`CINDER_HOME=` 行） | ❌ |
| 脚本自身位置 | 仓根定位（第 3 层 fallback：`<script>/../..`） | ❌ |

---

## 写入的路径（输出）

| 路径 | 内容 | 时机 |
|---|---|---|
| `brain/insights/consolidate-*.md`（原位置） | 在 frontmatter 追加 8 个 `score_*` 字段 | 评分完成且非 `--dry-run` |
| `brain/insights/promoted/<filename>.md` | 移动（verdict=promote） | 评分写回后 |
| `brain/insights/hold/<filename>.md` | 移动（verdict=hold） | 同上 |
| `brain/insights/discarded/<filename>.md` | 移动（verdict=discard） | 同上 |

**绝对禁动**（红线）：
- `brain/cortex/methodology.md`（防污染）
- `brain/insights/<非 consolidate-*>.md`（早期人工 insights）

---

## 外部依赖

| 依赖 | 用途 | 可替代？ |
|---|---|---|
| `claude` CLI（OAuth 已登录或三方 API 已配） | subprocess 调 `claude --print` 跑 Haiku 评分 | ❌ 唯一 LLM 调用通道 |
| Python 3.13+ | 脚本运行时 | ✅ 但 uv project 已锁 |
| `uv` | 依赖管理 + 虚拟环境 | ❌（`pyproject.toml` + `.venv/` 是部署单位） |
| stdlib only | 无 PyPI 依赖 | — |

**没用到**：`ANTHROPIC_API_KEY`、Basic Memory MCP、Web UI。

---

## frontmatter 契约

评分写回的字段 schema：

```yaml
score_novelty: 0-3       # int
score_evidence: 0-3      # int
score_actionability: 0-3 # int
score_total: 0-9         # int (= sum of above 3)
verdict: promote | hold | discard
score_reason: "..."      # ≤120 字中文
scored_at: YYYY-MM-DD HH:MM
scored_by: axon/curator-insights v<version>
```

**保留**（绝不覆盖）：`title` / `type` / `status` / `sources` / `created` / `permalink`。

---

## 对调用方的承诺

1. **幂等**：同一文件重复评分不会破坏内容，只覆盖 `score_*` 字段（多次评分留下最后一次）
2. **失败不污染**：评分失败时不写回、不移动，文件保持原状
3. **dry-run 真不写**：`--dry-run` 只打印 verdict 不动磁盘
4. **批量限速**：`--batch` 串行调用 Haiku，不并发（避免触发 OAuth rate-limit）

## 调用方对本工具的承诺

1. 不直接编辑 `score_*` 字段（评分由本工具写入）
2. 不在 `brain/insights/promoted/` 目录手动 promote 到 methodology（用户拍板由专门流程负责）
3. 改 frontmatter schema 时同步更新本文件 + CHANGELOG
