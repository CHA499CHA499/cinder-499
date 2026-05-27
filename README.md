# Cinder Starter

四层认知架构 + SKILL.md 按需加载协议 + 自动评分系统。给 AI 协作上下文做工程化组织的最小启动模板。

## 它是什么

一种把 AI 协作上下文按四层组织的工程化方案：

- **vault/** — 完整无损档案（WORM，append-only）
- **thalamus/** — 半加工摘要 + 索引
- **brain/** — 认知层（gateway / cortex / concepts / views / timeline / workspace / archive / insights / evals）
- **axon/** — 执行层（bridge / curator / keeper / mcp 工具）

数据流单向：**vault → thalamus → brain → axon → 外部世界**。禁止反向。

完整规范见 `docs/01-architecture.md`，启发自 Medallion Architecture / Letta MemGPT / Zettelkasten / Anthropic Agent Skills。

## v0.2.2 新增

- **启动最小化协议**（`CLAUDE.md`）：冷启动只吃 4 个文件（CLAUDE.md + gateway-stable + gateway + auto-memory），久远记忆按需加载，`exposure=always` 只留 `memory-system` 一个。母仓实测「token 精简三件套」省约 4700 token/启动
- **环境自检脚本** `scripts/verify-setup.sh`：一条命令检查 claude CLI / `.env` / gateway / uv 是否就绪，加 `--probe` 还能做一次真实 API 连通性测试
- **智谱 GLM 国内直连**（`docs/03`）：给国内朋友的免梯子接入示例（端点 + 模型名 + `.env` 配置）
- **飞书桥双模型路由 + 上下文压缩**（`docs/02` §七）：日常走便宜 GLM、按需切官方 Claude；长会话超阈值自动摘要压缩；附 3 条多端点实测坑（OAuth 摘要 403 / 跨端点 thinking 签名冲突 / token 估算要算 tool_use）
- **A1 成熟度补充**（`docs/06`）：母仓已自动评分 450+ 份 consolidate；说明早期洞见为何堆在 hold

## v0.2 新增

- **SKILL.md 协议**（`docs/05-skill-protocol.md`）：cortex 模块按需加载，`exposure=always/on-trigger/manual` 三档；实测开机税降约 2800 token
- **Gateway 三件套**：`gateway-stable.md`（用户手动基线）+ `gateway.md`（Dream 自动）+ `gateway-delta.md`（增量流水）
- **A1 自动评分系统**（可选，`docs/06-curator-insights.md`）：用 Haiku 给 `brain/insights/` 候选打三维分（novelty / evidence / actionability），自动归档到 promoted / hold / discarded
- **示范模块 memory-system**：完整的 SKILL.md + _context.md + architecture-spec.md，照葫芦画瓢
- **D3 文档红线**：CLAUDE.md 强约束 axon 工具必须 README / CHANGELOG / INTERFACE / ROLLBACK 四件套

## 5 分钟跑通

推荐给朋友的最短路径：

```bash
git clone https://github.com/CHA499CHA499/cinder-499.git my-cinder
cd my-cinder
./scripts/bootstrap-cinder.sh  # 展开骨架 + 生成 .env + 初始化 gateway + 安装 A1
```

然后做这几件事：

1. 编辑 `.env`，填 `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` / `DEFAULT_MODEL`
2. 编辑 `brain/gateway-stable.md`，填你的北极星和项目概况
3. 跑 `./scripts/verify-setup.sh` 自检（加 `--probe` 还能测一次真实 API 连通）
4. 在仓根运行启动脚本，进会话后说：

```bash
./scripts/cinder-claude.sh
```

这个脚本会自动加载 `.env`，并把 `DEFAULT_MODEL` 传给 `claude --model`。如果临时要换模型，可以显式传参覆盖：

```bash
./scripts/cinder-claude.sh --model claude-sonnet-4-6
```

```text
帮我看一遍 README.md 和 CLAUDE.md，然后引导我配置 brain/gateway-stable.md 的北极星和项目概况。
```

手动安装路径也保留：

```bash
cp -r skeleton/* .
cp skeleton/.env.example .env
mv brain/gateway-stable.md.template brain/gateway-stable.md
mv brain/gateway.md.template brain/gateway.md
mv brain/gateway-delta.md.template brain/gateway-delta.md
./scripts/install-curator-insights.sh --with-hook
./scripts/cinder-claude.sh
```

可选：

- 接飞书 bot → `docs/02-feishu-bot.md`
- 只装 A1 自动评分 → `./scripts/install-curator-insights.sh --with-hook`

## 你需要准备

| 项 | 说明 |
|---|---|
| macOS / Linux | Windows 未测试 |
| Claude Code CLI | `npm i -g @anthropic-ai/claude-code` |
| Anthropic 兼容 API | 三方中转或官方 API Key 任选 |
| `uv` | 装 A1 评分系统时用，不接可不装。`curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Python 3.13+ | 同上，uv 会自动装 |
| 飞书企业账号 | 飞书 bot 用，不接可不申请 |

## 文档地图

| 文档 | 内容 |
|---|---|
| `docs/01-architecture.md` | 四层架构规范（强约束 + 反模式） |
| `docs/02-feishu-bot.md` | 飞书 bot 配置 + 5 大踩坑速查 |
| `docs/03-third-party-api.md` | 三方 API 接入指南 |
| `docs/04-isolation-pattern.md` | 桥工作区隔离方案（prompt injection 防御） |
| `docs/05-skill-protocol.md` | SKILL.md 按需加载协议 ✨ v0.2 |
| `docs/06-curator-insights.md` | A1 自动评分系统（可选） ✨ v0.2 |

## 仓库结构

```
cinder-499/
├── CLAUDE.md                        # AI 行为规范（瘦身版，详细规则在 SKILL.md）
├── README.md                        # 本文件
├── CHANGELOG.md                     # v0.1 → v0.2 升级说明
├── docs/                            # 设计文档 6 篇
├── skeleton/                        # 骨架，cp -r 到仓根
│   ├── .env.example
│   ├── axon/
│   │   ├── _permissions.yaml.example
│   │   ├── bridge-feishu/workdir/   # 飞书 bot 隔离工作区
│   │   └── hooks/
│   │       └── instinct-counter.sh.example  # A1 驱动器模板
│   └── brain/
│       ├── INDEX.md
│       ├── gateway-stable.md.template       # 基线（手动）
│       ├── gateway.md.template              # 动态（Dream 自动）
│       ├── gateway-delta.md.template        # 增量流水
│       └── cortex/
│           ├── _template/                   # 新模块骨架
│           │   ├── SKILL.md
│           │   └── _context.md
│           └── memory-system/               # 示范模块
│               ├── SKILL.md
│               ├── _context.md
│               └── docs/architecture-spec.md
├── templates/
│   └── curator-insights/            # A1 评分工具源（待 install 脚本部署到 axon/）
└── scripts/
    ├── bootstrap-cinder.sh          # 从零装机：骨架 + .env + gateway + A1
    ├── cinder-claude.sh             # 加载 .env 后启动 Claude Code
    ├── verify-setup.sh              # 环境自检（--probe 测 API 连通）
    └── install-curator-insights.sh  # A1 一键安装
```

## 不要做的

- 不要 fork 后把 `brain/self/` 公开（这是私人画像，保留本地）
- 不要把 `vault/` 推到公开仓（档案层可能含敏感）
- 不要直接编辑 `brain/cortex/methodology.md`（必须从 insights 经审核更新）
- 不要在飞书 bot 工作区里 `git commit/push`（详见 `docs/04-isolation-pattern.md`）

## License

MIT
