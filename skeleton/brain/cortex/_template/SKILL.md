---
name: <module-slug>
description: <一句话描述这个模块解决什么问题，AI 看 description 决定是否加载>
triggers:
- <触发词 1>
- <触发词 2>
- <模块名同义词>
exposure: on-trigger
requires_files:
- _context.md
arch_constraints: []
permalink: cinder/cortex/<module-slug>/skill
---

## 模块简介

（2-3 句话讲清楚：这个模块是干嘛的、当前在哪个阶段、和其他模块什么关系）

---

## 强约束 / 红线（如有）

| 红线 | 出处 | 违反代价 |
|---|---|---|
| 例：禁动 X 字段 | docs/spec.md §三 | 数据污染 |

---

## 关键文件 / 目录

- `_context.md` — 模块状态卡（最近更新 / 阻塞 / 子目录说明）
- `docs/` — 设计文档 / spec / handoff 记录
- `design/` — 设计稿（pencil/figma 截图，如有）
- `code/` — 模块独立可运行代码（如有）

---

## 操作协议

> 这个模块在会话中如何被调用 / 触发哪些动作。例：
>
> - 用户说「X」时，加载本 SKILL.md + `docs/Y.md`，按 Z 流程执行
> - 完成后立即更新 `_context.md` 的"当前状态"

---

## 写入规则（如有）

- 哪些文件可以写
- 哪些字段绝对不能改

## 禁止操作

- 例：禁止越过 docs/spec.md §三 的限制
