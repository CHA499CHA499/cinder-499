---
title: hirebase-project-config-template
type: note
permalink: cinder/cortex/interview-pipeline/docs/recruiting-project-config-template
---

# HireBase Harness 项目配置模板

> 复制本模板，为每个招聘项目单独填写。不要把 token、cookie、密钥、个人账号凭证写进本文档；只记录资源名称、用途和是否已配置。

---

## 1. 项目信息

| 配置项 | 内容 |
|---|---|
| 项目名称 | `{project_name}` |
| 公司/团队介绍文档 | `{company_profile_doc}` |
| 岗位画像文档 | `{job_profile_doc}` |
| 招聘负责人 | `{owner}` |
| 面试官列表 | `{interviewers}` |
| 默认面试时长 | `{duration_minutes}` |
| 是否有测试题 | `{yes_or_no}` |

---

## 2. 前置环境体检

| 检查项 | 状态 | 备注 |
|---|---|---|
| Node.js | `{configured / missing}` | `{version_or_action}` |
| Python | `{configured / missing}` | `{version_or_action}` |
| 包管理器 | `{configured / missing}` | `{pnpm/npm/uv/etc}` |
| 招聘平台 CLI | `{configured / missing}` | `{provider}` |
| 飞书 CLI | `{configured / missing}` | `{provider}` |
| 会议平台 CLI | `{configured / missing}` | `{provider}` |
| 招聘平台登录态 | `{configured / missing}` | 不记录敏感值 |
| 飞书登录态 | `{configured / missing}` | 不记录敏感值 |
| 会议平台登录态 | `{configured / missing}` | 不记录敏感值 |
| 会议录制权限 | `{enabled / disabled}` | 必须可用 |
| 会议转写权限 | `{enabled / disabled}` | 必须可用 |

---

## 3. 平台资源

| 资源 | 配置 |
|---|---|
| 招聘平台 | `{provider}` |
| 候选人消息入口 | `{channel_name_or_description}` |
| 飞书多维表格主控台 | `{base_name_or_link}` |
| 候选人数据表 | `{table_name_or_link}` |
| 面试稿文档空间 | `{doc_space_name_or_link}` |
| 日历/会议创建方式 | `{calendar_or_meeting_provider}` |
| 转写拉取方式 | `{transcript_provider}` |

---

## 4. 飞书多维表格字段

| 字段 | 类型 | 是否必须 |
|---|---|---|
| 候选人 | 文本 | 必须 |
| 来源 | 单选/文本 | 必须 |
| 简历 | 附件 | 必须 |
| AI 摘要 | 长文本 | 必须 |
| 评分 | 数字 | 必须 |
| 星级 | 单选 | 必须 |
| 风险 | 多选/文本 | 必须 |
| 推荐动作 | 单选 | 必须 |
| 当前状态 | 单选 | 必须 |
| 一面时间 | 日期时间 | 建议 |
| 一面会议链接 | URL | 建议 |
| 一面主持稿 | URL | 建议 |
| 一面转写/录音 | 附件/URL | 建议 |
| 一面复盘 | 长文本 | 建议 |
| 测试题状态 | 单选 | 按需 |
| 二面时间 | 日期时间 | 按需 |
| 二面会议链接 | URL | 按需 |
| 二面主持稿 | URL | 按需 |
| 二面转写/录音 | 附件/URL | 按需 |
| 二面复盘 | 长文本 | 按需 |
| 最近一次外联 | 长文本 | 建议 |
| 候选人回复 | 长文本 | 建议 |
| 是否确认参会 | 单选/勾选 | 建议 |

---

## 5. 飞书多维表格视图

| 视图 | 筛选/排序 | 是否必须 |
|---|---|---|
| 全部候选人 | 入表时间倒序 | 必须 |
| 待筛选 | 当前状态=待筛选，评分/星级倒序 | 必须 |
| 待约面 | 当前状态包含待约，评分/星级倒序 | 必须 |
| 今日面试 | 面试日期=今天，时间升序 | 必须 |
| 面后待复盘 | 已完成面试但复盘为空 | 必须 |
| 测试题跟进 | 测试题状态未终结 | 按需 |
| 二面池 | 当前状态=二面待约/二面已约 | 按需 |
| 已终结 | 当前状态=通过/不通过/放弃 | 必须 |

---

## 6. 状态枚举

```text
待筛选
一面待约
一面已约
一面已完成
测试题未发放
测试中
已提交待评估
测试题通过
测试题不通过
二面待约
二面已约
二面已完成
通过
不通过
放弃
```

---

## 7. 消息模板

### 收到简历

```text
已收到你的简历，我们会尽快查看。后续如有合适时间，会继续和你沟通安排。
```

### 询问是否有空

```text
你好，请问你 {日期} {时间段} 是否方便做一次线上沟通？预计 {时长} 分钟左右。
如果这个时间不方便，也可以告诉我你方便的时间段。
```

### 确认会议

```text
好的，那我们约在：
时间：{日期} {开始时间}-{结束时间}
会议：{会议链接}

到时麻烦提前 3 分钟进入会议，保持麦克风和网络可用。谢谢。
```

### 测试题通知

```text
这里有一个小任务需要你完成：
{测试题说明}

提交方式：{提交方式}
截止时间：{截止时间}
如有环境问题，可以直接回复我。
```

---

## 8. 首次试运行

| 步骤 | 结果 |
|---|---|
| 样例简历解析 | `{pass / fail}` |
| 样例候选人入表 | `{pass / fail}` |
| 样例评分生成 | `{pass / fail}` |
| 多维表格视图检查 | `{pass / fail}` |
| 样例面试稿生成 | `{pass / fail}` |
| 面试稿链接回填表格 | `{pass / fail}` |
| 测试会议创建 | `{pass / fail}` |
| 录制/转写开关验证 | `{pass / fail}` |
| 转写拉取验证 | `{pass / fail}` |
| 转写/复盘回填表格 | `{pass / fail}` |

只有全部关键项通过后，才开启真实候选人监听。

---

## 9. 巡检与手动刷新配置

飞书多维表格是主控台，因此必须配置每日巡检。默认每天下午 4 点自动检查一次；其他时间如需更新，由系统提醒用户手动触发刷新。

| 机制 | 默认触发 | 当前项目配置 | 游标字段 |
|---|---:|---|---|
| 每日多维表格巡检 | 每天 16:00 | `{16:00_or_custom_daily_time}` | `last_daily_audit_at` |
| 手动刷新简历 | 用户指令 | `{enabled / disabled}` | `last_resume_processed_at` |
| 手动刷新候选人回复 | 用户指令 | `{enabled / disabled}` | `last_recruiting_message_at` |
| 手动刷新会议产物 | 用户指令 | `{enabled / disabled}` | `last_meeting_checked_at` |
| 手动刷新测试题 | 用户指令 | `{enabled / disabled}` | `last_test_submission_checked_at` |

| 配置项 | 内容 |
|---|---|
| 游标存放位置 | `{local_file_or_base_table}` |
| 自动化日志位置 | `{local_log_or_base_log_table}` |
| 巡检失败通知方式 | `{feishu_message_or_manual_review}` |
| 手动刷新提醒方式 | `{feishu_message_or_cli_prompt}` |
| 是否允许自动写表 | `{yes_or_no}` |
| 需要人工确认的状态 | `{通过 / 不通过 / 二面 / 发测试题 / offer}` |

巡检验收标准：

| 检查项 | 结果 |
|---|---|
| 能扫描待筛选记录 | `{pass / fail}` |
| 能发现缺主持稿/缺会议链接 | `{pass / fail}` |
| 能发现面后缺转写/缺复盘 | `{pass / fail}` |
| 能写自动化日志 | `{pass / fail}` |
| 能保存并读取游标 | `{pass / fail}` |
