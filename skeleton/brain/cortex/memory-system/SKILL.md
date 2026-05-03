---
name: memory-system
description: Cinder 四层架构核心约束 + 文件存放规则 + 记忆指令协议 + 对话归档/任务闭环细则
triggers:
- memory
- 记忆系统
- architecture
- architecture-spec
- Dream
- brain/
- gateway
- 更新记忆
- 提炼记忆
- 收工
- 再见
- 结束
exposure: always
requires_files:
- _context.md
arch_constraints:
- methodology 禁直接编辑
- vault 访问三条件
- sources 必填
- gateway 容量 ≤ 5×5
permalink: cinder/cortex/memory-system/skill
---

## 模块简介

Cinder 记忆系统是整个 AI 大脑的基础设施。四层架构（vault/thalamus/brain/axon）是唯一权威架构，所有文件操作必须符合层级归属规则。

权威规范：`brain/cortex/memory-system/docs/architecture-spec.md`。

---

## 四层架构强约束（红线）

| 红线 | 违反代价 |
|---|---|
| `methodology.md` 禁止直接编辑（必须从 insights/ 经审核） | commit 加 `[SPEC-WAIVER]` |
| vault 访问三条件（provenance + permissions.yaml + 用户同意） | 数据污染 |
| 结论性陈述必须有 sources 字段或 wiki-link 引用 | 无法追溯 |
| gateway 活跃任务 ≤ 5 chunk × ≤ 5 个（Cowan 工作记忆上限） | 注意力溢出 |
| wiki-link 关系词只能用 8 个：implements/refines/supersedes/blocks/part_of/contrasts_with/sources_from/validated_by | 词表污染 |
| append-only：vault 文件写入后不可改；brain 旧版本走 supersedes 链而非删除 | 历史丢失 |

数据流向**单向**：vault → thalamus → brain → axon → 外部世界。**禁止反向**。

---

## 文件存放规则（详细版，按四层）

### vault/ 层（档案，WORM）
- 原始音频/视频/PDF → `vault/<source>/<YYYY-MM-DD>/<HH-MM-SS>_<slug>.<ext>`（必配 `.sha256` + `.meta.yaml`）
- 系统迁移快照 → `vault/_system/migrations/<YYYY-MM-DD>_<slug>/`
- 关键对话归档（用户标记后）→ `vault/conversations/<YYYY-MM-DD_HH-MM>_<slug>.md`

### thalamus/ 层（感知）
- 源 _context + schema + digests → `thalamus/<source>/{_context.md, schema.yaml, digests/}`

### brain/ 层（认知）
- 工作记忆基线 → `brain/gateway-stable.md`（用户手动维护）
- 工作记忆动态 → `brain/gateway.md`（Dream 自动重写，≤ 5×5）
- 增量流水 → `brain/gateway-delta.md`（AI 实时追加）
- 模块文档 → `brain/cortex/<模块>/{SKILL.md, _context.md, docs, design, code}/`
- 原子概念笔记 → `brain/concepts/<kebab-case>.md`（200-600 字）
- 视图索引 → `brain/views/<slug>.md`（纯索引，不含内容本体）
- 用户画像 / feedback / reference → `brain/self/`（**不入公开仓**）
- 周报 → `brain/timeline/<YYYY-MM>/W<数>.md`
- 活跃任务 → `brain/workspace/<YYYY-MM-DD>-<模块>-<slug>.md`
- 归档 → `brain/archive/`
- 方法论沉淀 → `brain/cortex/methodology.md`（**禁直接编辑**）
- Dream consolidation 候选 → `brain/insights/consolidate-<date>.md`（A1 评分后归 promoted/hold/discarded）
- Benchmark → `brain/evals/<category>/<YYYY-MM-DD>-<slug>.yaml`

### axon/ 层（执行）
- 工具按前缀分类 → `axon/{bridge-,curator-,keeper-,mcp-}<name>/`
- 写权限白名单 → `axon/_permissions.yaml`
- Hook 脚本 → `axon/hooks/<name>.sh`

---

## 指令协议

### 用户说 "再见" / "收工" / "结束"

将本次对话关键上下文写入 `brain/inbox/{YYYY-MM-DD}.md`：
- 做了哪些决策（选了什么方案、为什么、否定了哪些备选）
- 遇到了什么问题、怎么解决的
- 未完成的事项
- 用户给出的重要指示或偏好

同一天多次对话追加到同一个文件，用 `## HH:MM` 分隔。

### 用户说 "更新记忆"

1. 回顾当前对话上下文，提取：今天做了什么 / 遇到了什么问题、如何解决 / 涉及哪些模块 / 有无重要决策或方向变更
2. 写入 `timeline/<YYYY-MM>/W<数>.md`：定位当前周的周报文件，在对应日期下追加今日摘要
3. 更新对应 `cortex/<模块>/_context.md` 的"当前状态"和"最近更新"
4. 更新 workspace/ 活跃任务（如有变化）
5. 简要列出写入了哪些文件

### 用户说 "提炼记忆"

1. 全面阅读：所有周报 / 所有 _context.md / methodology.md / workspace
2. 提炼三类知识：
   - **方法论**：反复出现的工作模式和有效方法
   - **可复用模式**：可在其他模块复用的设计模式/解决方案
   - **教训与避坑**：犯过的错误和避坑指南
3. 写入 `brain/insights/consolidate-<YYYY-MM-DD-HHMM>.md`（**不直接写 methodology.md**）
4. 如装了 A1（`axon/curator-insights/`），文件会被自动评分归档：
   - verdict ≥ 7 → `brain/insights/promoted/`
   - verdict 4-6 → `brain/insights/hold/`
   - verdict ≤ 3 → `brain/insights/discarded/`
5. 想拿 ≥ 7 自动 promote 的写法（评分维度 novelty / evidence / actionability，每维 0-3）：
   - 至少 2 周内复现的实证（不是单事件深度复盘）
   - 写出"反模式 vs 正模式"对照
   - 给出可执行的检查表 / 脚本 / Hook 草案
6. 输出本次提炼的核心发现 + 评分结果（3-5 条 + verdict）

---

## 任务闭环规则（严格执行）

1. **完成即更新**：代码已提交或功能确认完成时，**同会话内**立即更新：
   - workspace 任务文件（标记为已完成）
   - gateway.md 活跃任务列表（移入已完成或追加 gateway-delta.md）
   - 对应 cortex 模块的 `_context.md`（更新状态字段）
   - 禁止"代码做完了但记录没更新"
2. **会话开始时校验**：涉及任务进度查询时，不能只读 gateway 就报告，必须抽查至少一项活跃任务的实际状态（git log / 代码文件）与记录是否一致。发现不一致立即修正。
3. **workspace 过期清理**：已完成超过 7 天的 workspace 任务文件应归档到 `brain/archive/`。

---

## Gateway 增量更新

会话中发生以下事件时，立即在 `brain/gateway-delta.md` 末尾追加一行：
- 任务状态翻转（进行中 → 已完成、新增任务、任务阻塞）
- 重要决策落定（选定方案、否决方案、方向变更）
- 新增阻塞项或阻塞解除

格式：`- MM-DD HH:MM: 简述（≤30 字）`

不需要追加的：日常文件编辑、讨论过程中的临时结论、未确定的方案。

**注意**：不要追加到 `gateway.md`（那是 Dream 自动产物），只写 `gateway-delta.md`。

---

## 写入规则

- `brain/insights/consolidate-*.md` → 提炼候选 draft（写完自动被 curator-insights 评分归档）
- `brain/insights/promoted/` → curator-insights 自动入档（≥ 7 分），用户审核后升 methodology
- `brain/insights/hold/` → curator-insights 自动入档（4-6 分），一周后自动二次评分
- `brain/insights/discarded/` → curator-insights 自动入档（≤ 3 分），归档不删
- `brain/cortex/methodology.md` → 禁止直接写，只能通过 insights/promoted/ 审核通道
- `vault/` → 禁止探索式读取；append-only
- `brain/gateway-delta.md` → 实时追加增量事件

## 禁止操作

- 直接编辑 `brain/cortex/methodology.md`
- 探索式读取 vault/（未经 provenance 指针 + _permissions.yaml + 用户同意）
- 删除 brain/inbox/archived/ 中任何文件
- 向 gateway-delta.md 以外的位置追加未合并更新
- 在 vault 文件写入后修改（append-only 红线）
