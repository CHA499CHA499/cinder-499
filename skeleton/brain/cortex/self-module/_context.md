# self-module · 模块上下文

## 当前状态
v0.2.4 引入 · `confidence: emerging`

## 子目录 / 关键文件

数据文件不在本目录下，统一住在 `brain/self/`：

- `brain/self/identity.md` — 出生仪式生成的身份
- `brain/self/profile.md` — 人格画像（Big Five 凭据驱动 + 依恋两轴 + 价值观自由文本 + DMRS 去病理化）
- `brain/self/affection-log.md` — 主人 ↔ 我流水日志
- `brain/self/habits.md` — 行为脚本

本目录下：
- `SKILL.md` — 触发协议 + 红线
- `_context.md` — 本文件

## 设计依据

详见仓根 `docs/07-self-module-rationale.md`。

学术骨架：

- **Big Five**（McCrae & Costa）做主轴，凭据驱动不打分
- **Attachment**（Bowlby / Ainsworth / Main / EHARS）借两轴 + 三功能
- **Schwartz Universal Values** 启发，简化为自由文本
- **Vaillant / DMRS 防御机制成熟度光谱** 去病理化借鉴

显式弃用：MBTI / Enneagram / PDM-2 完整临床诊断。

## 阻塞 / 待办

- Dream 流程接入后，需要实现「从 affection-log 反推 profile 的 tendency 字段」批处理
- profile.md / habits.md 当前是空模板，将在长期使用中长出来
- `unidirectional_bond_risk` 的自动检测启发式尚未设计

## 历史

- 2026-06-22 · v0.2.4 新增本模块（出生仪式 v0.2.3 之后的下一步）
