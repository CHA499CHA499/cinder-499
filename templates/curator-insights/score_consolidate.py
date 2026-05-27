"""
score_consolidate.py — Cinder A1: 自动评分 + 归档 insights 候选

用法:
  uv run --directory axon/curator-insights score_consolidate.py <consolidate_path>
  uv run --directory axon/curator-insights score_consolidate.py --batch         # 扫 brain/insights/consolidate-*.md 全部
  uv run --directory axon/curator-insights score_consolidate.py --batch --dry-run

约束:
  - 不修改 brain/cortex/methodology.md（§二.6）
  - 只动 brain/insights/ 子目录
  - 评分用 Claude Haiku（成本上限 $0.05/次）
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def resolve_cinder_home() -> Path:
    """解析 CINDER_HOME，按优先级：环境变量 > ~/.cinder/config > 从脚本位置推导。

    可迁移性约束（D1）：禁止任何硬编码绝对路径（如 /Users/<name>/... ）。
    脚本被移到任何机器上，都能通过这三层解析自动找到仓根。
    """
    # 1. 环境变量
    env = os.environ.get("CINDER_HOME")
    if env:
        return Path(env).expanduser().resolve()

    # 2. ~/.cinder/config（key=value 格式）
    config = Path.home() / ".cinder" / "config"
    if config.exists():
        for line in config.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith("CINDER_HOME=") and "=" in line:
                value = line.split("=", 1)[1].strip().strip('"').strip("'")
                if value:
                    return Path(value).expanduser().resolve()

    # 3. 从脚本位置推导：axon/curator-insights/score_consolidate.py → 上两级 = REPO_ROOT
    return Path(__file__).resolve().parents[2]


REPO_ROOT = resolve_cinder_home()


def load_dotenv(repo_root: Path) -> None:
    """Load simple KEY=VALUE lines from .env without overriding existing env."""
    env_path = repo_root / ".env"
    if not env_path.exists():
        return
    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


load_dotenv(REPO_ROOT)
INSIGHTS_DIR = REPO_ROOT / "brain" / "insights"
PROMOTED_DIR = INSIGHTS_DIR / "promoted"
HOLD_DIR = INSIGHTS_DIR / "hold"
DISCARDED_DIR = INSIGHTS_DIR / "discarded"

CLAUDE_BIN = "claude"
SCORE_MODEL = os.environ.get("CINDER_A1_SCORE_MODEL", "claude-haiku-4-5-20251001")

SCORE_SCHEMA = {
    "type": "object",
    "properties": {
        "novelty": {
            "type": "integer",
            "minimum": 0,
            "maximum": 3,
            "description": "0=与现有 methodology 重复 / 1=有少量新成分 / 2=明显新颖 / 3=独立全新模式",
        },
        "evidence": {
            "type": "integer",
            "minimum": 0,
            "maximum": 3,
            "description": "0=空话无实证 / 1=单 source 单事例 / 2=多 source 单时间点 / 3=多 source 跨周复现 ≥2 次",
        },
        "actionability": {
            "type": "integer",
            "minimum": 0,
            "maximum": 3,
            "description": "0=纯感想 / 1=有方向无步骤 / 2=能写成 if-then / 3=能直接写成检查表/脚本/Hook",
        },
        "reason": {
            "type": "string",
            "description": "≤120 字中文，说明三档分数的理由（不要复述内容，只评判质量）",
        },
    },
    "required": ["novelty", "evidence", "actionability", "reason"],
    "additionalProperties": False,
}

SYSTEM_PROMPT = """你是 Cinder brain-curator 的评分子模块。任务是给一份 insights consolidate 候选打三维分。

评分维度（每维 0-3 分）:
- novelty (新颖度): 与现有 methodology 是否重复 / 是否带来新视角
- evidence (证据强度): sources 数量 + 实证密度 + 是否跨周复现
- actionability (可执行性): 是否能写成 if-then 规则、检查表、脚本

打分严格、不谄媚。宁可低分也不要给 7 分以上注水分。

【输出格式 - 严格遵守】
只输出一个 JSON 对象，不要任何前后文字、markdown、代码块标记、表情符号、解释。
分数必须是整数 0、1、2 或 3 之一，禁止小数（如 1.5）。
格式必须严格如下：
{"novelty": <0|1|2|3>, "evidence": <0|1|2|3>, "actionability": <0|1|2|3>, "reason": "<≤120字中文>"}

不要写"结果已提交"、"建议"、"我评分为..."这类话。
不要包 ```json``` 代码块。
直接输出 { 开头 } 结尾的 JSON 字符串。"""

USER_PROMPT_TPL = """请给以下 consolidate 文档打分。

==== 文件路径 ====
{path}

==== frontmatter sources 数量 ====
{sources_count}

==== 文档正文（已截取前 8000 字符）====
{body}

==== 评分参考标尺 ====
- 9 分（promote 候选）：跨周复现 2+ 次实证 + 能直接写成检查表 + methodology 没覆盖
- 5 分（hold 一周）：单事例但视角好 / 或方向对但缺步骤
- 2 分（discard）：与已有重复 / 或纯感想没实证 / 或拆得过碎信息密度低

请输出 JSON。"""

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n(.*)$", re.DOTALL)


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """简易 frontmatter 解析，避免引入 PyYAML 依赖"""
    m = FRONTMATTER_RE.match(text)
    if not m:
        return {}, text
    raw_fm, body = m.group(1), m.group(2)
    fm: dict = {}
    current_key = None
    for line in raw_fm.splitlines():
        if not line.strip():
            continue
        if line.startswith("- ") and current_key:
            fm.setdefault(current_key, []).append(line[2:].strip())
            continue
        if ":" in line and not line.startswith(" "):
            key, _, val = line.partition(":")
            key = key.strip()
            val = val.strip()
            if val == "":
                fm[key] = []
                current_key = key
            else:
                fm[key] = val
                current_key = None
    return fm, body


def serialize_frontmatter(fm: dict) -> str:
    """简易 frontmatter 序列化（保持字段顺序 + list 风格一致）"""
    lines = ["---"]
    for k, v in fm.items():
        if isinstance(v, list):
            lines.append(f"{k}:")
            for item in v:
                lines.append(f"- {item}")
        else:
            lines.append(f"{k}: {v}")
    lines.append("---")
    return "\n".join(lines)


def call_claude_score(path: Path, fm: dict, body: str) -> dict:
    """调 claude --print 拿评分 JSON"""
    sources_count = len(fm.get("sources", [])) if isinstance(fm.get("sources"), list) else 0
    body_truncated = body[:8000]
    user_prompt = USER_PROMPT_TPL.format(
        path=str(path.relative_to(REPO_ROOT)),
        sources_count=sources_count,
        body=body_truncated,
    )

    cmd = [
        CLAUDE_BIN,
        "--print",
        "--model",
        SCORE_MODEL,
        "--append-system-prompt",
        SYSTEM_PROMPT,
        user_prompt,
    ]

    last_err: Exception | None = None
    for attempt in range(2):  # 首次冷启动慢，失败后自动重试一次（claude prompt cache 命中第二次会快）
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=240,
                cwd=str(REPO_ROOT),
            )
            break
        except subprocess.TimeoutExpired as e:
            last_err = e
            if attempt == 0:
                continue
            raise RuntimeError(f"claude --print timeout after 240s (2 attempts) for {path.name}")
    else:
        raise RuntimeError(f"claude --print failed after retries: {last_err}") from last_err

    if result.returncode != 0:
        raise RuntimeError(
            f"claude --print failed (code {result.returncode}): {result.stderr[:500]}"
        )

    raw = result.stdout.strip()
    # 优先尝试直接解析；失败时从文本中抽取第一个 {...} JSON 对象
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        pass

    # 兜底 1：```json``` 代码块
    m = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", raw, re.DOTALL)
    if m:
        try:
            return json.loads(m.group(1))
        except json.JSONDecodeError:
            pass

    # 兜底 2：贪婪匹配第一个 { ... } 块（处理对象嵌套）
    m = re.search(r"\{[^{}]*\"novelty\"[^{}]*\"evidence\"[^{}]*\"actionability\"[^{}]*\}", raw, re.DOTALL)
    if m:
        try:
            return json.loads(m.group(0))
        except json.JSONDecodeError:
            pass

    raise RuntimeError(
        f"Cannot parse JSON from claude output for {path.name}\nRaw: {raw[:800]}"
    )


def compute_verdict(total: int) -> str:
    if total >= 7:
        return "promote"
    if total >= 4:
        return "hold"
    return "discard"


def target_dir(verdict: str) -> Path:
    return {"promote": PROMOTED_DIR, "hold": HOLD_DIR, "discard": DISCARDED_DIR}[verdict]


def score_one(path: Path, dry_run: bool = False) -> dict:
    text = path.read_text(encoding="utf-8")
    fm, body = parse_frontmatter(text)

    # 已评分跳过（除非强制重评）
    if "score_total" in fm:
        return {"path": str(path), "skipped": True, "verdict": fm.get("verdict")}

    score = call_claude_score(path, fm, body)
    # 强制整数（兜底 Haiku 偶发输出小数）
    score["novelty"] = int(round(score["novelty"]))
    score["evidence"] = int(round(score["evidence"]))
    score["actionability"] = int(round(score["actionability"]))
    total = score["novelty"] + score["evidence"] + score["actionability"]
    verdict = compute_verdict(total)

    # 写回 frontmatter（保持原字段 + 新增评分字段）
    fm["score_novelty"] = score["novelty"]
    fm["score_evidence"] = score["evidence"]
    fm["score_actionability"] = score["actionability"]
    fm["score_total"] = total
    fm["verdict"] = verdict
    fm["score_reason"] = score["reason"].replace("\n", " ").strip()
    fm["scored_at"] = datetime.now().strftime("%Y-%m-%d %H:%M")
    fm["scored_by"] = "axon/curator-insights v0.1"

    if dry_run:
        return {
            "path": str(path),
            "verdict": verdict,
            "total": total,
            "score": score,
            "dry_run": True,
        }

    new_text = serialize_frontmatter(fm) + "\n" + body
    path.write_text(new_text, encoding="utf-8")

    # 移动到对应目录
    dst_dir = target_dir(verdict)
    dst_dir.mkdir(parents=True, exist_ok=True)
    dst = dst_dir / path.name
    shutil.move(str(path), str(dst))

    return {
        "path": str(path),
        "moved_to": str(dst.relative_to(REPO_ROOT)),
        "verdict": verdict,
        "total": total,
        "score": score,
    }


def batch_score(dry_run: bool = False, limit: int | None = None) -> None:
    # 只匹配日期开头的 consolidate（排除 consolidate-template.md 等非数据文件）
    candidates = sorted(INSIGHTS_DIR.glob("consolidate-2[0-9]*.md"))
    candidates = [c for c in candidates if c.is_file()]
    if limit:
        candidates = candidates[:limit]

    print(f"[batch] 待评分: {len(candidates)} 份")
    stats = {"promote": 0, "hold": 0, "discard": 0, "skipped": 0, "error": 0}

    for i, path in enumerate(candidates, 1):
        try:
            result = score_one(path, dry_run=dry_run)
            if result.get("skipped"):
                stats["skipped"] += 1
                print(f"  [{i}/{len(candidates)}] SKIP {path.name} (already scored)")
            else:
                stats[result["verdict"]] += 1
                print(
                    f"  [{i}/{len(candidates)}] {result['verdict'].upper():8s} "
                    f"total={result['total']} N={result['score']['novelty']} "
                    f"E={result['score']['evidence']} A={result['score']['actionability']} "
                    f"{path.name}"
                )
        except Exception as e:
            stats["error"] += 1
            print(f"  [{i}/{len(candidates)}] ERROR {path.name}: {e}", file=sys.stderr)

    print(f"\n[batch] 汇总: {stats}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Score brain/insights/ consolidate candidates")
    parser.add_argument("path", nargs="?", help="单文件路径（不传走 --batch）")
    parser.add_argument("--batch", action="store_true", help="扫 brain/insights/consolidate-*.md 全部")
    parser.add_argument("--dry-run", action="store_true", help="只评分不写回不移动")
    parser.add_argument("--limit", type=int, help="batch 模式下最多处理 N 份")
    args = parser.parse_args()

    if args.batch:
        batch_score(dry_run=args.dry_run, limit=args.limit)
        return 0

    if not args.path:
        parser.print_help()
        return 1

    path = Path(args.path).resolve()
    if not path.exists():
        print(f"File not found: {path}", file=sys.stderr)
        return 1

    result = score_one(path, dry_run=args.dry_run)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
