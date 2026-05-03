# SKILL.md 协议

> Cinder cortex 模块的"按需加载"机制。把每个模块的上下文打包成 `SKILL.md`，AI 按触发词决定加载——避免每轮对话都把全量项目知识塞进 prompt。

## 为什么需要

没有 SKILL.md 协议时：
- 所有模块文档堆在 CLAUDE.md 或 gateway.md 里
- 每轮对话开机税：3000-5000 token 加载用不到的内容
- 模块越多越糟

有 SKILL.md 协议时：
- 每个模块自带独立的 `SKILL.md`，含触发词清单
- 会话启动只加载 `exposure=always` 的（一般 1-2 个）
- 谈到具体模块时，AI 识别触发词 → 现场加载对应 SKILL.md
- 实测开机税从 ~5000 token 降到 ~2200 token

## 三档 exposure

```yaml
exposure: always      # 会话启动时自动注入（用于元模块：memory-system）
exposure: on-trigger  # 识别到触发词时加载（默认，大部分模块用这个）
exposure: manual      # 用户明确请求时加载（很少用，给重型工作流准备）
```

## SKILL.md frontmatter 完整字段

```yaml
---
name: <module-slug>            # 必填，与目录名一致
description: <≤80字>            # 必填，AI 看这个决定要不要加载
triggers:                       # on-trigger 必填，匹配关键词清单
- <关键词 1>
- <关键词 2>
- <模块同义词>
exposure: on-trigger            # 必填：always | on-trigger | manual
requires_files:                 # 可选，加载本 SKILL.md 后跟着读哪些文件
- _context.md
- docs/spec.md
arch_constraints:               # 可选，本模块涉及的架构约束（跨模块红线）
- §二.6 methodology 防污染
permalink: cinder/cortex/<slug>/skill   # 可选，给 mcp-brain 用
---
```

## 触发词识别优先级

1. **精确匹配**优先（"figma" 命中 figma 模块）
2. **模块名匹配**次之（"设置中心" 命中 settings-unified）
3. **同义词**最后（"设计稿" 命中 figma 模块的 triggers）

同一对话中已加载的 SKILL.md 不重复加载。

## CLAUDE.md 里怎么写触发表

CLAUDE.md 里维护一份"触发口令 → SKILL.md"映射表，AI 看到对应词时主动加载：

```markdown
## 触发口令 → 加载对应 SKILL.md

| 用户/上下文出现 | 加载 |
|---|---|
| UI / 设计稿 / 组件 | `brain/cortex/figma/SKILL.md` |
| 记忆 / 架构 / Dream | `brain/cortex/memory-system/SKILL.md` |
| 飞书 / lark-cli | `brain/cortex/feishu-integration/SKILL.md` |
```

## SKILL.md 写作要点

**好的 SKILL.md**：
- description 一句话说清楚"我是谁，加载我能拿到什么"
- triggers 覆盖用户口语化说法（不只是模块名）
- 正文 100-300 行，含强约束 + 操作协议 + 写入规则 + 禁止操作
- 不重复架构总规范（指向 docs/01-architecture.md 即可）

**坏的 SKILL.md**：
- description 写"模块文档"（无信息量）
- 把整个模块所有 docs 复制进来（违背"按需加载"初衷）
- triggers 只写模块名（用户说同义词时加载不上）

## 新增模块的工作流

```bash
# 1. 复制模板
cp -r brain/cortex/_template brain/cortex/<your-module>

# 2. 改 SKILL.md 的 frontmatter（name / description / triggers / exposure）

# 3. 在 CLAUDE.md 触发口令表里加一行

# 4. 在 brain/INDEX.md 的 cortex 模块清单里加一行
```

完成。下次会话 AI 看到对应触发词就会自动加载。
