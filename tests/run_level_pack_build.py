"""Build one level pack from a recipe with the seeded level generator.

Usage:
  python tests/run_level_pack_build.py --godot <executable> --recipe levels/recipes/<pack>.json
  python tests/run_level_pack_build.py --godot <executable> --recipe levels/recipes/<pack>.json --check

Runs tests/level_pack_build.gd headlessly in a bare, isolated temp project (the
same pattern as run_puzzle_structural_report.py) holding the puzzle domain
scripts, the shared report printer, the current levels/ and the recipe. The
Godot side generates and checks every level and prints a structural report per
level; it prints the serialized pack only when nothing failed.

Write mode writes that pack to levels/packs/<pack>.json atomically: the bytes
go to a temp file beside the destination, are flushed to disk, then replace
the destination in one step. On any failure nothing is written and an existing
pack is left byte-identical. --check never writes: it exits 0 only when the
build passes and is byte-identical to the committed pack.
"""

from pathlib import Path
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import uuid

PUZZLE_SCRIPTS = (
    "puzzle_definition", "puzzle_state", "puzzle_solver", "puzzle_analyzer",
    "puzzle_content_version", "puzzle_pack_format", "puzzle_catalog", "puzzle_generator",
)


def _isolated_env(root: Path) -> dict:
    env = dict(os.environ)
    env["APPDATA"] = str(root / "userdata")
    env["XDG_DATA_HOME"] = str(root / "userdata")
    return env


def build_pack(godot: str, repo: Path, recipe: Path) -> tuple[bool, str, bytes]:
    """Returns (passed, report text, pack bytes); pack bytes are empty on failure."""
    with tempfile.TemporaryDirectory(prefix="arrowgame-pack-build-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        name = "ArrowGamePackBuild-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n', encoding="utf-8"
        )
        for script in PUZZLE_SCRIPTS:
            shutil.copyfile(repo / "scripts/puzzle" / f"{script}.gd", root / f"{script}.gd")
        shutil.copyfile(repo / "tests/puzzle_report_format.gd", root / "puzzle_report_format.gd")
        shutil.copyfile(repo / "tests/level_pack_build.gd", root / "level_pack_build.gd")
        shutil.copytree(repo / "levels", root / "levels", ignore=shutil.ignore_patterns("recipes"))
        shutil.copyfile(recipe, root / "recipe.json")

        # Build the global class_name cache first, same as the other launchers.
        subprocess.run([godot, "--headless", "--path", str(root), "--editor", "--quit"],
                       env=env, check=True, timeout=45, capture_output=True)
        result = subprocess.run(
            [godot, "--headless", "--path", str(root), "--script", "level_pack_build.gd",
             "--", "--recipe", "res://recipe.json"],
            env=env, check=False, timeout=600, capture_output=True, encoding="utf-8", errors="replace",
        )

    lines = result.stdout.splitlines()
    if "PACK_BEGIN" in lines and "PACK_END" in lines:
        begin, end = lines.index("PACK_BEGIN"), lines.index("PACK_END")
        pack_text = "\n".join(lines[begin + 1:end]) + "\n"
        report = "\n".join(lines[:begin] + lines[end + 1:])
    else:
        pack_text, report = "", result.stdout
    script_error = "SCRIPT ERROR:" in result.stderr or "Parse Error:" in result.stderr
    if script_error:
        report += "\nGodot reported a script error:\n" + result.stderr
    passed = (result.returncode == 0 and not script_error
              and "PACK_BUILD_FAILURES=0" in lines and bool(pack_text))
    return passed, report, pack_text.encode("utf-8") if passed else b""


def write_atomically(destination: Path, data: bytes) -> None:
    temporary = destination.with_name(f".{destination.name}.tmp")
    try:
        with open(temporary, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, destination)
    finally:
        if temporary.exists():
            temporary.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--godot", default="godot")
    parser.add_argument("--recipe", required=True, help="recipe path relative to the repository root")
    parser.add_argument("--check", action="store_true",
                        help="build and compare with the committed pack; never write")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    recipe = (repo / args.recipe).resolve()
    if not recipe.is_file():
        print(f"recipe not found: {recipe}", file=sys.stderr)
        return 2
    try:
        pack_name = json.loads(recipe.read_text(encoding="utf-8"))["pack"]
    except (ValueError, KeyError, TypeError):
        print(f"recipe {recipe} is not JSON with a 'pack' name", file=sys.stderr)
        return 2
    destination = repo / "levels/packs" / f"{pack_name}.json"

    passed, report, data = build_pack(args.godot, repo, recipe)
    print(report)
    if not passed:
        print(f"Build failed; {destination.relative_to(repo).as_posix()} was not written.", file=sys.stderr)
        return 1
    if args.check:
        if destination.is_file() and destination.read_bytes() == data:
            print(f"Check passed: {destination.relative_to(repo).as_posix()} is byte-identical to a fresh build.")
            return 0
        print(f"Check failed: {destination.relative_to(repo).as_posix()} differs from a fresh build.", file=sys.stderr)
        return 1
    write_atomically(destination, data)
    print(f"Wrote {destination.relative_to(repo).as_posix()} ({len(data)} bytes).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
