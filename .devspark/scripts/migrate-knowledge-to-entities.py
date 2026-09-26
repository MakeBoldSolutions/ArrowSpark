#!/usr/bin/env python3
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
"""Opt-in migration: flat type-folder knowledge docs -> entity-ontology layout.

Per constitution Principle I, adopting .knowledge/entities/ is an explicit, human-run, reversible
migration — never automatic. This script only proposes/executes moves for docs under
.knowledge/architecture/, .knowledge/patterns/, .knowledge/operations/ (domain-entity content).
Governance docs (.knowledge/governance/**) are intentionally left untouched: they are not domain
entities and the target model keeps governance/ as its own top-level root.

Usage:
    python migrate-knowledge-to-entities.py --repo-root . --dry-run --json
    python migrate-knowledge-to-entities.py --repo-root . --yes
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path
from typing import Any

TYPE_TO_LAYER = {
    "architecture": "architecture",
    "engineering-pattern": "pattern",
    "operations-runbook": "operations",
}
SOURCE_DIRS = (".knowledge/architecture", ".knowledge/patterns", ".knowledge/operations")


def _slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def parse_frontmatter(path: Path) -> tuple[dict[str, Any], str]:
    text = path.read_text(encoding="utf-8-sig")
    if not text.startswith("---\n"):
        return {}, text
    parts = text.replace("\r\n", "\n").split("---\n", 2)
    if len(parts) != 3:
        raise ValueError(f"{path}: malformed YAML frontmatter")
    import yaml

    metadata = yaml.safe_load(parts[1]) or {}
    return metadata, parts[2]


def plan_moves(root: Path) -> list[dict[str, str]]:
    moves: list[dict[str, str]] = []
    for source_dir in SOURCE_DIRS:
        directory = root / source_dir
        if not directory.exists():
            continue
        for path in sorted(directory.glob("*.md")):
            metadata, _ = parse_frontmatter(path)
            entity_id = str(metadata.get("id") or _slug(path.stem))
            layer = TYPE_TO_LAYER.get(str(metadata.get("type", "")), "architecture")
            dest = f".knowledge/entities/{entity_id}/{layer}.md"
            moves.append(
                {
                    "from": path.relative_to(root).as_posix(),
                    "to": dest,
                    "entity_id": entity_id,
                    "layer": layer,
                    "needs_review": "source_of_truth/last_verified frontmatter must be added by hand",
                }
            )
    return moves


def apply_moves(root: Path, moves: list[dict[str, str]]) -> None:
    for move in moves:
        source = root / move["from"]
        dest = root / move["to"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(["git", "mv", str(source), str(dest)], cwd=root, check=True)
        entity_yaml = dest.parent / "_entity.yaml"
        if not entity_yaml.exists():
            entity_yaml.write_text(
                f"id: {move['entity_id']}\ntype: {move['entity_id']}\nowner: TBD\n",
                encoding="utf-8",
            )
            subprocess.run(["git", "add", str(entity_yaml)], cwd=root, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Migrate flat-type knowledge docs to entities/")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--yes", action="store_true")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    moves = plan_moves(root)

    if args.json or args.dry_run:
        print(json.dumps({"moves": moves}, indent=2))
    if args.dry_run:
        return 0
    if not args.yes:
        print("Re-run with --yes to apply, or --dry-run to preview only.")
        return 1
    apply_moves(root, moves)
    print(f"Moved {len(moves)} doc(s). _entity.yaml owner/type fields still need manual review.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
