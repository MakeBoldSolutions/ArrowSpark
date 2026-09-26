"""Run headless Godot checks for the arrow puzzle without touching player data.

Two independent checks run:
1. Pure rule regressions (tests/puzzle_regression.gd) against an isolated,
   unique temporary project containing only the puzzle core scripts. No
   scenes, addons or autoloads are needed since PuzzleState/PuzzleDefinition
   have no Node, mouse, tween or persistence dependency (FR-012).
2. A scene-based HUD/board layout and feedback-duration check
   (tests/puzzle_layout_check.gd) against the real project (so the full
   scene tree and addon autoloads are available), with the platform
   application-data root redirected to an isolated temporary directory so no
   player save/settings data is read or written.
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


def run_rule_regressions(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-puzzle-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        name = "ArrowGamePuzzleRegression-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n', encoding="utf-8"
        )
        for script in ("puzzle_definition", "puzzle_state", "puzzle_feedback", "puzzle_results_format"):
            shutil.copyfile(
                repo / "scripts/puzzle" / f"{script}.gd",
                root / f"{script}.gd",
            )
        shutil.copyfile(repo / "tests/puzzle_regression.gd", root / "puzzle_regression.gd")
        for flags in (("--editor", "--quit"), ("--script", "puzzle_regression.gd")):
            command = [godot, "--headless", "--path", str(root), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=True, timeout=45,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            if "--script" in flags and "PUZZLE_FAILURES=0" not in result.stdout:
                raise RuntimeError("Godot did not report a completed passing puzzle rule regression run")


def run_layout_check(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-puzzle-layout-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        command = [
            godot, "--headless", "--path", str(repo),
            "--script", "res://tests/puzzle_layout_check.gd",
        ]
        print("Running:", " ".join(command), flush=True)
        result = subprocess.run(command, env=env, check=True, timeout=45,
                                capture_output=True, text=True)
        print(result.stdout, flush=True)
        print(result.stderr, flush=True)
        if "PUZZLE_LAYOUT_FAILURES=0" not in result.stdout:
            raise RuntimeError("Godot did not report a completed passing puzzle layout check")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    run_rule_regressions(args.godot, repo)
    run_layout_check(args.godot, repo)


if __name__ == "__main__":
    main()
