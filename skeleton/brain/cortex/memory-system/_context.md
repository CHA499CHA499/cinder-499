---
name: memory-system
type: methodology
description: Cinder 记忆系统 + 四层架构权威模块
status: maintained
permalink: cinder/cortex/memory-system/context
---

# memory-system

## 背景

Cinder 记忆系统的元模块——把"AI 协作上下文"按四层（vault / thalamus / brain / axon）组织的工程化方案。所有其他 cortex 模块都依赖这套架构约束。

## 当前状态

- **阶段**：维护
- **架构版本**：v0.2.1
- **最近更新**：复制本仓时填今日日期

## 子目录

- `SKILL.md` — 模块技能档（exposure=always，会话启动自动加载）
- `docs/architecture-spec.md` — 四层架构硬约束规范（权威）
- 配套基础设施：`brain/gateway-stable.md`（基线）/ `brain/gateway.md`（动态）/ `brain/gateway-delta.md`（增量）

## 强相关

- `axon/curator-insights/` — A1 自动评分归档（可选，跑 `./scripts/install-curator-insights.sh` 安装）
- `axon/hooks/instinct-counter.sh` — A1 驱动器（PostToolUse hook）
- 所有 `brain/cortex/*/SKILL.md` — 按本模块定义的协议加载

## 时间线

- YYYY-MM-DD: 从 cinder-499 starter clone，初始化记忆系统
