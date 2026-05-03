# curator-insights · CHANGELOG

> 仅记录**对外可观察的变更**：评分逻辑 / 字段 / 命令行接口 / 归档去向 / 调用方契约。
> 内部重构、注释、变量改名不进 changelog。
> 格式：`## YYYY-MM-DD vN.M.P` + 改动列表。新版本追加在顶部。

---

## 2026-05-03 v0.1.0 · 首发

### 新增
- `score_consolidate.py`：单文件 Python 工具，subprocess 调 `claude --print` 跑 Haiku 评分
- 三维评分 novelty / evidence / actionability（每维 0-3，总分 0-9）
- verdict 三档：`promote` (≥7) / `hold` (4-6) / `discard` (≤3)
- 写回 frontmatter 字段：`score_novelty` / `score_evidence` / `score_actionability` / `score_total` / `verdict` / `score_reason` / `scored_at` / `scored_by`
- 自动归档：`brain/insights/{promoted,hold,discarded}/`
- 命令行接口：`--dry-run` / `--batch` / `--limit`
- 接 `axon/hooks/instinct-counter.sh`：sub-agent 写完 consolidate 立即评分

### 路径解析
- 三层 fallback：`$CINDER_HOME` → `~/.cinder/config` → 脚本位置推导
- 与 `axon/hooks/instinct-counter.sh` 行为一致

### 已知限制
- Haiku 偶发输出非 JSON，靠正则兜底抽 `{...}`
- 不评分非 `consolidate-*` 命名的 insights
