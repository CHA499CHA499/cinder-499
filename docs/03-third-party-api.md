# 三方 API 接入指南

> 没有 Claude Max/Pro 订阅时怎么办。

## 背景

Claude Code CLI 默认支持两种认证：
1. Claude Max/Pro 订阅（个人账号）
2. **Anthropic 兼容 API Key**（OneAPI / packycode / Anyrouter / Aihubmix / DMXAPI 等）

本指南讲第二种。

## 一、Claude Code CLI 端配置（一次性）

编辑 `~/.zshrc` 或 `~/.bashrc`：

```bash
# 三方 Anthropic 兼容 API
export ANTHROPIC_BASE_URL="https://your-provider.com/v1"
export ANTHROPIC_AUTH_TOKEN="sk-xxxxxxxxxxxxx"
```

`source ~/.zshrc` 后验证：

```bash
claude --print "say hi" --model claude-sonnet-4-6
```

能正常返回就 OK。

如果你使用仓根 `.env`，推荐用 Cinder 启动脚本，它会自动加载 `.env`：

```bash
./scripts/cinder-claude.sh
```

它也会把 `.env` 里的 `DEFAULT_MODEL` 自动传给 `claude --model`。临时覆盖模型：

```bash
./scripts/cinder-claude.sh --model claude-sonnet-4-6
```

### 示例：智谱 GLM（国内直连，省梯子）

如果你在国内、不想折腾代理，智谱 GLM 提供了 **Anthropic 兼容端点**，可以直接喂给 Claude Code CLI：

```bash
# .env（或 ~/.zshrc）
ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic
ANTHROPIC_AUTH_TOKEN=<你的智谱 API Key>   # 控制台获取，绝不要提交进仓库
DEFAULT_MODEL=glm-5.1                      # 先在智谱控制台确认你账号可用的 model id
```

- 端点 `open.bigmodel.cn` 国内直连，无需梯子
- 模型名按智谱当前提供的填（GLM 系列名字会随版本变，以控制台为准）
- 这套配置同样适用于飞书 bot 子进程（见 `02-feishu-bot.md`）

> 母仓的飞书 bot 主控就跑在 GLM 上：日常对话用便宜的 GLM，需要强推理时再切官方 Claude（见 `02-feishu-bot.md` 的「双模型路由」）。

## 二、飞书 bot 端额外改动

bot subprocess 默认继承父进程环境（`os.environ.copy()`），所以**只要 launchd plist / systemd 里 export 了上面两个变量，subprocess 自动带上**。

但有 **2 个坑**：

### 坑 1: CLAUDE_SUBPROCESS_PROXY 默认值

[feishu-claude-code/claude_runner.py](https://github.com/joewongjc/feishu-claude-code) 默认给 subprocess 注入 `HTTPS_PROXY=http://127.0.0.1:7897`（原作者用本地代理访问 api.anthropic.com）。

如果你的三方 API 在国内（直连即可），**必须把代理关掉**，否则会走错链路：

`.env` 里加：

```
CLAUDE_SUBPROCESS_PROXY=
```

或 launchd plist 的 `EnvironmentVariables` 段把它设成空字符串（见 `02-feishu-bot.md` §六）。

### 坑 2: 模型名要对齐三方 API

`.env` 里 `DEFAULT_MODEL=claude-sonnet-4-6`。

不同三方厂商支持的 model id 不同。先在三方 API 控制台确认你能调哪些 model：

```bash
curl https://your-provider.com/v1/models \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN"
```

确认后改 `.env` 的 `DEFAULT_MODEL`。

## 三、成本估算（粗略）

| 方案 | 月成本 | 优点 | 缺点 |
|---|---|---|---|
| 三方中转 | ¥30-500（按用量） | 国内直连快，不用梯子 | 厂商可能跑路 |
| 自建 OneAPI + 官方 API Key | 透明（按 Anthropic 计费） | 最稳 | 需要梯子稳定 |
| 直连 api.anthropic.com | 同上 | 最快 | 需要梯子稳定 |

具体选哪家自己评估，本指南不推荐特定厂商。

## 四、不要做的

- 不要把 API Key 写进 git 跟踪的文件（用 `.env`，并确认 `.gitignore` 包含 `.env`）
- 不要在群聊截图里暴露 `ANTHROPIC_AUTH_TOKEN`
- 不要在飞书 bot 工作区的 CLAUDE.md 里写 API Key（详见 `04-isolation-pattern.md`）
