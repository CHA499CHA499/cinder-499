---
name: playwall-systems
description: 把仓里长出来的可复用能力提炼成可分享、可安装、可迁移的 Skill 包模块。当用户提到「提炼成 Skill」「玩法包」「系统包」「分享给别人用」时加载。
triggers:
- 提炼成 Skill
- 玩法包
- 系统包
- 打包成 Skill
- 分享给别人用
- 上架
- 玩法墙
exposure: on-trigger
requires_files:
- _context.md
permalink: cinder/cortex/playwall-systems/skill
---

# Playwall Systems

## 模块定位

把 Cinder 仓里长出来的可复用做法（一套 prompt 协议、一套记忆模板、一段工作流），提炼成**可装、可分享、可迁移**的 Skill 包。让自己的方法论能被别人 fork 着用。

## 包结构约定

```
skills/<system-name>/
├── SKILL.md              # 触发协议 + 核心流程（保持轻量）
├── assets/templates/     # 详细模板（长内容下沉）
├── references/           # 长说明 / 引用 / 设计依据
└── README.md             # 给安装者看的入口
```

## 工作协议

1. 先读 `_context.md`，确认当前已提炼的包清单和来源
2. 新增 Skill 时：核心流程写在 `SKILL.md`，**长模板放 `assets/templates/`**，长说明放 `references/`
3. SKILL.md 加 `exposure` / `triggers` / `requires_files` frontmatter，符合本仓 SKILL 协议（见 `docs/05-skill-protocol.md`）
4. 新增包后跑验证（如有 skill-creator 工具链）
5. 维护一份「包清单」表（标题 / 分类 / 描述 / 来源 / 导入指令），方便对外发布

## 红线

- **不把 `brain/self/identity.md`、`brain/cortex/self-module/me/*`、`brain/inbox/`、`brain/timeline/`、`brain/vault/` 等私人数据打包进公开 Skill**
- Cinder 框架包对外发布时只能是空骨架 + 规则 + 模板，**不能带真实 gateway / timeline / inbox / vault 内容**
- 系统包文案面向**安装者**写「这个系统能做什么、怎么用」，不能写成内部工程实现说明
- 涉及心理 / 情绪 / 健康类系统包，**不得输出疾病判断、治疗建议、危机承诺**
- 涉及"打卡 / 连签 / 督促"类系统包，**不得用羞耻、惩罚、焦虑驱动用户**

## 与其他模块关系

- 提炼自 `brain/cortex/<source-module>/` 的能力 → 在新 Skill 的 README 注明来源模块和迁移笔记
- 提炼 self-module 相关能力时**特别小心**：实例数据（profile / affection-log / habits）必须留在原仓，只发布字段定义和反推协议
