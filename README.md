# Cinder Starter

四层认知架构 + 飞书 Claude Code 双向桥的最小启动模板。

## 它是什么

一种把 AI 协作上下文按四层组织的工程化方案：

- **vault/** — 完整无损档案（WORM，append-only）
- **thalamus/** — 半加工摘要 + 索引
- **brain/** — 认知层（gateway / cortex / concepts / views / timeline / workspace / archive / insights / evals）
- **axon/** — 执行层（bridge / curator / keeper / mcp 工具）

数据流单向：**vault → thalamus → brain → axon → 外部世界**。禁止反向。

完整规范见 `docs/01-architecture.md`。

## 5 分钟跑通

```bash
git clone --single-branch --branch CinderT <this-repo> my-cinder
cd my-cinder
cp -r skeleton/* .            # 把骨架展开到根目录
rm -rf skeleton                # 移除模板目录
```

然后：

1. 配 Claude Code CLI（三方 API）→ `docs/03-third-party-api.md`
2. （可选）配飞书 bot → `docs/02-feishu-bot.md`
3. 把根目录 `CLAUDE.md` 加进 Claude Code → 开始用

## 你需要准备

| 项 | 说明 |
|---|---|
| macOS / Linux | Windows 未测试 |
| Claude Code CLI | `npm i -g @anthropic-ai/claude-code` |
| Anthropic 兼容 API | 三方中转或官方 API Key 任选 |
| Python 3.11+ | 飞书 bot 用，不接可不装 |
| 飞书企业账号 | 飞书 bot 用，不接可不申请 |

## 文档地图

| 文档 | 内容 |
|---|---|
| `docs/01-architecture.md` | 四层架构规范（强约束 + 反模式） |
| `docs/02-feishu-bot.md` | 飞书 bot 配置 + 5 大踩坑速查 |
| `docs/03-third-party-api.md` | 三方 API 接入指南（无 Claude Max 订阅） |
| `docs/04-isolation-pattern.md` | 桥工作区隔离方案（prompt injection 防御） |

## 不要做的

- 不要 fork 后把 `brain/self/` 公开（这是私人画像，保留本地）
- 不要把 `vault/` 推到公开仓（档案层可能含敏感）
- 不要直接编辑 `brain/cortex/methodology.md`（必须从 insights 经审核更新）
- 不要在飞书 bot 工作区里 `git commit/push`（详见 `docs/04-isolation-pattern.md`）

## License

MIT
