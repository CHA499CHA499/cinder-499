# curator-insights · ROLLBACK

> 工具出问题怎么回到上一个可用状态。
> 设计前提：所有变更可逆；不破坏 vault / brain 的 append-only 承诺。

---

## 故障场景 → 处理

### 场景 1：评分逻辑回归（新版打分明显变差）

**症状**：高质量稿子被打 ≤3 分 / 垃圾稿子被打 ≥7 分。

**回退**：
```bash
cd <repo>/axon/curator-insights
git log --oneline score_consolidate.py | head -10  # 找上一个可用 commit
git checkout <commit-sha> -- score_consolidate.py
# 重跑批量验证：
uv run score_consolidate.py --batch --dry-run --limit 5
```

不需要回退已评分文件——本工具幂等，重跑会覆盖 `score_*` 字段。

---

### 场景 2：错误移动了文件到 promoted/hold/discarded

**症状**：consolidate 被分到错误目录。

**回退**：
```bash
# A. 仅个别文件（git 跟踪了的话）
git log --oneline -- brain/insights/<filename>  # 看历史路径
git mv brain/insights/<wrong-dir>/<file>.md brain/insights/<right-dir>/<file>.md

# B. 整批回退（最近一次评分失误）
git log --oneline brain/insights/ | head -5
git revert <bad-commit-sha>  # 安全：生成反向 commit
```

**不要**：直接 `rm` 错放文件。所有评分动作走 git 跟踪，反悔靠 git。

---

### 场景 3：frontmatter 被破坏（YAML 解析错误）

**症状**：consolidate 文件顶部 `---` 块出现重复字段或语法错。

**回退**：
```bash
# A. 单文件
git checkout HEAD -- brain/insights/consolidate-XXXX.md

# B. 批量
git diff brain/insights/  # 看影响范围
git checkout HEAD -- brain/insights/consolidate-*.md
```

之后修代码再重跑 `--dry-run` 验证不会再写崩。

---

### 场景 4：claude CLI OAuth 失效 / 三方 API 报错

**症状**：`claude --print failed (code 1)`。

**处理**（修复，不是回退）：
1. 先跑 `./scripts/cinder-claude.sh --print "hi"` 验证 CLI + `.env`
2. 三方 API：检查仓根 `.env` 里的 `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN`
3. 供应商不支持默认 Haiku 名称：在 `.env` 里设置 `CINDER_A1_SCORE_MODEL=<可用模型名>`
4. 持续失败：检查 CLAUDE.md 是否被注入到 Haiku prompt

---

### 场景 5：完全停用本工具（紧急）

**症状**：怀疑评分系统污染 insights/ 大面积。

**降级措施**：
```bash
# 1. 注释掉 axon/hooks/instinct-counter.sh 末尾对 score_consolidate.py 的调用
#    （让 sub-agent 继续写新 consolidate，但不再自动评分）

# 2. 或者整个停 instinct-counter（保守做法）：
#    去 ~/.claude/settings.local.json 把 PostToolUse hook 注释

# 3. 把 brain/insights/promoted/ hold/ discarded/ 子目录文件统一移回 brain/insights/
#    git mv brain/insights/{promoted,hold,discarded}/*.md brain/insights/

# 4. 评估问题源后再决定是否重启
```

---

## 不可逆操作清单

本工具**不会**做以下任何一种操作（如果未来版本要做必须独立 RFC）：
- ❌ 删除 consolidate 文件
- ❌ 修改 consolidate 的 title / sources / 正文
- ❌ 写 `brain/cortex/methodology.md`（防污染红线）
- ❌ 跨仓操作
- ❌ 网络请求（除 `claude` CLI subprocess）

如果观察到上述行为 → 立即 git revert 并查代码污染源。

---

## 验证回退是否成功

```bash
# 1. 单文件评分能跑通
uv run score_consolidate.py --dry-run brain/insights/consolidate-XXXX.md

# 2. 批量 dry-run 看分布
uv run score_consolidate.py --batch --dry-run --limit 10

# 3. 检查归档目录数量
ls brain/insights/promoted/ brain/insights/hold/ brain/insights/discarded/ 2>/dev/null | wc -l
```
