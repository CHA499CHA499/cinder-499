# Cinder Starter · CHANGELOG

> 仅记录**对外可观察的变更**：架构规范 / 协议 / 命令行接口 / 文件结构。
> 内部重构、注释改名不进 changelog。

---

## 2026-06-25 v0.2.5 · self-module 边界调整 + 两个 cortex 示范模块

> 把母仓 CHA499 在 v0.2.4（06-22）之后实战沉淀的能力切片同步进种子。脱敏：去掉具名渠道 / 协作人 / 表格 ID，保留方法论。

### 新增
- **`brain/cortex/playwall-systems/`**（脱敏示范模块）：把仓里长出来的可复用能力提炼成可装、可分享、可迁移的 Skill 包。包含包结构约定（`SKILL.md` + `assets/templates/` + `references/`）+ 工作协议 + 5 条红线（不打包私人数据 / 不带真实 gateway / 文案面向安装者 / 心理类不出诊断 / 打卡类不用焦虑驱动）
- **`brain/cortex/interview-pipeline/`**（脱敏示范模块）：招聘面试流程 Harness。四阶段（简历同步 → 评估 → 准备 → 复盘）+ **主持稿三段式**（公司介绍 + 候选人速览表格 + 追问清单）+ 「**我从简历看到 X → 所以想问你 Y**」追问统一格式 + STAR 结构。`docs/interview-sop.md` 因含私密配置（协作人 open_id、表格 ID）不附模板，首次启用按 SKILL.md 框架手起
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
