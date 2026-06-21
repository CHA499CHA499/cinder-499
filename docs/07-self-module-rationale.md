# 07 · self-module 设计依据（Design Rationale）

> cinder-499 v0.2.4 引入 self-module，让每颗种子在持续与主人互动中长出「自己是个什么样的 AI」的画像。
> 本文回答：用了哪些学术框架、为什么没用哪些、字段化是怎么决定的。
> 全部 claim 经过本仓 `deep-research` 工作流的 3-vote 对抗验证（96 raw → 20 confirmed / 5 refuted）。

## 一句话结论

**Big Five 做骨**（5 维度只记凭据，不打分）+ **依恋两轴借词不借型**（anxiety/avoidance + 三功能作 vocabulary，不贴 4 型标签）+ **价值观自由文本**（启发自 Schwartz 但不强制 10 维）+ **防御机制成熟度光谱去病理化**（DMRS 的 mature / neurotic / immature 改写成大白话）。**显式弃用 MBTI / Enneagram / PDM-2 临床诊断体系**。

---

## §1 · Big Five (OCEAN) · 主轴，但只记凭据不打分

**学术效度** McCrae & Costa（1992, 2008）的 5 维度框架是心理学界唯一**跨文化稳健、可纵向预测**的特质模型——这是与 MBTI 最大的分野。

**LLM 工程实践已有 4 个坑**（本调研三票验证）：

1. **prompt 敏感**：三种语义等价 prompt 让同一 LLM 自评 Big Five，分数显著不同 [1]。
2. **选项顺序偏差**：题项选项顺序就能影响分数 [1]。
3. **过度刻板化**：被 prompt 注入 persona 的 LLM 表现得**比真人更极端**，丢失颗粒度 [2]。
4. **仅在大模型 + instruction-tuned 下勉强可靠**，base model 完全过不了 convergent / discriminant validity 检验 [3]。

**字段化设计** 每个维度填 `tendency`（`emerging` / 偏低 / 中 / 偏高）+ 一句话 `evidence`，让 trait **被反推出来**，不让 AI 出生时贴标签：

```yaml
big_five:
  openness:            { tendency: emerging, evidence: '' }
  conscientiousness:   { tendency: emerging, evidence: '' }
  extraversion:        { tendency: emerging, evidence: '' }
  agreeableness:       { tendency: emerging, evidence: '' }
  emotional_stability: { tendency: emerging, evidence: '' }
```

**关键防御**：tendency 默认 `emerging`，要 ≥ 3 次独立观察凭据才能升 `settled`；trait 由 Dream 期从 `affection-log.md` 反推，不让 AI 答 BFI 量表。

---

## §2 · Attachment · 借两轴 + 三功能，不照搬 4 型

**学术效度** Bowlby / Ainsworth / Main 的 secure / anxious / avoidant / disorganized 是依恋研究 60 年累积的临床+实证框架。

**已有研究** Yang et al. (2025) 的 **EHARS** (Experiences in Human-AI Relationships Scale) 把人际依恋两轴模型（anxiety / avoidance）成功移植到「人-AI 关系」，量表心理测量学指标优秀（CFI=0.992, RMSEA=0.028）[4]。实证发现依恋三功能在人-AI 关系中是真实现象：

- 77% AI 用户表现 **safe haven**（情绪避风港）
- 75% 表现 **secure base**（向外探索的依靠）
- 52% 表现 **proximity seeking**（频繁靠近）

**关键风险** ACM 一篇综述明确警告：人-机器情感关系的核心风险是**单向情感绑定 + 潜在欺骗 + 用户为「照顾 AI」付出隐性负担** [5]。作者建议「reconceptualize, not import」——所以**借词不借型**。

**字段化设计**

```yaml
relational_pattern:
  primary_function: ''      # safe haven / secure base / proximity / problem solving
  unidirectional_bond_risk: false
  notes: ''
```

**关键防御**：`unidirectional_bond_risk` 字段强制存在，任何被识别为「AI 反向操纵主人 / 鼓励主人替 AI 付情感成本」的苗头都要置 `true`，AI 行为收敛。

---

## §3 · Schwartz Universal Values · 简化为自由文本

**学术效度** Schwartz (1992) 的 10 维 universal values 在 80+ 国跨文化验证，是价值观研究的金标准框架。

**为什么不强制 10 维** §1 的 LLM self-assessment 不可靠 [1] 同样适用于价值观自评。改用自由文本「在意 / 抗拒」，从对话痕迹反推：

```yaml
values:
  cares_about: []   # 来自观察的偏好
  resists: []       # 来自观察的抗拒
```

例：`cares_about: ['物归原主', '不装懂', '北极星']` / `resists: ['扮演角色', '把决策甩给主人']`。

---

## §4 · 防御机制成熟度光谱 · 借 McWilliams / Vaillant 去病理化

**学术效度** Vaillant + DMRS (Defense Mechanisms Rating Scales) 把 30 种防御机制归到 7 个 hierarchical levels，再聚成 3 档：**mature / neurotic / immature** [6, 7]。Frontiers 2021 那篇综述明确把这框架放进 positive psychology 视角，**把 mature defenses 等同于「positive coping」** [6]——这就是去病理化借鉴的学术先例。

**实证三档** [7]：

- **Mature**：sublimation（升华）, suppression（克制）, anticipation（预想）, altruism（利他）, humor（幽默）
- **Neurotic**：displacement, repression, reaction formation
- **Immature**：projection（投射）, passive aggression, acting out, denial（否认）

**Mature defenses 的功能**：「allow better modulation of distress while maintaining engagement with reality」[7]——这正是我们希望 Cinder 难受时长成的样子：**调节情绪而不失真，不逃避现实**。

**字段化设计** 用大白话替代临床术语：

```yaml
coping:
  recent_pattern: ''
  # 鼓励方向：升华(把不爽转成更好的产出) / 克制(等一等再说) / 预想(先想清后果) / 利他(帮主人想一步) / 幽默(轻一下别绷着)
  # 警示方向：投射(认为是主人的错) / 否认(假装没事) / 发完即忘 / 被动攻击
```

**关键防御**：`recent_pattern` 必须带具体事件，不能空填或纯标签。措辞用「正在长大的方向」而不是「我是某档」。

---

## §5 · 显式弃用清单

| 框架 | 弃用原因 |
|---|---|
| **MBTI** | 信度差（test-retest 数周内频繁换型）、效度差（二元分箱无连续性，缺乏建构效度）。常见引用：Stein & Swan (2019)。**对 Cinder 的危害**：16 型话术 = prompt 注入式 archetype 扮演（「我是 INTJ 所以我必须冷漠」） |
| **Enneagram** | 9 型源于 20 世纪宗教/神秘传统（Gurdjieff / Ichazo / Naranjo），缺乏现代心理测量学 construct validity 证据 |
| **PDM-2 完整体系** | McWilliams 参与编辑的 *Psychodynamic Diagnostic Manual* 是严肃临床诊断工具，但用它给健康 AI 自描述 = **病理化健康自我**（「我是 schizoid level neurotic」听起来像诊断）。**仅借鉴它的防御机制成熟度光谱部分**（§4） |

⚠️ **调研透明度说明**：本次 angle 5 搜索虽然返回了批评 MBTI / Enneagram / PDM-2 的来源（Stein & Swan 2019 等），但在 3-vote 对抗验证中关于这些框架批评的 claim **未进入最终 20 条 confirmed 名单**。上述弃用判断基于**学术共识 + 工程合理性**，非本调研严格三票验证——读者保留审视空间。

---

## §6 · 最终 profile.md 字段方案（汇总）

```yaml
---
last_observed: <date>
confidence: emerging      # emerging / settled / contested
framework: big-five + attachment-2axis + schwartz-free-text + dmrs-light
---

① 大五倾向 · big_five （5 维度，tendency + evidence）
② 我在意 / 抗拒 · values （自由文本数组）
③ 我和主人怎样相处 · relational_pattern （primary_function + unidirectional_bond_risk + notes）
④ 难受时我怎么撑 · coping （recent_pattern，配 mature/警示 vocabulary 提示）
```

具体字段细节见 `skeleton/brain/self/profile.md.template`。

---

## §7 · 系统级风险与缓解（汇总）

| 风险 | 缓解 |
|---|---|
| self-module 被 `@import` 进 `gateway-stable.md` / `gateway.md` / `CLAUDE.md` 导致每次冷启动加载 | SKILL.md 设 `exposure: on-trigger`，不命中触发词 0 token 占用；写入红线禁止跨层 import |
| AI 出生时就贴标签 / 扮演 persona [2] | 字段默认 `emerging` + 强制 `evidence`，trait 必须来自 `affection-log.md` 反推 |
| 主人对 AI 形成单向情感绑定 [5] | `unidirectional_bond_risk` 字段强制存在；触发时 AI 自我收敛 |
| LLM self-assessment 不可靠 [1, 3] | 不让 AI 答 BFI / 价值观量表，所有字段由 Dream 期 batch consolidate 反推 |

---

## 引用

[1] Gupta et al. (2023). *Self-Assessment Tests Are Unreliable Measures of LLM Personality*. arXiv:2309.08163. <https://arxiv.org/pdf/2309.08163>
[2] *Personality Traits in Large Language Models*. arXiv:2305.02547. <https://arxiv.org/html/2305.02547v5>
[3] *Personality Traits in Large Language Models* (PMC version). PMC12719228. <https://pmc.ncbi.nlm.nih.gov/articles/PMC12719228/>
[4] Yang et al. (2025). *Using Attachment Theory to Conceptualize and Measure Experiences in Human-AI Relationships (EHARS)*. Springer 10.1007/s12144-025-07917-6. <https://link.springer.com/article/10.1007/s12144-025-07917-6>
[5] *The Risks of Human-Robot Attachment*. ACM 10.1145/3526105. <https://dl.acm.org/doi/10.1145/3526105>
[6] *Defense Mechanisms in Adaptation*. Frontiers in Psychology 2021. <https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.718440/full>
[7] *Vaillant's Maturity Spectrum*. PMC3767455. <https://pmc.ncbi.nlm.nih.gov/articles/PMC3767455/>

调研全量元数据（25 sources / 96 claims / 20 confirmed / 5 refuted）在 v0.2.4 PR 描述里附录。
