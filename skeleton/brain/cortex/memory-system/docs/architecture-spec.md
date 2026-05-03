---
name: Cinder 四层认知架构硬约束规范
description: vault/thalamus/brain/axon 四层架构的硬约束清单，违反即 flag
type: methodology
version: 0.2.1
permalink: cinder/cortex/memory-system/docs/architecture-spec
---

# Cinder 四层认知架构硬约束规范 v0.2.1

> 外部对标：Medallion Architecture / Letta MemGPT / Zettelkasten / Anthropic Agent Skills

---

## 〇、适用范围

1. 本规范约束本仓库内所有新增和修改的文件组织方式。
2. 违反本规范的改动：**AI 必须在 commit 前 flag**；commit message 第一行注明 `[SPEC-WAIVER: <条款号> <原因>]`。
3. 规范冲突时优先级：`vault 完整性规则` > `跨层引用规则` > `各层内部规则` > `审美偏好`。

---

## 一、四层架构总则

1. **只有 4 个顶级认知目录**：`vault/` `thalamus/` `brain/` `axon/`。禁止新增第 5 个平级。
2. **数据流向单向**：
   ```
   外部输入 → vault/ → thalamus/ → brain/ → axon/ → 外部世界
   ```
   禁止反向。
3. **每层顶部建议存在 `_context.md`**，说明：① 本层定位；② 硬约束摘要；③ 常见反模式。
4. **跨层引用必须显式声明来源路径**（见 §六）。

### 生物学对应

| 层 | 生物学对应 | 功能 |
|---|---|---|
| `vault/` | 外挂档案 | 完整无损档案，WORM 保真 |
| `thalamus/` | 丘脑 | 原始输入的半加工摘要 |
| `brain/` | 新皮层 + 海马 + 前额叶 | 方法论、决策、工作记忆 |
| `axon/` | 轴突 | brain 到外部世界的所有传递接口 |

---

## 二、brain/（认知层）硬约束

1. **只允许文本格式**：`.md` / `.yaml` / `.json` / `.txt` / `.ndjson`。二进制（图片/音频/PDF）→ 进 vault。

2. **结论性文档 frontmatter 必含 6 字段**：
   ```yaml
   name: <文档名称>
   description: <一句话用途描述>
   type: <concept | project | procedural | episodic | methodology | reference | index | view>
   sources: [<路径 或 [[wiki-link]]>]
   valid_from: YYYY-MM-DD
   supersedes: <前一版本相对路径 或 null>
   ```

3. **gateway 三件套**（替代单文件 gateway）：
   - `gateway-stable.md` — 永久基线（北极星 + 架构 + 红线），用户手动维护，月级
   - `gateway.md` — 当前活跃任务（≤ 5 chunk × ≤ 5 个），Dream 自动重写
   - `gateway-delta.md` — 实时增量流水，AI 会话中追加

4. **brain 子目录定位不可混用**：
   | 路径 | 定位 |
   |---|---|
   | `cortex/<模块>/` | project-oriented，复杂任务载体（带 SKILL.md） |
   | `concepts/` | atomic notes（200-600 字/篇） |
   | `views/` | 纯索引，不含内容本体 |
   | `timeline/<YYYY-MM>/W<数>.md` | 周报 |
   | `workspace/` | 活跃任务（7 天未编辑迁 archive） |
   | `archive/` | 历史归档（append-only） |
   | `self/` | 用户画像/feedback/reference（不入公开仓） |
   | `insights/` | Dream consolidation 候选 |
   | `evals/` | benchmark 问题集 |

5. **methodology.md 防污染**（强约束 §二.6）：`brain/cortex/methodology.md` **禁止直接编辑**。只能从 `brain/insights/` 经审核后批量更新。

6. **gateway 容量上限**（§二.4）：活跃任务 ≤ 5 chunk × ≤ 5 个。超过强制裁剪到 archive。Cowan 工作记忆上限。

---

## 三、cortex/（模块）硬约束

1. **每个模块顶部带 `SKILL.md`**：定义触发词 + exposure 等级 + 加载哪些 requires_files。详见 `docs/05-skill-protocol.md`。

2. **每个模块带 `_context.md`**：状态卡（当前阶段 / 最近更新 / 阻塞 / 子目录说明）。

3. **模块内子目录约定**：
   - `docs/` — 设计文档 / spec / handoff 记录
   - `design/` — 设计稿截图（如有）
   - `code/` — 模块独立可运行代码（如有）

---

## 四、vault/（档案）硬约束

1. **append-only 红线**：vault 文件写入后**不可改、不可删**。需要更新走 `supersedes` 链。

2. **vault 访问三条件**（强约束 §四.12）：禁止探索式读取。**只在以下三种情形下访问**：
   - ① brain 文件已有 provenance 指针指向具体 vault 路径
   - ② `axon/_permissions.yaml` 登记了访问 scope
   - ③ 用户当前会话明确同意访问

3. **二进制必配 sidecar**：每个二进制文件配同名 `.sha256`（完整性校验）+ `.meta.yaml`（元数据），代替 frontmatter。

4. **目录约定**：
   - `vault/<source>/<YYYY-MM-DD>/<HH-MM-SS>_<slug>.<ext>` — 按源 + 日期分类
   - `vault/_system/migrations/` — 系统迁移快照
   - `vault/conversations/` — 关键对话归档（用户标记后）

---

## 五、thalamus/（感知）硬约束

1. **由 axon/curator-* 工具单向蒸馏**：thalamus 数据来源只能是 `vault/`，禁止从 brain 反流。

2. **每个源一个目录**：`thalamus/<source>/{_context.md, schema.yaml, digests/}`

3. **digests 是聚合产物**：单条原始数据 → vault；批量摘要/索引 → thalamus。

---

## 六、跨层引用与追溯链

1. **wiki-link 词汇表**（§六.2）：`[[link]]` 关系只能从以下 8 个选：
   - `implements` / `refines` / `supersedes` / `blocks`
   - `part_of` / `contrasts_with` / `sources_from` / `validated_by`

2. **跨层引用必须显式路径**：
   ```yaml
   sources:
     - vault/research/2026-04/competitor-survey.md
     - brain/concepts/dynamic-island-pattern.md
   ```

3. **brain 之间禁止循环引用**：用 concepts/ 中间节点解耦。

4. **结论性陈述必须有 sources**（§六.5）：任何结论性陈述必须有 `sources` 字段或 `[[wiki-link]]` 引用，否则视为无追溯链。

---

## 七、axon/（执行）硬约束

1. **工具按前缀分类**：
   - `bridge-*` — 桥接外部系统（如飞书 bot）
   - `curator-*` — 蒸馏工具（vault → thalamus / insights 评分等）
   - `keeper-*` — 维护工具（备份 / 清理）
   - `mcp-*` — MCP server

2. **每个工具必须自带四件套**：
   - `README.md` — 用法
   - `CHANGELOG.md` — 对外可观察的变更
   - `INTERFACE.md` — 与外部世界的契约（调用方 / 读写路径 / 依赖）
   - `ROLLBACK.md` — 出问题如何回退

3. **写权限声明**：在 `axon/_permissions.yaml` 登记每个工具的 `can_write` / `can_read` / `cannot`。

---

## 八、反模式清单

| 反模式 | 为什么不行 | 怎么做对 |
|---|---|---|
| AI 直接改 methodology.md | 短期对话噪音污染长期沉淀 | 写入 insights/ 等审核 |
| brain 文件直接 rm | 丢失演进历史 | 用 supersedes 链 |
| vault 探索式 grep | 档案层不该被频繁读 | 先看 brain provenance 指针 |
| gateway 塞 20 个任务 | 超出工作记忆上限 | 裁到 5 个，剩余进 archive |
| 无 source 的"我觉得" | 没追溯链 | 加 wiki-link 或 sources 字段 |
| brain 之间循环引用 | 破坏单向流 | 改用 concepts/ 中间节点 |
| axon 工具没文档四件套 | 朋友/未来 AI 接手抓瞎 | 强制 README/CHANGELOG/INTERFACE/ROLLBACK |

---

## 九、规范演进流程

修改本规范的流程：
1. 在 `brain/insights/` 写改进提案
2. 用户审核
3. 批量合并到本文件 + 在 commit message 注明 `[SPEC-WAIVER: §条款 原因]`（如有破例）

---

本规范基于 Cinder v0.2.1（2026-04 落地于 CHA499 项目，2026-05 切片入 cinder-499 starter）。
