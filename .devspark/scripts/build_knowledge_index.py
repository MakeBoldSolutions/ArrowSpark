#!/usr/bin/env python3
# BSW.DevSpark - (c) 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com
"""Generate the current BSW.DevSpark knowledge index.

Superset of the legacy flat type-folder model (architecture/, governance/, reference/, ...,
classified by `type:` frontmatter) and the entity-ontology model
(.knowledge/entities/<id>/_entity.yaml + layer docs classified by `layer:` frontmatter).
Both models are additive and may coexist in the same repository per constitution Principle I —
adopting entities/ is an explicit, opt-in migration (see migrate-knowledge-to-entities.py), never
required for an existing repo to keep working.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys
from datetime import UTC, date, datetime
from pathlib import Path
from typing import Any

import yaml

ALLOWED_TYPES = {
    "authoritative-reference",
    "engineering-pattern",
    "reference-data",
    "operations-runbook",
    "research-or-context",
    "architecture",
    "governance",
    "governance-decision",
    "entity-layer",
}
ALLOWED_LAYERS = {"architecture", "business", "integration", "operations", "pattern", "plan"}
PROHIBITED_KEYS = {
    "status",
    "lifecycle",
    "supersedes",
    "superseded-by",
    "replaced",
    "obsolete",
}
PROHIBITED_TYPES = {
    "historical-record",
    "stale-reference",
    "decision",
    "rationale",
    "history",
    "feature",
    "requirement",
    "task",
}
# Decisions are keyed by domain/topic and edited in place, never by creation order — a filename
# carrying a sequence number or ADR-style counter is the historical-tracking pattern this model
# explicitly rejects (see .knowledge/tooling/content-lifecycle.md).
DECISION_SEQUENCE_PREFIX_RE = re.compile(r"^(?:\d+[-_]|adr[-_]?\d+|decision[-_]?\d+)", re.IGNORECASE)
SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
# Current knowledge is durable truth and must never point at ephemeral planning/work-product state
# or the write-only archive — both may contain a path that happens to exist on disk, so an
# existence check alone cannot catch this; these prefixes must be rejected explicitly. This is the
# ephemeral subset of `.devspark.work/` only (per .knowledge/taxonomy-registry.json's
# `workProductType` entries plus the CAP/legacy-release drafts folders) — durable config and
# override subtrees such as `.devspark.work/scripts/`, `.devspark.work/commands/`,
# `.devspark.work/templates/`, and `.devspark.work/autonomy/` are legitimate appliesTo/
# source_of_truth targets and must stay allowed.
FORBIDDEN_REFERENCE_PREFIXES = (
    ".archive/",
    ".devspark.work/specs/",
    ".devspark.work/quickfixes/",
    ".devspark.work/pr-review/",
    ".devspark.work/audit/",
    ".devspark.work/metrics/",
    ".devspark.work/telemetry/",
    ".devspark.work/governance/",
    ".devspark.work/releases/",
)


def _is_forbidden_reference(item: str) -> bool:
    return any(item.startswith(prefix) for prefix in FORBIDDEN_REFERENCE_PREFIXES)


DEFAULT_MAPPINGS = (
    (".knowledge/reference/**", "reference-data"),
    (".knowledge/reference-data/**", "reference-data"),
    (".knowledge/integrations/**", "operations-runbook"),
    (".knowledge/operations/**", "operations-runbook"),
    (".knowledge/scripts/**", "operations-runbook"),
    (".knowledge/legal/**", "authoritative-reference"),
    (".knowledge/plans/**", "research-or-context"),
    (".knowledge/architecture/**", "architecture"),
    (".knowledge/governance/decisions/**", "governance-decision"),
    (".knowledge/governance/**", "governance"),
)
ROOTS = (
    {"path": ".devspark/", "owner": "framework", "purpose": "framework payload"},
    {"path": ".devspark.work/", "owner": "repo", "purpose": "work products"},
    {"path": ".knowledge/", "owner": "repo", "purpose": "current authoritative knowledge and published user-facing guidance"},
    {"path": ".archive/", "owner": "repo", "purpose": "landing place for old work products, grouped by release"},
)


def parse_frontmatter(path: Path) -> tuple[dict[str, Any], str]:
    text = path.read_text(encoding="utf-8-sig")
    if not text.startswith("---\n") and not text.startswith("---\r\n"):
        return {}, text
    normalized = text.replace("\r\n", "\n")
    parts = normalized.split("---\n", 2)
    if len(parts) != 3:
        raise ValueError(f"{path}: malformed YAML frontmatter")
    metadata = yaml.safe_load(parts[1]) or {}
    if not isinstance(metadata, dict):
        raise ValueError(f"{path}: frontmatter must be an object")
    return metadata, parts[2]


def load_registry(root: Path) -> list[dict[str, Any]]:
    path = root / ".knowledge/taxonomy-registry.json"
    if not path.exists():
        return []
    registry = json.loads(path.read_text(encoding="utf-8"))
    mappings = registry.get("mappings")
    if not isinstance(mappings, list):
        raise ValueError(f"{path}: mappings must be an array")
    return [mapping for mapping in mappings if isinstance(mapping, dict)]


def infer_type(relative_path: str, mappings: list[dict[str, Any]]) -> str:
    for mapping in mappings:
        pattern = mapping.get("pathPattern")
        node_type = mapping.get("nodeType")
        if pattern and node_type and fnmatch.fnmatchcase(relative_path, pattern):
            return str(node_type)
    for pattern, node_type in DEFAULT_MAPPINGS:
        if fnmatch.fnmatchcase(relative_path, pattern):
            return node_type
    return "authoritative-reference"


def validate_current(path: Path, metadata: dict[str, Any], body: str) -> None:
    invalid_keys = sorted(PROHIBITED_KEYS.intersection(metadata))
    if invalid_keys:
        raise ValueError(f"{path}: current knowledge prohibits {', '.join(invalid_keys)}")
    node_type = str(metadata.get("type", ""))
    if node_type in PROHIBITED_TYPES or (node_type and node_type not in ALLOWED_TYPES):
        raise ValueError(f"{path}: prohibited knowledge type '{node_type}'")
    links = metadata.get("links", {})
    if links and not isinstance(links, dict):
        raise ValueError(f"{path}: links must be an object")
    if isinstance(links, dict) and set(links).difference({"references"}):
        raise ValueError(f"{path}: only current 'references' links are allowed")
    # No body-text scan: lifecycle language is prohibited in frontmatter (above), not in prose —
    # docs legitimately describe current system behavior using these words (e.g. a live Cosmos
    # "status": "superseded" field value, or a still-present-but-unread legacy field).


def _git_last_commit_date(root: Path, relative_path: str) -> str | None:
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%cI", "--", relative_path],
            cwd=root,
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    line = result.stdout.strip()
    return line or None


def validate_entity_layer_doc(
    root: Path, path: Path, metadata: dict[str, Any], stale_findings: list[dict[str, str]]
) -> None:
    """Validate an entity-layer doc's structure (raises immediately) and check staleness
    (appended to `stale_findings` instead of raising, so every stale doc in a run can be
    reported together rather than stopping at the first one). Staleness is reported, not
    hard-failed by default -- see the `stale_entities` field on the built index and the
    `--fail-on-stale` flag in `main()`.
    """
    layer = metadata.get("layer")
    if layer not in ALLOWED_LAYERS:
        raise ValueError(f"{path}: layer must be one of {sorted(ALLOWED_LAYERS)}")
    sources = metadata.get("source_of_truth")
    if not isinstance(sources, list) or not sources or not all(isinstance(s, str) for s in sources):
        raise ValueError(f"{path}: source_of_truth must be a non-empty array of paths")
    last_verified = metadata.get("last_verified")
    if not last_verified:
        raise ValueError(f"{path}: last_verified is required for entity-layer docs")
    try:
        verified_date = date.fromisoformat(str(last_verified))
    except ValueError as exc:
        raise ValueError(f"{path}: last_verified must be an ISO date (YYYY-MM-DD)") from exc
    for source in sources:
        if _is_forbidden_reference(source):
            raise ValueError(f"{path}: source_of_truth cannot target .devspark.work/ or .archive/: {source}")
        if not (root / source).exists():
            raise ValueError(f"{path}: source_of_truth path does not exist: {source}")
        commit_date = _git_last_commit_date(root, source)
        if commit_date is None:
            continue
        try:
            source_date = datetime.fromisoformat(commit_date).date()
        except ValueError:
            continue
        if source_date > verified_date:
            stale_findings.append(
                {
                    "path": path.relative_to(root).as_posix(),
                    "source": source,
                    "source_date": str(source_date),
                    "last_verified": str(verified_date),
                }
            )


def load_entity_node(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    if not isinstance(data, dict):
        raise ValueError(f"{path}: _entity.yaml must be an object")
    for key in ("id", "type", "owner"):
        if not data.get(key):
            raise ValueError(f"{path}: _entity.yaml missing required '{key}'")
    entity_id = str(data["id"])
    if entity_id != path.parent.name:
        raise ValueError(f"{path}: id '{entity_id}' must match folder name '{path.parent.name}'")
    return data


def validate_decision_doc(path: Path, metadata: dict[str, Any], entity_ids: set[str]) -> list[str]:
    """Validate a governance-decision doc; returns its `constrains` entity id list.

    Decisions are current governance, not history: keyed by topic (filename), not creation order,
    and every entity they constrain must exist and carry a reciprocal `constrained_by` pointer
    (checked by the caller once all entities and decisions are known).
    """
    if DECISION_SEQUENCE_PREFIX_RE.match(path.stem):
        raise ValueError(
            f"{path}: decisions must be keyed by domain/topic, not creation order — rename away "
            "from a numbered/ADR-style filename"
        )
    constrains = metadata.get("constrains")
    if not isinstance(constrains, list) or not constrains or not all(isinstance(c, str) for c in constrains):
        raise ValueError(f"{path}: governance-decision requires a non-empty 'constrains' array of entity ids")
    for entity_id in constrains:
        if entity_id not in entity_ids:
            raise ValueError(f"{path}: constrains references unknown entity '{entity_id}'")
    return [str(c) for c in constrains]


def build_entities(
    root: Path,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[dict[str, str]]]:
    """Return (entity_nodes, layer_doc_nodes, stale_entities) for every .knowledge/entities/<id>/.

    `stale_entities` is reported, never raised here -- a source file's commit date moving past
    a doc's `last_verified` is common noise (an unrelated edit to a cited file), not proof the
    described behavior actually changed. The caller decides whether to treat it as blocking via
    `--fail-on-stale`; the routine build always succeeds so it never blocks unrelated work.
    """
    entities_root = root / ".knowledge/entities"
    entity_nodes: list[dict[str, Any]] = []
    layer_nodes: list[dict[str, Any]] = []
    stale_findings: list[dict[str, str]] = []
    if not entities_root.exists():
        return entity_nodes, layer_nodes, stale_findings
    for entity_dir in sorted(p for p in entities_root.iterdir() if p.is_dir()):
        node_file = entity_dir / "_entity.yaml"
        if not node_file.exists():
            raise ValueError(f"{entity_dir}: missing required _entity.yaml")
        entity = load_entity_node(node_file)
        entity_id = str(entity["id"])
        overrides = {
            str(item["layer"])
            for item in entity.get("coverage_overrides", []) or []
            if isinstance(item, dict) and item.get("layer")
        }
        present_layers: set[str] = set()

        for doc_path in sorted(entity_dir.glob("*.md")):
            relative = doc_path.relative_to(root).as_posix()
            metadata, body = parse_frontmatter(doc_path)
            validate_current(doc_path, metadata, body)
            validate_entity_layer_doc(root, doc_path, metadata, stale_findings)
            layer = str(metadata["layer"])
            present_layers.add(layer)
            node_id = str(metadata.get("id") or f"{entity_id}-{layer}")
            layer_nodes.append(
                {
                    "id": node_id,
                    "entity": entity_id,
                    "layer": layer,
                    "type": "entity-layer",
                    "path": relative,
                    "title": str(metadata.get("title") or node_id),
                    "source_of_truth": metadata["source_of_truth"],
                    "last_verified": str(metadata["last_verified"]),
                }
            )

        missing_layers = sorted(ALLOWED_LAYERS - present_layers - overrides)
        entity_nodes.append(
            {
                "id": entity_id,
                "type": str(entity["type"]),
                "owner": str(entity["owner"]),
                "path": entity_dir.relative_to(root).as_posix(),
                "relations": entity.get("relations", []) or [],
                "layers": sorted(present_layers),
                "missing_layers": missing_layers,
                "coverage_overrides": sorted(overrides),
                "constrained_by": [str(d) for d in entity.get("constrained_by", []) or []],
            }
        )

    return entity_nodes, layer_nodes, stale_findings


def generated_at(explicit: str | None = None) -> str:
    override = explicit or os.environ.get("DEVSPARK_GENERATED_AT")
    if override:
        return override
    return datetime.now(UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def build_index(root: Path, timestamp: str | None = None) -> dict[str, Any]:
    knowledge_root = root / ".knowledge"
    mappings = load_registry(root)
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, str]] = []
    seen: set[str] = set()

    # Entities are built first so governance-decision docs can validate `constrains` against real
    # entity ids, and so the reciprocal `constrained_by` check below has entities to compare against.
    entity_nodes, layer_nodes, stale_entities = build_entities(root)
    entity_by_id = {entity["id"]: entity for entity in entity_nodes}
    decision_constrains: dict[str, list[str]] = {}

    if knowledge_root.exists():
        for path in sorted(knowledge_root.rglob("*.md")):
            relative = path.relative_to(root).as_posix()
            if relative in {".knowledge/index.md", ".knowledge/README.md"}:
                continue
            if ".knowledge/entities/" in relative:
                continue  # handled by build_entities
            metadata, body = parse_frontmatter(path)
            validate_current(path, metadata, body)
            node_id = str(metadata.get("id") or path.relative_to(knowledge_root).with_suffix("").as_posix().replace("/", "-"))
            if node_id in seen:
                raise ValueError(f"{path}: duplicate knowledge id '{node_id}'")
            seen.add(node_id)
            node_type = str(metadata.get("type") or infer_type(relative, mappings))
            if node_type not in ALLOWED_TYPES:
                raise ValueError(f"{path}: prohibited knowledge type '{node_type}'")
            title = str(metadata.get("title") or next((line[2:].strip() for line in body.splitlines() if line.startswith("# ")), node_id))
            node: dict[str, Any] = {
                "id": node_id,
                "type": node_type,
                "path": relative,
                "title": title,
            }
            applies_to = metadata.get("appliesTo")
            if applies_to:
                if not isinstance(applies_to, list) or not all(isinstance(item, str) for item in applies_to):
                    raise ValueError(f"{path}: appliesTo must be an array of paths")
                if any(_is_forbidden_reference(item) for item in applies_to):
                    raise ValueError(f"{path}: appliesTo cannot target .devspark.work/ or .archive/ paths")
                node["appliesTo"] = applies_to
            if node_type == "governance-decision":
                decision_constrains[node_id] = validate_decision_doc(path, metadata, set(entity_by_id))
            nodes.append(node)
            for target in (metadata.get("links") or {}).get("references", []):
                edges.append({"from": node_id, "to": str(target), "rel": "references"})

    for layer_node in layer_nodes:
        if layer_node["id"] in seen:
            raise ValueError(f"{layer_node['path']}: duplicate knowledge id '{layer_node['id']}'")
        seen.add(layer_node["id"])
    nodes.extend(layer_nodes)

    # An unresolved relation is a dead edge in the graph every command traverses, and the entity
    # schema requires a resolvable entity id, so it fails the build. A `links.references` target
    # may legitimately point at knowledge not yet authored, so it is reported rather than fatal.
    known_ids = seen | set(entity_by_id)
    path_by_id = {node["id"]: node["path"] for node in nodes}
    for entity in entity_nodes:
        for relation in entity["relations"]:
            if not isinstance(relation, dict) or not relation.get("to"):
                raise ValueError(
                    f".knowledge/entities/{entity['id']}/_entity.yaml: every relation requires a 'to' entity id"
                )
            target = str(relation["to"])
            if target not in entity_by_id:
                raise ValueError(
                    f".knowledge/entities/{entity['id']}/_entity.yaml: relation targets unknown entity '{target}'"
                )
    dangling_references = [
        {"from": edge["from"], "to": edge["to"], "path": path_by_id.get(edge["from"], edge["from"])}
        for edge in edges
        if edge["to"] not in known_ids
    ]

    # Reciprocity: an entity an existing decision constrains must point back via `constrained_by`,
    # and an entity must not claim `constrained_by` for a decision that doesn't actually constrain it.
    for decision_id, constrains in decision_constrains.items():
        for entity_id in constrains:
            if decision_id not in entity_by_id[entity_id]["constrained_by"]:
                raise ValueError(
                    f".knowledge/entities/{entity_id}/_entity.yaml: missing 'constrained_by: [{decision_id}]' "
                    f"required by governance decision '{decision_id}'"
                )
    for entity_id, entity in entity_by_id.items():
        for decision_id in entity["constrained_by"]:
            if entity_id not in decision_constrains.get(decision_id, []):
                raise ValueError(
                    f".knowledge/entities/{entity_id}/_entity.yaml: constrained_by references "
                    f"'{decision_id}', which does not list '{entity_id}' in its constrains"
                )

    return {
        "generated": {"by": "build-knowledge-index", "at": generated_at(timestamp)},
        "roots": list(ROOTS),
        "nodes": nodes,
        "edges": sorted(edges, key=lambda edge: (edge["from"], edge["to"])),
        "dangling_references": sorted(
            dangling_references, key=lambda item: (item["from"], item["to"])
        ),
        "entities": entity_nodes,
        "stale_entities": stale_entities,
    }


def build_coverage_report(index: dict[str, Any], timestamp: str | None = None) -> dict[str, Any]:
    entities = index.get("entities", [])
    gaps = [
        {"entity": entity["id"], "missing_layers": entity["missing_layers"]}
        for entity in entities
        if entity["missing_layers"]
    ]
    return {
        "generated": {"by": "build-knowledge-index", "at": generated_at(timestamp)},
        "entity_count": len(entities),
        "fully_covered": len(entities) - len(gaps),
        "gaps": gaps,
    }


def _drift(existing_path: Path, fresh_payload: dict[str, Any]) -> str | None:
    """Compare fresh output to the committed file, ignoring the generated.at timestamp."""
    if not existing_path.exists():
        return f"{existing_path} does not exist (run the generator to create it)"
    try:
        existing_payload = json.loads(existing_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return f"{existing_path} is not valid JSON: {exc}"

    def _normalize(payload: dict[str, Any]) -> dict[str, Any]:
        return {**payload, "generated": {"by": payload.get("generated", {}).get("by")}}

    if _normalize(existing_payload) != _normalize(fresh_payload):
        return f"{existing_path} is stale relative to .knowledge/ source content"
    return None


def _pattern_covers(pattern: str, changed_file: str) -> bool:
    if fnmatch.fnmatchcase(changed_file, pattern):
        return True
    # A directory named as source_of_truth claims the files beneath it.
    return changed_file.startswith(pattern.rstrip("/") + "/")


def find_unmapped_files(index: dict[str, Any], changed_files: list[str]) -> list[str]:
    """Return the subset of changed_files that no knowledge node claims.

    Used by /devspark.pr-review as a computed hint for its PRD5 ("new behavior with no
    knowledge") judgment call — never a mechanical gate on its own, just a real list backing
    the reviewer's read of the diff instead of leaving it to eyeballing.

    Entity layer docs claim code through `source_of_truth` rather than `appliesTo`, so reading
    only the latter reports entity-covered files as unmapped.
    """
    patterns = [
        pattern
        for node in index.get("nodes", [])
        for key in ("appliesTo", "source_of_truth")
        for pattern in node.get(key) or []
    ]
    return [
        changed_file
        for changed_file in changed_files
        if not any(_pattern_covers(pattern, changed_file) for pattern in patterns)
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate the current BSW.DevSpark knowledge index")
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--output")
    parser.add_argument("--coverage-output")
    parser.add_argument("--stdout", action="store_true")
    parser.add_argument("--generated-at")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Fail if committed index.json/coverage.json are stale; never writes files.",
    )
    parser.add_argument(
        "--fail-on-stale",
        action="store_true",
        help=(
            "Exit 1 if any entity-layer doc's last_verified is older than its "
            "source_of_truth's newest commit. Off by default so a routine build never blocks "
            "on an unrelated edit to a cited file; use this flag for a dedicated, periodic "
            "knowledge-currency check."
        ),
    )
    parser.add_argument(
        "--unmapped-files",
        nargs="+",
        metavar="PATH",
        help="Print (as a JSON array) the subset of given paths matching no node's appliesTo pattern; never writes files.",
    )
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    index = build_index(root, args.generated_at)
    stale_entities = index.get("stale_entities", [])
    output = Path(args.output) if args.output else root / ".knowledge/index.json"
    coverage_output = Path(args.coverage_output) if args.coverage_output else root / ".knowledge/ontology/coverage.json"

    if args.unmapped_files is not None:
        print(json.dumps(find_unmapped_files(index, args.unmapped_files)))
        return 0

    if stale_entities:
        for finding in stale_entities:
            print(
                f"STALE: {finding['path']}: source_of_truth '{finding['source']}' changed "
                f"({finding['source_date']}) after last_verified ({finding['last_verified']}) "
                "-- confirm the doc still matches the code before bumping last_verified "
                "(prefer running /devspark.explain <topic> over a bare hand-edit of the date)",
                file=sys.stderr,
            )
        if args.fail_on_stale:
            print(
                f"{len(stale_entities)} entity-layer doc(s) have a stale last_verified; "
                "failing because --fail-on-stale was set.",
                file=sys.stderr,
            )

    if args.check:
        problems = [_drift(output, index)]
        if index["entities"]:
            problems.append(_drift(coverage_output, build_coverage_report(index, args.generated_at)))
        problems = [p for p in problems if p]
        if problems:
            for problem in problems:
                print(f"DRIFT: {problem}", file=sys.stderr)
            print(
                "Regenerate with: python3 scripts/build_knowledge_index.py --repo-root .",
                file=sys.stderr,
            )
            return 1
        return 1 if (args.fail_on_stale and stale_entities) else 0

    payload = json.dumps(index, indent=2, ensure_ascii=False) + "\n"
    if args.stdout:
        print(payload, end="")
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(payload, encoding="utf-8")

    if index["entities"]:
        coverage = build_coverage_report(index, args.generated_at)
        coverage_payload = json.dumps(coverage, indent=2, ensure_ascii=False) + "\n"
        if args.stdout:
            pass  # --stdout emits only the index, matching legacy behavior
        else:
            coverage_output.parent.mkdir(parents=True, exist_ok=True)
            coverage_output.write_text(coverage_payload, encoding="utf-8")
    return 1 if (args.fail_on_stale and stale_entities) else 0


if __name__ == "__main__":
    raise SystemExit(main())
