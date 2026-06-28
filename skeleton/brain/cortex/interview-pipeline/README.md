# HireBase Harness

HireBase Harness 是一套以飞书多维表格为主控台的 AI 招聘中控台。

它把简历、候选人评分、约面、面试稿、会议录制转写、复盘、测试题和多轮状态流转都收回到同一张候选人表里。飞书文档、候选人沟通窗口和会议系统都是表格某一行候选人记录的附属对象。

## 适合谁

- 正在用飞书多维表格管理候选人的招聘负责人
- 想把 Boss 直聘、飞书和腾讯会议串成招聘流程的人
- 想让 AI 帮忙做简历入表、候选人评分、面试准备和面后复盘的人

## 快速开始

1. 先读 [`SKILL.md`](SKILL.md)，了解触发词和硬约束。
2. 复制 [`docs/recruiting-project-config-template.md`](docs/recruiting-project-config-template.md)，填写自己的项目配置。
3. 按 [`docs/recruiting-harness-product-spec.md`](docs/recruiting-harness-product-spec.md) 建飞书多维表格字段和视图。
4. 用 [`docs/feishu-interview-doc-template.md`](docs/feishu-interview-doc-template.md) 生成每位候选人的面试官工作页。
5. 每次批量操作后，用 [`docs/real-flow-audit-checklist.md`](docs/real-flow-audit-checklist.md) 复核。

## 核心原则

- 飞书多维表格是主控台和单一真相源。
- 所有流程产物必须回写同一条候选人记录。
- 候选人外发消息只给必要信息，不暴露内部轮次、评级、排序、薪资策略和淘汰逻辑。
- 默认每天 16:00 自动巡检一次多维表格，其他更新由用户手动刷新。
- AI 负责整理、评分、写稿、复盘和归档；人负责约谁、过不过、是否进入下一轮。

## 不包含

- 不包含真实公司、候选人、简历、录音或复盘。
- 不包含 open_id、base_id、wiki_id、会议链接、token、cookie 或任何私有凭证。
- 不替用户自动做通过/不通过、进入二面、发 offer 等高风险决策。
