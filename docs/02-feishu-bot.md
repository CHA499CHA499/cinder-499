# 飞书 bot 配置 + 踩坑速查

> 把 Claude Code 接到飞书，手机上随时和本机 Claude 对话。

## 一、它是什么

[feishu-claude-code](https://github.com/joewongjc/feishu-claude-code) 是开源 bot：

- WebSocket 长连接飞书，流式输出
- bot 在你本机起一个 Python 进程，用 subprocess 调起 `claude` CLI
- 飞书消息 → 进 bot → 调 Claude Code → 流式回飞书

**前置**：你的本机要常开（笔记本盖盖子睡眠会断），或挂在云主机上。

## 二、安装

```bash
git clone https://github.com/joewongjc/feishu-claude-code.git
cd feishu-claude-code
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# 编辑 .env，填飞书凭证 + ADMIN_OPEN_IDS
python3 main.py
```

## 三、飞书应用配置

1. 进 https://open.feishu.cn/app 创建**自建应用**
2. 凭证与基础信息 → 拿 `App ID` + `App Secret` 填进 `.env`
3. 权限管理 → 申请 scope（**严守最小原则**，见下方坑 5）
4. 事件订阅 → 订阅 `im.message.receive_v1`（私聊）+ `im.message.group_at_msg`（群 @）
5. 应用发布 → 提交版本审核（企业管理员审批）

## 四、ADMIN_OPEN_IDS 白名单

bot 默认会响应所有人。**必须开白名单**，否则任何人 @ 都能让你的 Claude Code 跑命令。

`.env` 里加：

```
ADMIN_OPEN_IDS=ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

拿你自己 open_id 的方法：在飞书企业里 @ 自己一次，bot 启动后会在 log 打出 sender_open_id。

## 五、5 大踩坑速查（实战教训）

### 坑 1: keychain app_secret 条目消失
**症状**：`lark` 命令全部 "not configured"
**原因**：macOS 系统更新或 keychain 被锁
**修复**：
```bash
pbpaste | lark config init --app-id cli_xxx --app-secret-stdin
lark auth login
```
（先复制 secret 到剪贴板再跑命令，不要先粘贴 secret 到终端被吞）

### 坑 2: lark strict-mode 严禁动
**症状**：`--identity bot-only` bind 把 strict-mode 设成 bot，挡住 user OAuth
**铁律**：**AI 严禁动 strict-mode**（lark-cli 文档明确禁止）
**人工修复**：`lark config strict-mode off`

### 坑 3: lark-cli 配置文件路径必须绝对
**症状**：`lark config bind` 报 "app id not found"
**原因**：配置文件用 `~/` 相对路径，lark-cli 1.0.18 要绝对路径
**修复**：sed 替换 `~/` 为 `/Users/<你的用户名>/`

### 坑 4: lark-cli event +subscribe 是常驻 daemon
**症状**：bot 连上飞书但 0 条消息
**原因**：飞书 single-instance lock 把事件随机分发，lark-cli 的 daemon 抢到就丢了
**排查**：
```bash
ps aux | grep lark
# 看到 event +subscribe daemon 就 kill
```
**纪律**：调研用完 `event +subscribe` 立刻 kill，不要让它后台常驻。

### 坑 5: OAuth scope 最小原则（最贵的教训）
**反例**：`--scope all --domain all` 一次申请所有 scope
- 后果：触发 16 个工单全部进管理员审批队列
- 全部被驳回，重新走流程，多花一周

**正确做法**：明确列出你要的 scope，按需逐个申请：

| 用途 | 最小 scope |
|---|---|
| 接私聊消息 | `im:message:receive_v1` |
| 接群 @ 消息 | `im:message.group_at_msg` |
| 拉群信息 | `im:chat` |
| user OAuth | `offline_access` + 你具体要用的 API scope |

## 六、launchd 接管（macOS 长跑）

bot 主进程退出后要自动重启，用 launchd：

```xml
<!-- ~/Library/LaunchAgents/com.your-org.feishu-claude.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.your-org.feishu-claude</string>
  <key>ProgramArguments</key>
  <array>
    <string>/path/to/feishu-claude-code/.venv/bin/python3</string>
    <string>/path/to/feishu-claude-code/main.py</string>
  </array>
  <key>WorkingDirectory</key>
  <string>/path/to/your-cinder/axon/bridge-feishu/workdir</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>ANTHROPIC_BASE_URL</key>
    <string>https://your-provider.com/v1</string>
    <key>ANTHROPIC_AUTH_TOKEN</key>
    <string>sk-xxxxx</string>
    <key>CLAUDE_SUBPROCESS_PROXY</key>
    <string></string>
  </dict>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/feishu-claude.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/feishu-claude.err</string>
</dict>
</plist>
```

加载：

```bash
launchctl load ~/Library/LaunchAgents/com.your-org.feishu-claude.plist
launchctl list | grep feishu-claude
tail -f /tmp/feishu-claude.log
```

## 七、安全护栏（必看）

bot 跑在你本机，能动你的代码、commit、装包。**必须做隔离**，详见 `04-isolation-pattern.md`。
