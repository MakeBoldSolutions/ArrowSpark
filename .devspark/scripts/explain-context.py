#!/usr/bin/env python3
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
"""Resolve a free-text topic against `.knowledge/` and code for `/devspark.explain`.

Reuses `build_knowledge_index.py` (frontmatter parsing, git-log dates, the built index) rather
than duplicating that logic — per constitution Principle VI, it is the single source of truth
for knowledge structure across languages.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_knowledge_index import (  # noqa: E402
    _drift,
    _git_last_commit_date,
    build_coverage_report,
    build_index,
    parse_frontmatter,
)

STOPWORDS = {
    "how", "is", "the", "a", "an", "of", "in", "to", "and", "or", "does", "do", "are", "for",
    "on", "with", "what", "when", "where", "why", "this", "that", "was", "were", "be", "it",
}
TEXT_EXTENSIONS = {
    ".md", ".py", ".ps1", ".sh", ".js", ".jsx", ".ts", ".tsx", ".cs", ".go", ".rs",
    ".json", ".yaml", ".yml", ".toml",
}
TEST_PATH_RE = re.compile(r"(?i)(^|/)(tests?|__tests__|spec)(/|$)|(_test\.|\.test\.|_spec\.|\.spec\.)")
GLOB_CHARS = re.compile(r"[*?\[]")
EXCLUDED_DIRS = {
    ".git", ".devspark.work", ".archive", ".devspark", "node_modules", "__pycache__",
    ".venv", "venv", "dist", "build", "bin", "obj",
}


def repository_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], check=False, capture_output=True, text=True, encoding="utf-8"
    )
    return Path(result.stdout.strip()) if result.returncode == 0 else Path.cwd().resolve()


def relative(repo: Path, path: Path) -> str:
    return path.relative_to(repo).as_posix()


def tokenize(topic: str) -> list[str]:
    words = re.findall(r"[a-zA-Z][a-zA-Z0-9_-]{2,}", topic.lower())
    keywords = sorted({w for w in words if w not in STOPWORDS})
    return keywords or sorted(set(words))


def index_is_fresh(repo: Path, index: dict[str, Any]) -> bool:
    output = repo / ".knowledge/index.json"
    coverage_output = repo / ".knowledge/ontology/coverage.json"
    problems = [_drift(output, index)]
    if index.get("entities"):
        problems.append(_drift(coverage_output, build_coverage_report(index)))
    return not any(problems)


def node_haystack(node: dict[str, Any]) -> str:
    parts = [str(node.get("id", "")), str(node.get("title", "")), str(node.get("path", ""))]
    parts.extend(node.get("appliesTo", []) or [])
    parts.extend(node.get("source_of_truth", []) or [])
    return " ".join(parts).lower()


def score(haystack: str, keywords: list[str]) -> int:
    return sum(1 for kw in keywords if kw in haystack)


def match_knowledge_nodes(index: dict[str, Any], keywords: list[str], limit: int) -> list[dict[str, Any]]:
    scored = [(score(node_haystack(node), keywords), node) for node in index.get("nodes", [])]
    scored = [pair for pair in scored if pair[0] > 0]
    scored.sort(key=lambda pair: (-pair[0], pair[1]["id"]))
    return [node for _, node in scored[:limit]]


def match_entities(index: dict[str, Any], keywords: list[str], limit: int) -> list[dict[str, Any]]:
    scored = []
    for entity in index.get("entities", []):
        haystack = " ".join(
            [str(entity.get("id", "")), str(entity.get("owner", "")), str(entity.get("path", ""))]
            + [str(r) for r in entity.get("relations", []) or []]
        ).lower()
        entity_score = score(haystack, keywords)
        if entity_score > 0:
            scored.append((entity_score, entity))
    scored.sort(key=lambda pair: (-pair[0], pair[1]["id"]))
    return [entity for _, entity in scored[:limit]]


def _source_exists(repo: Path, source: str) -> bool:
    """`appliesTo` entries are globs, which never resolve as a literal path."""
    if GLOB_CHARS.search(source):
        try:
            return any(repo.glob(source))
        except (ValueError, OSError):
            return False
    return (repo / source).exists()


def enrich_node(repo: Path, node: dict[str, Any], entity_lookup: dict[str, dict[str, Any]]) -> dict[str, Any]:
    entry = dict(node)
    sources = node.get("source_of_truth") or node.get("appliesTo") or []
    entry["source_status"] = [
        {
            "path": source,
            "exists": _source_exists(repo, source),
            "last_commit_date": _git_last_commit_date(repo, source),
        }
        for source in sources
    ]
    if node.get("type") == "governance-decision":
        metadata, _ = parse_frontmatter(repo / node["path"])
        constrains = [str(c) for c in (metadata.get("constrains") or [])]
        entry["constrains"] = constrains
        entry["constrained_by_reciprocal"] = {
            entity_id: node["id"] in entity_lookup.get(entity_id, {}).get("constrained_by", [])
            for entity_id in constrains
        }
    entity_id = node.get("entity")
    if entity_id and entity_id in entity_lookup:
        entity = entity_lookup[entity_id]
        entry["entity_missing_layers"] = entity.get("missing_layers", [])
        entry["entity_constrained_by"] = entity.get("constrained_by", [])
    return entry


def bounded_files(root: Path, limit: int) -> list[Path]:
    if not root.is_dir():
        return []
    files = [
        path
        for path in root.rglob("*")
        if path.is_file() and not any(part in EXCLUDED_DIRS for part in path.parts)
    ]
    return sorted(files, key=lambda path: path.as_posix())[:limit]


def grep_code_hits(repo: Path, keywords: list[str], limit: int) -> list[dict[str, Any]]:
    if not keywords:
        return []
    pattern = re.compile("|".join(re.escape(kw) for kw in keywords), re.IGNORECASE)
    hits: list[dict[str, Any]] = []
    for path in bounded_files(repo, limit * 20):
        if path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except (OSError, UnicodeDecodeError):
            continue
        rel = relative(repo, path)
        for number, line in enumerate(lines, start=1):
            if pattern.search(line):
                hits.append({
                    "file": rel,
                    "line": number,
                    "text": line.strip()[:240],
                    "is_test": bool(TEST_PATH_RE.search(rel)),
                })
                if len(hits) >= limit:
                    return hits
    return hits


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("topic", nargs="*", help="Free-text topic/question, e.g. 'how is auth done'")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--match-limit", type=int, default=8)
    parser.add_argument("--hit-limit", type=int, default=40)
    args, _ = parser.parse_known_args()

    repo = repository_root()
    topic = " ".join(args.topic).strip()
    keywords = tokenize(topic)
    try:
        index = build_index(repo)
    except ValueError as exc:
        payload = {
            "REPO_ROOT": str(repo), "TOPIC": topic, "KEYWORDS": keywords,
            "INDEX_FRESH": False, "ERROR": str(exc),
        }
        print(json.dumps(payload, separators=(",", ":")))
        return 1

    fresh = index_is_fresh(repo, index)
    entity_lookup = {entity["id"]: entity for entity in index.get("entities", [])}
    matched_nodes = [enrich_node(repo, node, entity_lookup) for node in match_knowledge_nodes(index, keywords, args.match_limit)]
    matched_entities = match_entities(index, keywords, args.match_limit)
    code_hits = grep_code_hits(repo, keywords, args.hit_limit)

    payload = {
        "REPO_ROOT": str(repo),
        "TOPIC": topic,
        "KEYWORDS": keywords,
        "INDEX_FRESH": fresh,
        "MATCHED_KNOWLEDGE": matched_nodes,
        "MATCHED_ENTITIES": matched_entities,
        "CANDIDATE_CODE_HITS": code_hits,
        "SUMMARY": {
            "matched_knowledge_count": len(matched_nodes),
            "matched_entity_count": len(matched_entities),
            "code_hit_count": len(code_hits),
            "test_hit_count": sum(1 for hit in code_hits if hit["is_test"]),
        },
    }
    print(json.dumps(payload, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
