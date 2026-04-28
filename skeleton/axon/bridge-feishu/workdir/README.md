# axon/bridge-feishu/workdir

> 飞书 bot 的 Claude subprocess **cwd 锁这里**，与主项目 brain/ 物理隔离。

## 快速上手

| 想做的事 | 怎么做 |
|---|---|
| 看 IM 角色定位 | 读 [CLAUDE.md](./CLAUDE.md) |
| 看实际 allow 权限边界 | 读 [.claude/settings.local.json](./.claude/settings.local.json)（首次需从 .example 复制） |
| 查 bot 日志 | `tail -f /tmp/feishu-claude.log` |

## 物理布局

```
axon/bridge-feishu/
├── workdir/                ← Claude subprocess cwd 在这（隔离工作区）
│   ├── CLAUDE.md           ← IM 角色定位 + 行为约束（无条件优先）
│   ├── README.md           ← 本文件
│   ├── .claude/
│   │   ├── settings.local.json.example   ← allow list 模板（脱敏）
│   │   └── settings.local.json           ← 你的真实权限（git ignored）
│   └── scratch/            ← Claude 私人草稿（写入无限制）
└── （未来 bot 物理迁过来时，源码也会在 axon/bridge-feishu/ 下）
```

bot 实际位置：clone [feishu-claude-code](https://github.com/joewongjc/feishu-claude-code) 到任意位置。

## 边界速查

| 资源 | IM Claude 权限 |
|---|---|
| 主项目代码（业务代码 / src） | ❌ |
| `<主项目根>/brain/cortex/*/_context.md` | ❌ |
| `<主项目根>/brain/cortex/methodology.md` | ❌ |
| `<主项目根>/brain/gateway.md` | ❌（只读） |
| `<主项目根>/brain/inbox/*.im.md` | ✅（写） |
| `<主项目根>/brain/workspace/**` | ✅（写） |
| `Bash(git commit/push/merge)` | ❌ |
| `Bash(lark *)` | ✅ |
| `WebSearch / WebFetch` | ✅ |
