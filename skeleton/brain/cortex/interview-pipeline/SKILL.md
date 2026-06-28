---
name: interview-pipeline
description: 通用招聘流程 Harness——以飞书多维表格为主控台，完成前置环境体检、简历入表、候选人评分、约面、面试稿、转写复盘和多轮状态流转
triggers:
- 招聘
- 招聘 Harness
- 面试
- 简历
- 候选人
- 筛简历
- 面试准备
- 面试问题
- 沟通复盘
- 约面
- Boss直聘
- 腾讯会议
- 招聘平台
- 协作平台
- 会议平台
- 测试题
- 二面
- 测试岗
exposure: on-trigger
requires_files:
- docs/recruiting-harness-product-spec.md
- docs/recruiting-project-config-template.md
- docs/feishu-interview-doc-template.md
- docs/real-flow-audit-checklist.md
permalink: cinder/cortex/interview-pipeline/skill
---

## 模块简介

通用招聘面试流程 Harness。任何招聘/面试相关请求都走这条线：先完成本机环境与三类 CLI 体检，再按项目配置连接招聘平台、飞书多维表格/文档、会议系统，最后围绕飞书多维表格里的候选人记录完成简历监听、入表评分、面试预约、面试稿、录制转写、复盘和多轮状态推进。真实运行时默认每天 16:00 自动巡检一次多维表格，其他更新由用户手动触发。

产品化流程见 [`docs/recruiting-harness-product-spec.md`](docs/recruiting-harness-product-spec.md)，新项目配置模板见 [`docs/recruiting-project-config-template.md`](docs/recruiting-project-config-template.md)，面试官飞书文档格式见 [`docs/feishu-interview-doc-template.md`](docs/feishu-interview-doc-template.md)，真实流程审计清单见 [`docs/real-flow-audit-checklist.md`](docs/real-flow-audit-checklist.md)。本文件必须保持可抽取、可复用，不写入任何具体公司、个人、平台账号、资源标识符或候选人信息。

具体公司的落地资料只能作为项目私有实例配置存在，不能成为通用 Skill 的必需依赖。导出给其他用户时，只带通用规范和空白配置模板。

## 触发后第一步

先读 `docs/recruiting-harness-product-spec.md`、`docs/recruiting-project-config-template.md`、`docs/feishu-interview-doc-template.md` 与 `docs/real-flow-audit-checklist.md`，从第 1 章开始做环境体检：Node/Python、招聘平台 CLI、飞书 CLI、会议 CLI、登录态、环境变量、飞书多维表格结构、会议录制/转写权限。只有前置检查通过，才进入招聘前/招聘中/招聘后的流程。

如果当前任务明确指定了某个已有招聘项目，再额外读取该项目的私有 SOP、候选人表配置和上下文；否则只按通用产品化规范工作，并引导新用户完成项目初始化。

## 三阶段速记

1. **招聘前**：引导用户提供岗位画像/公司介绍/流程规则 → 检查 Node/Python/CLI/token/环境变量/飞书多维表格字段/会议权限 → 监听简历 → 自动回复收到 → 简历入表 → 评分、星级、风险与推荐动作。
2. **招聘中**：等待用户给出明确时间窗口与人数 → 从多维表格视图按评分优先级选候选人 → 创建会议并开启录制转写 → 用极简话术向候选人确认时间 → 回写「已约」状态 → 立即生成飞书面试文档并把链接挂回表格。
3. **招聘后**：会议结束后拉转写/录音 → 校验候选人归属 → 将转写、复盘、评分、测试题状态全部回写多维表格 → 等用户明确指令进入二面或终态；二面流程同一面。

## 硬约束

- 不把任何具体客户/公司/个人/候选人/表格 ID 写进通用 Skill；这些只能放在项目私有配置里。
- 写操作遵守当前项目 CLI 的安全约束；涉及附件下载/上传时必须使用项目允许的工作目录。
- 只依据简历真实内容评估，不编造；异地/投错岗/薪资倒挂显式标出。
- 不擅自淘汰候选人、不擅自进入二面、不擅自改用户判定的「面试情况」状态。
- 不在会议录制/转写未确认可用时静默约面；如果工具不支持自动开启，必须标红提醒用户手动开启。
- 候选人外发消息只做时间确认和必要会议信息，不暴露内部轮次、评级、薪资策略、测试题意图、淘汰逻辑。
- 修改已有在线面试文档前必须先读取在线现状，尊重用户手改内容，不用本地旧稿整篇覆盖。
- 会议改期必须同步会议平台、候选人表、候选人确认消息三处。
- 所有流程产物最终必须落回飞书多维表格同一条候选人记录；没有回写表格，就视为流程未完成。
- 真实自动化只默认保留每日 16:00 多维表格巡检；简历、候选人回复、会议产物、测试题更新默认由用户手动触发。巡检和手动刷新都必须保存游标和自动化日志。
