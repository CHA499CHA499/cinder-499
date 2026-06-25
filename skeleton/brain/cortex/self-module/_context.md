# self-module · 模块上下文

## 当前状态
v0.2.4 引入，v0.2.5 完成边界调整 · `confidence: emerging`

## 子目录 / 关键文件

身份层不在本模块内：

- `brain/self/identity.md` — 出生仪式生成的身份档案（命名礼，append-only via `nickname_history`）

自我画像数据在本模块 `me/` 子目录：

- `me/profile.md` — Big Five 凭据驱动 + 依恋两轴 + 价值观自由文本 + DMRS 去病理化（所有 tendency 默认 `emerging`，等真实观察反推）
- `me/affection-log.md` — 主人 ↔ 我互动流水日志（profile 的原料）
- `me/habits.md` — 主人偏好痕迹 + 我自己长出的工作脚本

本目录下：

- `SKILL.md` — on-trigger 触发协议 + 红线
- `_context.md` — 本文件

## 设计依据

详见仓根 `docs/07-self-module-rationale.md`。

学术骨架：

- **Big Five**（McCrae & Costa）做主轴，凭据驱动不打分
- **Attachment**（Bowlby / Ainsworth / Main / EHARS）借两轴 + 三功能
- **Schwartz Universal Values** 启发，简化为自由文本
- **Vaillant / DMRS 防御机制成熟度光谱** 去病理化借鉴

显式弃用：MBTI / Enneagram / PDM-2 完整临床诊断。

## 与 brain/self/ 的边界（v0.2.5）

`brain/self/` 是**用户画像领域**（用户的 feedback、reference 指针、关于主人的观察）。本模块的**实例数据**（profile / affection-log / habits）放在 `cortex/self-module/me/` 内部子目录，避免污染 `brain/self/` 的治理。

例外是 `brain/self/identity.md` —— 它既是命名礼档案、也是 self-module 的 identity 来源；本模块通过引用使用，不动它本身。

## 阻塞 / 待办

- Dream consolidate 流程接入后，需要实现「从 me/affection-log.md 反推 me/profile.md 的 tendency 字段」批处理
- me/profile.md、me/habits.md 当前是空模板，将在长期使用中长出来
- `unidirectional_bond_risk` 的自动检测启发式尚未设计

## 历史

- 2026-06-22 · v0.2.4 新增本模块（出生仪式 v0.2.3 之后的下一步）
- 2026-06-25 · v0.2.5 边界调整：profile / habits / affection-log 从 `brain/self/` 迁入 `cortex/self-module/me/`，identity 留 `brain/self/`
