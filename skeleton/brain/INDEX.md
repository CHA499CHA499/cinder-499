# Brain Index

> brain/ 目录的内部导航。跨层信息以 `docs/01-architecture.md` 为权威。

## 顶层文件

| 文件 | 用途 | 维护 |
|---|---|---|
| [gateway-stable.md](./gateway-stable.md) | 北极星 / 四层架构 / 红线（永久基线） | 用户手动，月级 |
| [gateway.md](./gateway.md) | 当前活跃任务（≤ 5 chunk × ≤ 5 个） | Dream / curator 自动，日级 |
| [gateway-delta.md](./gateway-delta.md) | 实时增量事件流水 | AI 会话中追加 |

## 子目录

| 目录 | 用途 |
|---|---|
| `cortex/<模块>/` | 模块状态 + SKILL.md + docs/design/code |
| `concepts/` | 原子概念笔记（200-600 字） |
| `views/` | 视图索引（纯索引） |
| `self/` | 用户画像 / feedback / reference（不入公开仓） |
| `timeline/<YYYY-MM>/W<n>.md` | 周报 |
| `workspace/` | 活跃任务（完成 7 天后归档） |
| `archive/` | 历史归档（append-only） |
| `inbox/` | 对话归档（按日，"再见"/"收工"触发） |
| `insights/` | Dream consolidation 候选（A1 评分后归 promoted/hold/discarded） |
| `evals/` | Benchmark 用例 |

## cortex 模块清单

> 每个模块带一份 `SKILL.md`，AI 按 `exposure` 协议加载（详见 `docs/05-skill-protocol.md`）。

- [_template](./cortex/_template/SKILL.md) — 模块骨架模板
- [memory-system](./cortex/memory-system/SKILL.md) — Cinder 记忆系统核心约束 + 文件存放规则 + 指令协议（**exposure=always**）
- [playwall-systems](./cortex/playwall-systems/SKILL.md) — 可分享 Skill / 玩法包提炼协议（exposure=on-trigger）
- [interview-pipeline](./cortex/interview-pipeline/SKILL.md) — HireBase Harness：以飞书多维表格为主控台的 AI 招聘中控台（exposure=on-trigger）
- [self-module](./cortex/self-module/SKILL.md) — AI 自我画像与关系痕迹模块（exposure=on-trigger）

（在这里追加你的模块）
