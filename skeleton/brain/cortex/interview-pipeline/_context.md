# interview-pipeline · 模块上下文

## 当前状态
v0.2.5 引入 · `confidence: emerging`

## 子目录 / 关键文件

- `SKILL.md` — on-trigger 触发协议
- `_context.md` — 本文件
- `docs/interview-sop.md` — 四阶段流程权威源（含具体协作人 / 表格 ID / 来源渠道，**私密**）
- `recordings/` — 面试录音 / 逐字稿（按候选人分子目录，**不入版本控制**）
- `backup/` — 已结束候选人归档

## 待用户填的硬编码（首次启用时）

| 配置项 | 说明 |
|---|---|
| 简历来源渠道 | 哪个 IM / 邮箱 / 招聘平台同步 |
| 候选人跟踪表 | 多维表格 / 在线表格 ID |
| 协作人 ID | 简历推送人的 open_id / userid |
| 主持稿存放 | wiki 节点 / 文档目录 |

把这些填进 `docs/interview-sop.md`（首次创建时复制 SKILL.md 的「四阶段速记」起草模板）。

## 阻塞 / 待办

- `docs/interview-sop.md` 是私密文件，starter 不附带模板（避免泄露具体配置）。首次用时按 SKILL.md 的四阶段框架手起一份
- 主持稿三段式 + 追问格式已固化（见 SKILL.md）

## 历史

- 2026-06-25 · v0.2.5 引入本模块（脱敏后从母仓 CHA499 切入示范，三段式主持稿格式 + 「我从简历看到 X → 所以问 Y」追问语句来自母仓 18 场约面 / 14 主持稿实战沉淀）
