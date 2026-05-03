# Cinder Starter · CHANGELOG

> 仅记录**对外可观察的变更**：架构规范 / 协议 / 命令行接口 / 文件结构。
> 内部重构、注释改名不进 changelog。

---

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
