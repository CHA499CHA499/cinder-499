---
title: interview-pipeline-context
type: note
permalink: cinder/cortex/interview-pipeline/context
---

# interview-pipeline · 模块上下文

## 当前状态
v0.2.7 更新 · `confidence: maturing`

## 子目录 / 关键文件

- `SKILL.md` — on-trigger 触发协议，以招聘 / 简历 / 候选人 / 面试 / 约面 / 二面等请求启动
- `README.md` — 给新使用者看的入口说明
- `_context.md` — 本文件
- `docs/recruiting-harness-product-spec.md` — 招聘 Harness 产品化规范
- `docs/recruiting-project-config-template.md` — 新项目空白配置模板
- `docs/feishu-interview-doc-template.md` — 面试官内部飞书文档模板
- `docs/real-flow-audit-checklist.md` — 真实流程审计清单

## 使用边界

- 本模块是 starter 里的通用招聘流程示范，保留可复用流程、字段、状态机、模板和审计清单。
- 真实公司、候选人、简历、录音、转写、会议链接、表格 ID、open_id、token、cookie 等都必须留在使用者自己的私有项目配置或数据目录里。
- 首次启用时，从 `docs/recruiting-project-config-template.md` 复制一份私有配置，再填写招聘平台、协作平台、会议平台、候选人表字段、会议录制/转写权限和消息模板。
- 所有真实流程产物最终要回写候选人多维表格同一条记录；没有回写表格，就视为流程未完成。

## 运行原则

- 先做环境体检，再处理候选人：Node/Python、招聘平台 CLI、飞书 CLI、会议 CLI、登录态、环境变量、表字段、会议录制/转写权限。
- 候选人外发消息只给必要信息，不暴露内部评级、排序、薪资策略、淘汰逻辑或测试题考察意图。
- AI 可以评分、建议、准备材料和复盘，但通过 / 不通过 / 进入二面 / 发测试题等决策必须等用户明确指令。
- 默认只保留每日 16:00 多维表格巡检；简历、候选人回复、会议产物、测试题更新由用户手动触发刷新。

## 当前待办

- 后续如沉淀 CLI 工作流，可按产品规范中的 `init`、`check-env`、`sync-resumes`、`schedule`、`write-interview-docs`、`pull-transcripts`、`review` 命令形态另建 axon 工具。
- 若新增 axon 工具，必须同步工具自己的 README / CHANGELOG / INTERFACE / ROLLBACK。

## 历史

- 2026-06-25 · v0.2.5 引入本模块（脱敏后从母仓 CHA499 切入示范，三段式主持稿格式 + 「我从简历看到 X → 所以问 Y」追问语句来自母仓 18 场约面 / 14 主持稿实战沉淀）
- 2026-06-30 · v0.2.7 更新为通用 HireBase / 招聘 Harness：以飞书多维表格为主控台，补齐产品规范、项目配置模板、飞书面试文档模板和真实流程审计清单；候选人材料、会议、录音、表格资源和私有 SOP 留在项目配置或数据目录。
