"""Run the non-gating PuzzleAnalyzer developer structural report headlessly.

Unlike run_puzzle_regressions.py, this is NOT a pass/fail gate: it has no
check()/failure counter and no PUZZLE_*_FAILURES=0 marker. It always exits 0
on successful completion (an unhandled Godot script error still exits
non-zero, same as any Godot script run). See
tests/puzzle_structural_report.gd for the exact output format it implements.

Reuses the same bare-isolated-temp-project pattern as
tests/run_puzzle_regressions.py's run_rule_regressions(), since
PuzzleAnalyzer/PuzzleCatalog need no scene, font, or GameVisualStyle
dependency.
"""

from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile
import uuid


def _isolated_env(root: Path) -> dict:
    env = dict(os.environ)
    env["APPDATA"] = str(root / "userdata")
    env["XDG_DATA_HOME"] = str(root / "userdata")
    return env


def run_structural_report(godot: str, repo: Path) -> str:
    with tempfile.TemporaryDirectory(prefix="arrowgame-puzzle-report-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        name = "ArrowGamePuzzleReport-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n', encoding="utf-8"
        )
        for script in ("puzzle_definition", "puzzle_state", "puzzle_solver", "puzzle_analyzer", "puzzle_catalog"):
            shutil.copyfile(
                repo / "scripts/puzzle" / f"{script}.gd",
                root / f"{script}.gd",
            )
        shutil.copyfile(repo / "tests/puzzle_structural_report.gd", root / "puzzle_structural_report.gd")

        # Build the global class_name cache first, same as run_puzzle_regressions.py.
        subprocess.run([godot, "--headless", "--path", str(root), "--editor", "--quit"],
                       env=env, check=True, timeout=45, capture_output=True, text=True)

        result = subprocess.run(
            [godot, "--headless", "--path", str(root), "--script", "puzzle_structural_report.gd"],
            env=env, check=True, timeout=45, capture_output=True, text=True,
        )
        if "SCRIPT ERROR:" in result.stderr or "Parse Error:" in result.stderr:
            raise RuntimeError("Godot reported a script/import error:\n" + result.stderr)
        return result.stdout


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = run_structural_report(args.godot, repo)
    print(output)


if __name__ == "__main__":
    main()
