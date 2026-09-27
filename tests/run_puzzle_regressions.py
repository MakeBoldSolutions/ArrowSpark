"""Run headless Godot checks for the arrow puzzle without touching player data.

Five independent checks run:
1. Pure rule regressions (tests/puzzle_regression.gd) against an isolated,
   unique temporary project containing only the puzzle core scripts. No
   scenes, addons or autoloads are needed since PuzzleState/PuzzleDefinition
   have no Node, mouse, tween or persistence dependency.
2. Pure catalog/session regressions (tests/puzzle_catalog_check.gd) against
   the same bare temporary project as (1), extended with
   scripts/puzzle/puzzle_catalog.gd and scripts/puzzle_session.gd:
   PuzzleCatalog depends only on PuzzleDefinition, so it is safe to add
   directly to the existing pure-rule-isolation project rather than a new
   temporary project.
3. Pure route-geometry regressions (tests/arrow_departure_geometry_check.gd)
   against a second isolated, unique temporary project containing only
   scripts/presentation/arrow_departure_geometry.gd. The helper takes its
   style-ratio constants as constructor arguments rather than referencing
   GameVisualStyle directly, so this suite needs no font/resource assets and
   keeps the same pure-script isolation as the rule regressions above.
4. A scene-based HUD/board layout and feedback-duration check
   (tests/puzzle_layout_check.gd) against the real project (so the full
   scene tree and addon autoloads are available), with the platform
   application-data root redirected to an isolated temporary directory so no
   player save/settings data is read or written.
5. Interaction, fonts and animation presentation checks after a real-project
   import, sharing the layout suite's isolated user-data root.
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
        for script in ("puzzle_definition", "puzzle_state", "puzzle_solver", "puzzle_feedback", "puzzle_results_format", "puzzle_catalog"):
            shutil.copyfile(
                repo / "scripts/puzzle" / f"{script}.gd",
                root / f"{script}.gd",
            )
        shutil.copyfile(repo / "scripts/puzzle_session.gd", root / "puzzle_session.gd")
        shutil.copyfile(repo / "tests/puzzle_regression.gd", root / "puzzle_regression.gd")
        shutil.copyfile(repo / "tests/puzzle_catalog_check.gd", root / "puzzle_catalog_check.gd")
        for flags, marker in (
            (("--editor", "--quit"), None),
            (("--script", "puzzle_regression.gd"), "PUZZLE_FAILURES=0"),
            (("--script", "puzzle_catalog_check.gd"), "PUZZLE_CATALOG_FAILURES=0"),
        ):
            command = [godot, "--headless", "--path", str(root), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=True, timeout=45,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            if marker and marker not in result.stdout:
                raise RuntimeError(f"Godot did not report {marker}")


def run_geometry_regressions(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-departure-geometry-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        name = "ArrowGameDepartureGeometryRegression-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n', encoding="utf-8"
        )
        shutil.copyfile(
            repo / "scripts/presentation/arrow_departure_geometry.gd",
            root / "arrow_departure_geometry.gd",
        )
        shutil.copyfile(
            repo / "tests/arrow_departure_geometry_check.gd",
            root / "arrow_departure_geometry_check.gd",
        )
        for flags in (("--editor", "--quit"), ("--script", "arrow_departure_geometry_check.gd")):
            command = [godot, "--headless", "--path", str(root), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=True, timeout=45,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            if "--script" in flags and "ARROW_DEPARTURE_GEOMETRY_FAILURES=0" not in result.stdout:
                raise RuntimeError("Godot did not report a completed passing arrow departure geometry regression run")


def run_layout_check(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-puzzle-layout-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        checks = (
            (("--import",), None),
            (("--script", "res://tests/puzzle_layout_check.gd"), "PUZZLE_LAYOUT_FAILURES=0"),
            (("--script", "res://tests/puzzle_presentation_check.gd"), "PUZZLE_PRESENTATION_FAILURES=0"),
        )
        for flags, marker in checks:
            command = [godot, "--headless", "--path", str(repo), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=False, timeout=90,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            result.check_returncode()
            if "SCRIPT ERROR:" in result.stderr or "Parse Error:" in result.stderr:
                raise RuntimeError("Godot reported a script/import error")
            if marker and marker not in result.stdout:
                raise RuntimeError(f"Godot did not report {marker}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    run_rule_regressions(args.godot, repo)
    run_geometry_regressions(args.godot, repo)
    run_layout_check(args.godot, repo)


if __name__ == "__main__":
    main()
