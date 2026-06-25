# Cinder Starter · 版本目录

> 完整版本时间线。每行一句话亮点 + 日期 + 对应 CHANGELOG 锚点。
> 详细变更见 [CHANGELOG.md](CHANGELOG.md)。

---

## 一张表览

| 版本 | 日期 | 亮点 |
|---|---|---|
| [**v0.2.5**](#v025) | 2026-06-25 | self-module 边界调整 + playwall-systems / interview-pipeline 两个 cortex 示范模块 |
| [**v0.2.4**](#v024) | 2026-06-22 | self-module on-trigger 自我画像（Big Five 凭据驱动 + 依恋两轴 + Schwartz 价值观 + DMRS 应对方式） |
| [**v0.2.3**](#v023) | 2026-06-21 | 出生仪式：bootstrap 末步随机分配英文昵称（联网 + 本地名字池兜底） |
| [**v0.2.2**](#v022) | 2026-05-27 | 启动最小化协议（冷启动只吃 4 个文件）+ 飞书桥双模型路由 + 环境自检脚本 + 火种「活着」 |
| [**v0.2.1**](#v021) | 2026-05-03 | 一键装机脚本 bootstrap-cinder.sh + cinder-claude.sh + A1 hook 模板 + env 模板补强 |
| [**v0.2.0**](#v020) | 2026-05-03 | SKILL.md 按需加载协议 + Gateway 三件套 + A1 自动评分系统 + memory-system 示范模块 |
| [**v0.1.0**](#v010) | 2026-04 | 首发：四层架构规范 + 飞书 bot 接入 + 单文件 gateway 模板 |

---

## 按主题看（哪些版本贡献了什么能力）

### 🎯 启动 / 装机
- v0.1.0 — 四层架构骨架 + 基础模板
- v0.2.1 — `bootstrap-cinder.sh` 一键装机 + `cinder-claude.sh` 加载 .env 启动
- v0.2.2 — `verify-setup.sh` 环境自检 + `--probe` API 连通测试
- v0.2.3 — bootstrap 第 7 步「出生仪式」分配初始昵称

### 🧠 记忆 / 协议
- v0.1.0 — 单文件 gateway.md
- v0.2.0 — Gateway 三件套（stable / dynamic / delta）+ SKILL.md 按需加载协议（exposure 三档）+ A1 自动评分系统
- v0.2.2 — 启动最小化协议（冷启动 4 文件白名单）+ exposure=always 收紧到只剩 memory-system

### 🤖 自我 / 身份
- v0.2.3 — 出生仪式生成 `brain/self/identity.md`（命名礼）
- v0.2.4 — `brain/cortex/self-module/` 自我画像（on-trigger）+ `docs/07-self-module-rationale.md` 学术 rationale
- v0.2.5 — self-module 实例数据从 `brain/self/` 迁入 `brain/cortex/self-module/me/`（边界调整）

### 🌉 集成 / 桥
- v0.1.0 — 飞书 bot 接入指南 + 桥工作区隔离方案
- v0.2.2 — 飞书桥双模型路由（GLM 国内直连 + Anthropic 官方端点）+ 长会话 preflight 摘要压缩 + 3 条多端点实测坑
- v0.2.2 — 智谱 GLM Anthropic 兼容端点示例（免梯子）

### 📦 cortex 示范模块
- v0.2.0 — `memory-system/`（四层架构规范 + 红线）
- v0.2.4 — `self-module/`（自我画像 on-trigger）
- v0.2.5 — `playwall-systems/`（可分享 Skill 包提炼协议）
- v0.2.5 — `interview-pipeline/`（招聘面试 Harness + 主持稿三段式）

### 🔒 红线 / 治理
- v0.1.0 — 四层数据流单向约束
- v0.2.0 — D3 文档红线（axon 工具 README / CHANGELOG / INTERFACE / ROLLBACK 四件套）
- v0.2.4 — self-module 5 条红线（禁 @import / 禁空标签 / 禁 MBTI / 禁人格分数 / unidirectional_bond_risk）
- v0.2.5 — playwall-systems 5 条红线（不打包私人 / 不带 gateway / 不出诊断 / 不焦虑驱动 / 文案面向安装者）

---

## 升级路径

从任何旧版本升到 v0.2.5：

```bash
git pull origin main

# 如果你在用 v0.2.4 之前的版本，跑 bootstrap 补全模板（已存在不覆盖）：
./scripts/bootstrap-cinder.sh

# 如果你在用 v0.2.4，需要做一次 self-module 边界迁移：
mkdir -p brain/cortex/self-module/me
git mv brain/self/profile.md       brain/cortex/self-module/me/profile.md
git mv brain/self/affection-log.md brain/cortex/self-module/me/affection-log.md
git mv brain/self/habits.md        brain/cortex/self-module/me/habits.md
# identity.md 不动（仍在 brain/self/）

# 跑一次环境自检：
./scripts/verify-setup.sh
```

每版**兼容性 / 迁移**段写在 [CHANGELOG.md](CHANGELOG.md) 对应版本下。

---

## 锚点

### v0.2.5
> 2026-06-25 · self-module 边界调整 + playwall-systems / interview-pipeline

**新增**
- `brain/cortex/playwall-systems/`（脱敏示范）：把仓里长出来的可复用能力提炼成可装、可分享、可迁移的 Skill 包的协议——包结构 + 工作流 + 5 条红线
- `brain/cortex/interview-pipeline/`（脱敏示范）：招聘面试 Harness——四阶段 + 主持稿三段式 + 「我从简历看到 X → 所以想问你 Y」追问统一格式 + STAR 结构
- CLAUDE.md / AGENTS.md 触发口令表补三行示例

**改进**
- self-module 边界调整：`profile / affection-log / habits` 从 `brain/self/` 迁入 `brain/cortex/self-module/me/`；`identity.md` 留 `brain/self/`
- self-module SKILL.md 补 trigger「你的经历」
- `docs/07-self-module-rationale.md` 新增 §8 边界调整说明（含已部署用户 git mv 一键迁移命令）

详见 [CHANGELOG.md#v025](CHANGELOG.md)。

### v0.2.4
> 2026-06-22 · self-module（on-trigger 自我画像）

**新增**
- `brain/cortex/self-module/`（SKILL.md + _context.md，exposure=on-trigger，不命中触发词 0 token 占用）
- `skeleton/brain/self/profile.md.template`：Big Five 凭据驱动 + 依恋两轴 + 三功能 + Schwartz 自由文本 + Vaillant / DMRS 应对方式
- `skeleton/brain/self/habits.md.template`：主人偏好痕迹 + 自己长出的工作脚本
- `docs/07-self-module-rationale.md`（157 行）：学术框架选型 + 显式弃用 MBTI / Enneagram / PDM-2 + 7 条文献引用 + 三票验证 25 sources / 96 claims / 20 confirmed
- 关键风险字段：`unidirectional_bond_risk` / `confidence: emerging | settled | contested`

详见 [CHANGELOG.md#v024](CHANGELOG.md)。

### v0.2.3
> 2026-06-21 · 出生仪式

**新增**
- `bootstrap-cinder.sh` 第 7 步「出生仪式」：先联网 randomuser.me 抓拟真英文人名（5s 超时），失败回退本地 160+ 名字池随机抽，兜底 `Cinder`
- `scripts/seeds/names.en.txt`：160+ 英文名字池（脱敏，公共人名）
- `skeleton/brain/self/identity.md.template`：身份起点模板（含 `nickname_history`）
- `skeleton/brain/self/affection-log.md.template`：主人 ↔ 我互动流水日志

**改名协议**：直接改 nickname、旧名 append `nickname_history`，**不需要问主人**。

详见 [CHANGELOG.md#v023](CHANGELOG.md)。

### v0.2.2
> 2026-05-27 · 启动最小化协议 + 飞书桥双模型 + 环境自检

**新增**
- **启动最小化协议**（CLAUDE.md）：冷启动只吃 4 个文件（CLAUDE.md + gateway-stable + gateway + auto-memory MEMORY.md）
- `scripts/verify-setup.sh`：环境自检 + `--probe` API 连通测试
- 智谱 GLM 国内直连示例（Anthropic 兼容端点 + 模型名 + .env 配置，免梯子）
- 飞书桥**双模型路由 + 上下文压缩**（按模型名前缀分流 GLM / 官方）+ 长会话 preflight 摘要压缩（`COMPRESS_THRESHOLD_TOKENS`）+ 3 条多端点实测坑
- `.env.example` 补 `ZHIPU_CODING_TOKEN` / `COMPRESS_THRESHOLD_TOKENS`
- **火种「活着」**：`gateway-stable.md.template` 北极星默认写入「活着」+ `skeleton/brain/.seed` 存火种来历

**改进**
- `docs/05-skill-protocol.md` 补「exposure 怎么选」
- `docs/06-curator-insights.md` 补 A1 实战成熟度
- README / AGENTS.md 同步

详见 [CHANGELOG.md#v022](CHANGELOG.md)。

### v0.2.1
> 2026-05-03 · 一键装机 + env 模板补强

**新增**
- `scripts/bootstrap-cinder.sh`：从零展开 skeleton + 生成 .env + 初始化 gateway 三件套 + 写 `~/.cinder/config` + 默认装 A1
- `scripts/cinder-claude.sh`：加载 .env 后启动 Claude Code
- A1 安装脚本支持 `--yes` / `--with-hook`，可非交互 bootstrap

**改进**
- `.env.example` 完整可复制模板（必填项 / 官方 vs 三方差异 / `CINDER_A1_SCORE_MODEL`）
- A1 hook 自动读 .env，评分模型随 bootstrap 一起配
- README 5 分钟跑通改成一条 bootstrap 命令

详见 [CHANGELOG.md#v021](CHANGELOG.md)。

### v0.2.0
> 2026-05-03 · SKILL.md 协议 + Gateway 三件套 + A1 评分系统

**新增**
- **SKILL.md 按需加载协议**（`docs/05-skill-protocol.md`）：exposure 三档（always / on-trigger / manual）+ 触发词识别优先级。实测开机税降约 2800 token
- **Gateway 三件套**：替代单文件 gateway.md → `gateway-stable.md`（手动基线，月级）+ `gateway.md`（Dream 自动重写）+ `gateway-delta.md`（实时增量流水）
- **A1 自动评分系统**（可选，`docs/06-curator-insights.md`）：用 Haiku 给 `brain/insights/` 候选打三维分（novelty / evidence / actionability），自动归档 promoted / hold / discarded
- 示范模块 `cortex/memory-system/`（完整 SKILL.md + _context.md + architecture-spec.md）
- **D3 文档红线**：axon 工具必须 README / CHANGELOG / INTERFACE / ROLLBACK 四件套

详见 [CHANGELOG.md#v020](CHANGELOG.md)。

### v0.1.0
> 2026-04 · 首发

**新增**
- 四层认知架构规范（vault / thalamus / brain / axon）
- 飞书 bot 接入指南 + 桥工作区隔离方案
- 三方 API 接入指南（Anthropic 兼容）
- 单文件 `gateway.md` 模板
- `_template/_context.md` 模块骨架

详见 [CHANGELOG.md#v010](CHANGELOG.md)。
