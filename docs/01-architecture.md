# Cinder 四层架构规范

> 把 AI 协作上下文按四层组织：vault / thalamus / brain / axon。

## 一、四层定位

| 层 | 定位 | 写入特性 | 读取频率 |
|---|---|---|---|
| `vault/` | 完整无损档案 | append-only（WORM） | 极低（只在追溯时） |
| `thalamus/` | 半加工摘要 + 索引 | 由 curator 工具批量更新 | 中（按需聚合） |
| `brain/` | 认知层 | 主要工作面，AI 频繁读写 | 高 |
| `axon/` | 执行层（工具） | 工具自身代码 + 权限声明 | 低（运行时） |

## 二、数据流向（单向）

```
外部世界 → vault → thalamus → brain → axon → 外部世界
                                              ↑
                                              └─ 反向禁止
```

- vault 写入后**不可改、不可删**（用 `supersedes` 链做版本演进）
- thalamus 由 `axon/curator-*` 工具从 vault 单向蒸馏
- brain 由用户 + AI 共同编辑，但 `methodology.md` 只能从 `insights/` 经审核更新
- axon 工具读 brain 状态、调用外部 API

## 三、brain 子目录约定

| 目录 | 用途 | 容量上限 |
|---|---|---|
| `gateway.md` | 当前活跃任务（工作记忆） | ≤ 5 chunk × ≤ 5 个 |
| `cortex/<模块>/` | 模块状态 + docs + design + code | 按模块拆 |
| `concepts/` | 原子概念笔记 | 200-600 字/篇 |
| `views/` | 视图索引 | 纯索引，不含内容本体 |
| `self/` | 用户画像 / feedback / reference | 不入公开仓 |
| `timeline/<YYYY-MM>/W<n>.md` | 周报 | 按周追加 |
| `workspace/` | 活跃任务文件 | 完成 7 天后归档 |
| `archive/` | 历史归档 | append-only |
| `insights/` | Dream consolidation 候选 | 等审核 |
| `evals/` | Benchmark 用例 | 按主题分 |

## 四、AI 行为强约束

### 4.1 追溯链
任何结论性陈述必须有 `sources` 字段或 `[[wiki-link]]` 引用。例：

```markdown
---
title: 录音触达 SOP
sources:
  - vault/research/2026-04/competitor-survey.md
  - brain/concepts/dynamic-island-pattern.md
---
```

### 4.2 vault 访问
禁止探索式读取。**只在以下三种情形下访问 vault**：
1. brain 文件已有 provenance 指针指向具体 vault 路径
2. `axon/_permissions.yaml` 登记了访问 scope
3. 用户当前会话明确同意访问

### 4.3 methodology 防污染
`brain/cortex/methodology.md` **禁止直接编辑**，必须从 `brain/insights/consolidate-*.md` 经用户审核批量更新。

理由：methodology 是长期沉淀，AI 直接改会被短期对话噪音污染。必须经过 insights → 审核 → 批量合并 三步过滤。

### 4.4 Gateway 容量
活跃任务 ≤ 5 chunk × ≤ 5 个，对应工作记忆上限。超过就强制裁剪到 archive。

### 4.5 append-only
vault 文件写入后不可改。brain 旧版本不删除，用 `supersedes` 链：

```markdown
---
title: 新方案 v2
supersedes: brain/cortex/x/docs/v1-plan.md
---
```

### 4.6 wiki-link 关系词汇表
`[[link]]` 关系只能从以下选：
- `implements` / `refines` / `supersedes` / `blocks`
- `part_of` / `contrasts_with` / `sources_from` / `validated_by`

## 五、反模式清单

| 反模式 | 为什么不行 | 怎么做对 |
|---|---|---|
| AI 直接改 methodology.md | 短期对话噪音污染长期沉淀 | 写入 insights/ 等审核 |
| brain 文件直接 rm | 丢失演进历史 | 用 supersedes 链 |
| vault 探索式 grep | 档案层不该被频繁读 | 先看 brain provenance 指针 |
| gateway 塞 20 个任务 | 超出工作记忆上限 | 裁到 5 个，剩余进 archive |
| 无 source 的"我觉得" | 没追溯链 | 加 wiki-link 或 sources 字段 |
| brain 之间循环引用 | 破坏单向流 | 改用 concepts/ 中间节点 |

## 六、规范演进

修改本规范的流程：
1. 在 `brain/insights/` 写改进提案
2. 用户审核
3. 批量合并到本文件 + 在 commit message 注明 `[SPEC-WAIVER: §条款 原因]`（如有破例）

---

本规范基于 Cinder v0.2.1（2026-04 落地）。
