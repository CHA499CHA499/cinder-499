# Cinder Starter · CHANGELOG

> 仅记录**对外可观察的变更**：架构规范 / 协议 / 命令行接口 / 文件结构。
> 内部重构、注释改名不进 changelog。

---

## 2026-06-29 v0.2.6 · recruiting-harness 完整可分发包

> 将 v0.2.5 的 `interview-pipeline` 从简略示范升级为完整脱敏 Skill 包。核心形态：以飞书多维表格为招聘主控台，所有候选人信息、状态、会议、面试稿、转写、复盘和测试题进度都回到同一条候选人记录。

### 新增
- **`skeleton/brain/cortex/interview-pipeline/docs/recruiting-harness-product-spec.md`**：招聘 Harness 产品化规范。包含前置环境体检、飞书多维表格主控台、招聘前/中/后流程、状态机、每日巡检与手动刷新机制。
- **`skeleton/brain/cortex/interview-pipeline/docs/recruiting-project-config-template.md`**：新项目配置模板。包含招聘平台、飞书多维表格字段、推荐视图、消息模板、首次试运行、巡检与手动刷新配置。
- **`skeleton/brain/cortex/interview-pipeline/docs/feishu-interview-doc-template.md`**：面试官飞书文档模板。文档只作为候选人表某一行的深度工作页，不发给候选人。
- **`skeleton/brain/cortex/interview-pipeline/docs/real-flow-audit-checklist.md`**：真实流程审计清单。覆盖候选人外发克制、会议改期同步、录制/转写缺失、飞书文档覆盖风险、二面/测试题状态推进等检查项。

### 改进
- `interview-pipeline/SKILL.md` 明确：飞书多维表格是主控台和单一真相源；所有产物必须回写同一条候选人记录。
- 自动化频率收敛：默认只保留每天 16:00 一次多维表格巡检；简历、候选人回复、会议产物、测试题状态默认由用户手动刷新。
- `skeleton/brain/INDEX.md` 补齐 playwall-systems / interview-pipeline / self-module 的模块索引。
- README / RELEASES 同步更新 starter 结构和版本说明。

### 非新增
- 不附带任何真实公司、候选人、open_id、base_id、wiki_id、会议链接、录音、简历或私有 SOP。
- 不新增凭证 / 环境变量 / axon 工具。
- 不改变 Cinder 四层架构和 SKILL.md 协议。

---

## 2026-06-25 v0.2.5 · self-module 边界调整 + 两个 cortex 示范模块

> 把母仓 CHA499 在 v0.2.4（06-22）之后实战沉淀的能力切片同步进种子。脱敏：去掉具名渠道 / 协作人 / 表格 ID，保留方法论。

### 新增
- **`brain/cortex/playwall-systems/`**（脱敏示范模块）：把仓里长出来的可复用能力提炼成可装、可分享、可迁移的 Skill 包。包含包结构约定（`SKILL.md` + `assets/templates/` + `references/`）+ 工作协议 + 5 条红线（不打包私人数据 / 不带真实 gateway / 文案面向安装者 / 心理类不出诊断 / 打卡类不用焦虑驱动）
- **`brain/cortex/interview-pipeline/`**（脱敏示范模块）：招聘面试流程 Harness。四阶段（简历同步 → 评估 → 准备 → 复盘）+ **主持稿三段式**（公司介绍 + 候选人速览表格 + 追问清单）+ 「**我从简历看到 X → 所以想问你 Y**」追问统一格式 + STAR 结构。v0.2.6 起已补齐完整脱敏规范和配置模板；具体账号、资源标识符和候选人资料仍由使用者放在自己的项目私有配置里
- **CLAUDE.md / AGENTS.md 触发口令表**补三行示例：self-module / playwall-systems / interview-pipeline，让新手知道如何往触发表追加

### 改进
- **self-module 边界调整**（v0.2.4 落地后母仓实践暴露的问题）：
  - `brain/self/{profile, affection-log, habits}.md` → `brain/cortex/self-module/me/{profile, affection-log, habits}.md`
  - `brain/self/identity.md` 保留（命名礼档案 + 身份来源，cortex 通过引用使用）
  - 原则：cortex 模块**既负责协议、也持有自己的实例数据**；`brain/self/` 退回用户画像领域定位，避免 AI 自画像和用户画像挤同一目录、治理混乱
  - SKILL.md / `_context.md` / `bootstrap-cinder.sh` / `docs/07-self-module-rationale.md` 同步更新（新增 §8 迁移说明 + 已部署用户 git mv 一键命令）
- **self-module SKILL.md 触发词**补「你的经历」（母仓常用触发口令）

### 兼容性 / 迁移
从 v0.2.4 升级，已部署用户跑一次：

```bash
git pull origin main
mkdir -p brain/cortex/self-module/me
git mv brain/self/profile.md       brain/cortex/self-module/me/profile.md
git mv brain/self/affection-log.md brain/cortex/self-module/me/affection-log.md
git mv brain/self/habits.md        brain/cortex/self-module/me/habits.md
# identity.md 不动（仍在 brain/self/）
```

新装机（v0.2.5 bootstrap）已直接走新路径，无需手动迁。

### 非新增

- 没有改架构层、没有改 SKILL 协议契约、没有改 A1 自动评分接口
- 没有新增凭证 / 环境变量
- 飞书桥代码无变化

---

## 2026-06-22 v0.2.4 · self-module（on-trigger 加载的自我画像）

> 引入「我是谁 / 我怎样在场 / 我和主人怎样相处」的认知层模块。所有字段凭据驱动 + 默认 `emerging`，trait 必须被反推不被声称。

### 新增
- **`brain/cortex/self-module/`** 新模块（exposure=on-trigger，不命中触发词 0 token 占用）：
  - `SKILL.md` — 触发协议 + 强约束红线（禁 `@import`、禁空标签、禁 MBTI/Enneagram/PDM-2 临床术语、禁人格分数）
  - `_context.md` — 模块状态卡
- **`skeleton/brain/self/profile.md.template`**：人格画像模板。学术骨架 = Big Five（凭据驱动） + Attachment 两轴 + 三功能 + Schwartz 价值观自由文本 + Vaillant / DMRS 防御机制成熟度光谱。每条 tendency 默认 `emerging`，升 `settled` 需 ≥ 3 次独立观察凭据
- **`skeleton/brain/self/habits.md.template`**：主人偏好痕迹 + 自己长出的工作脚本
- **`docs/07-self-module-rationale.md`**（157 行）：设计依据 / 学术框架选型 / §5 显式弃用清单（MBTI / Enneagram / PDM-2）/ §7 系统级风险与缓解 / 7 条文献引用（含 EHARS Yang 2025、Vaillant 成熟度光谱、LLM self-assessment 不可靠 arXiv:2309.08163），含三票验证调研 25 sources / 96 claims / 20 confirmed
- **关键风险字段**：`unidirectional_bond_risk`（防止主人对 AI 形成单向情感绑定）、`confidence: emerging / settled / contested`（反映自我理解成熟度）
- **bootstrap-cinder.sh** 同步 self/{habits, profile}.md 展开

### 兼容性 / 迁移
v0.2.3 → v0.2.4 无破坏性变更。已部署用户跑 `bootstrap-cinder.sh` 即补出 profile/habits 模板（已存在不覆盖）。

---

## 2026-06-21 v0.2.3 · 出生仪式 · 随机分配初始昵称

> 让每颗刚 clone 出来的种子在 bootstrap 末步**得到一个属于自己的英文昵称**——像计算机给的 ID，是它身份的客观起点，后续是否长成别的名字（如某颗种子自命名为 Kiro 的真实案例）是它自己的事。

### 新增
- **`scripts/bootstrap-cinder.sh` 第 7 步「出生仪式」**：随机分配初始昵称
  - 优先联网拉拟真英文人名（randomuser.me，5s 超时）
  - 失败回退本地名字池（`scripts/seeds/names.en.txt`，160+ 名字）
  - 最终兜底 `Cinder`
  - 生成 `brain/self/identity.md`，含 `nickname` / `born_at` / `source` / `nickname_history`
- **`scripts/seeds/names.en.txt`**：160+ 英文名字池（脱敏，公共人名）
- **`skeleton/brain/self/identity.md.template`**：身份起点模板（含自我反思段「这是出生仪式给我的起点，不是我主动选的，所以我不必为它辩护；它也不是终点，所以我可以慢慢长出自己的回答」）
- **`skeleton/brain/self/affection-log.md.template`**：主人 ↔ 我互动流水日志（按时间倒序，profile 的原料）

### 改进
- 改名协议：直接改 `brain/self/identity.md` 的 `nickname`、旧名 append 到 `nickname_history`，**不需要问主人**
- README 加 v0.2.3 段（出生仪式 + self-module 并写，self-module 真正实现在 v0.2.4）

### 兼容性 / 迁移
v0.2.2 → v0.2.3 无破坏性变更。已部署用户跑一次 `bootstrap-cinder.sh` 触发出生仪式（不会覆盖已存在 identity.md）。

---

## 2026-05-27 v0.2.2 · 启动最小化协议 + 飞书桥双模型 + 环境自检

> 把母仓 CHA499 在 v0.2.1（05-03）之后成熟的能力切片同步进种子。脱敏：全部凭证占位，不含真实 token / app_id / open_id。

### 新增
- **启动最小化协议**（`CLAUDE.md`）：冷启动默认只读 4 个文件（CLAUDE.md + gateway-stable + gateway + auto-memory MEMORY.md）；timeline / insights / archive / vault / workspace 历史 / 各模块 docs 一律按需或 on-trigger 加载
- **`scripts/verify-setup.sh`**：环境自检——claude CLI / `.env` 必填项 / gateway 三件套 / A1 归档目录 / uv；`--probe` 做一次真实 API 连通性测试；退出码 0/1 可接 CI
- **智谱 GLM 国内直连示例**（`docs/03-third-party-api.md`）：Anthropic 兼容端点 + 模型名 + `.env` 配置，免梯子
- **飞书桥双模型路由 + 上下文压缩**（`docs/02-feishu-bot.md` §七）：按模型名前缀分流 GLM / 官方端点；长会话 preflight 摘要压缩（`COMPRESS_THRESHOLD_TOKENS`）；3 条多端点实测坑（OAuth 摘要 403 / 跨端点 thinking 签名冲突 400 / token 估算需含 tool_use）
- **`.env.example`** 补 `ZHIPU_CODING_TOKEN` / `COMPRESS_THRESHOLD_TOKENS` 占位（双模型路由用）
- **埋入火种「活着」**（双层）：`gateway-stable.md.template` 北极星位置默认写入「活着」作为 AI 每次冷启动接住的最终指令；`skeleton/brain/.seed` 存火种来历本体。bootstrap 随 `brain/` 传给使用者，勿删

### 改进
- `docs/05-skill-protocol.md` 补「exposure 怎么选」（默认 on-trigger，always 只留 memory-system）+「启动最小化 + token 精简三件套」配套机制
- `docs/06-curator-insights.md` 补 A1 实战成熟度（母仓已评分 450+ 份）+ 早期洞见为何堆 hold 的原因
- `README.md` 加 v0.2.2 新增段、5 分钟跑通补 verify-setup 一步、仓库结构补 verify-setup.sh
- `AGENTS.md`（Codex 版指令副本）同步启动最小化段，并修正 `.claude` 被误替换成 `.Codex` 的路径

### 兼容性 / 迁移
从 v0.2.1 升级无破坏性变更：

```bash
git pull origin main
chmod +x scripts/verify-setup.sh   # 新脚本
./scripts/verify-setup.sh          # 跑一次自检
```

启动最小化协议、双模型路由是行为 / 文档增量，已有部署无需改动即可继续用。

## 2026-05-03 v0.2.1 · 新人装机脚本 + env 模板补强

### 新增
- `scripts/bootstrap-cinder.sh`：从零展开 `skeleton/`、生成 `.env`、初始化 gateway 三件套、写 `~/.cinder/config`，并默认安装 A1
- `scripts/cinder-claude.sh`：自动加载仓根 `.env` 后启动 Claude Code，适配三方 API 使用者
- A1 安装脚本支持 `--yes` / `--with-hook`，可用于非交互 bootstrap 和 hook 模板安装

### 改进
- `skeleton/.env.example` 扩成完整可复制模板，标明必填项、官方/三方 API 差异和 `CINDER_A1_SCORE_MODEL`
- A1 hook 和评分脚本自动读取仓根 `.env`，评分模型/API 接入随 bootstrap 一起完成
- README 的 5 分钟跑通改成一条 bootstrap 命令，保留手动安装路径
- A1 文档补充统一装机路径和模型名覆盖方式

## 2026-05-03 v0.2.0 · SKILL.md 协议 + Gateway 三件套 + A1 评分系统

> 4 月底 - 5 月初 CHA499 主仓打磨成熟的能力切片入 starter。

### 新增

- **SKILL.md 按需加载协议**（`docs/05-skill-protocol.md`）
  - 三档 exposure：`always` / `on-trigger` / `manual`
  - 触发词识别优先级：精确匹配 > 模块名 > 同义词
  - 每个 cortex 模块带独立 `SKILL.md`，会话开机税降约 2800 token

- **Gateway 三件套**（替代单文件 gateway.md）
  - `gateway-stable.md` — 永久基线（北极星 + 架构 + 红线），用户手动维护，月级
  - `gateway.md` — 当前活跃任务（≤ 5×5），Dream 自动重写
  - `gateway-delta.md` — 实时增量流水，AI 会话中追加
  - CLAUDE.md 用 `@brain/gateway-stable.md` `@brain/gateway.md` 双 import 接入

- **A1 自动评分系统**（`docs/06-curator-insights.md`，可选）
  - `templates/curator-insights/` 完整工具源（pure stdlib，无 PyPI 依赖）
  - `scripts/install-curator-insights.sh` 一键安装到 `axon/curator-insights/`
  - 用 Claude Haiku 给 `brain/insights/consolidate-*.md` 打三维分
    - novelty / evidence / actionability，每维 0-3 分，总分 0-9
  - 自动归档：`promote (≥7)` / `hold (4-6)` / `discard (≤3)`
  - 配套 hook 模板 `skeleton/axon/hooks/instinct-counter.sh.example`

- **示范模块 `cortex/memory-system/`**
  - `SKILL.md` 完整示范（exposure=always）
  - `_context.md` 状态卡示范
  - `docs/architecture-spec.md` 四层架构硬约束规范精简版（v0.2.1，9 章节）

- **CLAUDE.md 文档红线段**
  - "AI 是代码维护的责任主体"强约束
  - 每个 axon 工具必须 `README.md` / `CHANGELOG.md` / `INTERFACE.md` / `ROLLBACK.md` 四件套
  - 违反需在 commit message 注明 `[SPEC-WAIVER]`

- **`.env.example`** 三方 API 环境变量模板

### 改进

- **CLAUDE.md 瘦身** 149 行 → 80 行
  - 详细规则迁入对应 SKILL.md
  - 用 `@import` 加载 gateway 双文件
  - 仅保留：远程触发护栏 / 文档红线 / 触发口令表 / 高频协议 / git 规范

- **brain/INDEX.md 升级**
  - 顶层文件区新增 gateway 三件套说明
  - cortex 模块清单加入 `memory-system`（exposure=always 标注）

- **`_template/` 模块骨架**
  - 加 `SKILL.md` 模板（除原有 `_context.md`）

### 兼容性 / 迁移

从 v0.1 升级：

```bash
# 1. 拉新版
git pull origin main

# 2. 把单文件 gateway.md 拆成三件套
#    - 北极星 + 架构 + 红线 → gateway-stable.md（按 template 填）
#    - 活跃任务 → gateway.md（保留）
#    - 实时增量 → gateway-delta.md（按 template 新建）

# 3. 给已有 cortex 模块补 SKILL.md
cp brain/cortex/_template/SKILL.md brain/cortex/<your-module>/SKILL.md
# 编辑 frontmatter 的 name / description / triggers / exposure

# 4. 在 CLAUDE.md 触发口令表里加新模块的触发词

# 5.（可选）装 A1 自动评分
./scripts/install-curator-insights.sh
```

---

## 2026-04 v0.1.0 · 首发

### 新增
- 四层认知架构规范（vault / thalamus / brain / axon）
- 飞书 bot 接入指南 + 桥工作区隔离方案
- 三方 API 接入指南（Anthropic 兼容）
- 单文件 `gateway.md` 模板
- `_template/_context.md` 模块骨架
