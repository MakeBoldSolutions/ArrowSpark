"""Run headless Godot checks for the arrow puzzle without touching player data.

Nine independent checks run, in execution order:
1. Pure rule regressions (tests/puzzle_regression.gd) against an isolated,
   unique temporary project containing the puzzle core scripts. No scenes,
   addons or autoloads are needed by the RefCounted rule classes.
2. Pure structural-analysis regressions (tests/puzzle_analyzer_check.gd)
   against the same bare project: hand-computed fixtures check geometry,
   dependency graphs, witness walks, determinism and non-mutation.
3. Pure catalog/session regressions (tests/puzzle_catalog_check.gd) against
   the same bare project, including scripts/puzzle/puzzle_catalog.gd and
   scripts/puzzle_session.gd. Checks all 22 catalog entries: eight baseline
   puzzles, six structural experiments, one large-canvas fixture, six
   Gordian Knot experiments and the Reference Knot, plus the three purpose
   groups (Foundations, Puzzle Lab, ArrowSpark Levels) and their queries; preserves the original 14-entry fingerprint
   baseline, pins the Reference Knot's puzzle content version
   (scripts/puzzle/puzzle_content_version.gd), and checks session selection
   and advancement.
4. Pure scoreboard checks (tests/puzzle_scoreboard_check.gd) against the
   same bare project. PuzzleScoreboard operates on result Dictionaries
   independently of PuzzleState, PuzzleDefinition, scenes and fonts.
5. Pure route-geometry regressions (tests/arrow_departure_geometry_check.gd)
   against a second isolated project containing only
   scripts/presentation/arrow_departure_geometry.gd. Style ratios are passed
   as constructor arguments, so no GameVisualStyle or font assets are needed.
6. Pure viewport-transform regressions (tests/puzzle_viewport_transform_check.gd)
   against a third isolated project containing only
   scripts/presentation/puzzle_viewport_transform.gd, with no rule, scene or
   asset dependency.
7. Scene-based HUD/board layout and feedback-duration checks
   (tests/puzzle_layout_check.gd) against the imported real project, with the
   application-data root redirected to an isolated temporary directory.
8. Integrated canvas navigation, transformed input and lifecycle checks
   (tests/puzzle_canvas_check.gd) against the real project and the same
   isolated user-data root.
9. Interaction, fonts and animation presentation checks
   (tests/puzzle_presentation_check.gd) against the real project, sharing
   the layout and canvas suites' isolated user-data root.
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
        for script in ("puzzle_definition", "puzzle_state", "puzzle_solver", "puzzle_analyzer", "puzzle_feedback", "puzzle_results_format", "puzzle_catalog", "puzzle_content_version"):
            shutil.copyfile(
                repo / "scripts/puzzle" / f"{script}.gd",
                root / f"{script}.gd",
            )
        shutil.copyfile(repo / "scripts/puzzle_session.gd", root / "puzzle_session.gd")
        shutil.copyfile(repo / "scripts/puzzle_scoreboard.gd", root / "puzzle_scoreboard.gd")
        shutil.copyfile(repo / "tests/puzzle_regression.gd", root / "puzzle_regression.gd")
        shutil.copyfile(repo / "tests/puzzle_catalog_check.gd", root / "puzzle_catalog_check.gd")
        shutil.copyfile(repo / "tests/puzzle_analyzer_check.gd", root / "puzzle_analyzer_check.gd")
        shutil.copyfile(repo / "tests/puzzle_scoreboard_check.gd", root / "puzzle_scoreboard_check.gd")
        for flags, marker in (
            (("--editor", "--quit"), None),
            (("--script", "puzzle_regression.gd"), "PUZZLE_FAILURES=0"),
            (("--script", "puzzle_analyzer_check.gd"), "PUZZLE_ANALYZER_FAILURES=0"),
            (("--script", "puzzle_catalog_check.gd"), "PUZZLE_CATALOG_FAILURES=0"),
            (("--script", "puzzle_scoreboard_check.gd"), "PUZZLE_SCOREBOARD_FAILURES=0"),
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


def run_viewport_transform_regressions(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-viewport-transform-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        name = "ArrowGameViewportTransformRegression-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n', encoding="utf-8"
        )
        shutil.copyfile(
            repo / "scripts/presentation/puzzle_viewport_transform.gd",
            root / "puzzle_viewport_transform.gd",
        )
        shutil.copyfile(
            repo / "tests/puzzle_viewport_transform_check.gd",
            root / "puzzle_viewport_transform_check.gd",
        )
        for flags in (("--editor", "--quit"), ("--script", "puzzle_viewport_transform_check.gd")):
            command = [godot, "--headless", "--path", str(root), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=True, timeout=45,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            if "--script" in flags and "PUZZLE_VIEWPORT_FAILURES=0" not in result.stdout:
                raise RuntimeError("Godot did not report a completed passing viewport transform regression run")


def run_layout_check(godot: str, repo: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="arrowgame-puzzle-layout-") as directory:
        root = Path(directory)
        env = _isolated_env(root)
        checks = (
            (("--import",), None),
            (("--script", "res://tests/puzzle_layout_check.gd"), "PUZZLE_LAYOUT_FAILURES=0"),
            (("--script", "res://tests/puzzle_canvas_check.gd"), "PUZZLE_CANVAS_FAILURES=0"),
            (("--script", "res://tests/puzzle_presentation_check.gd"), "PUZZLE_PRESENTATION_FAILURES=0"),
        )
        for flags, marker in checks:
            command = [godot, "--headless", "--path", str(repo), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=False, timeout=180,
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
    run_viewport_transform_regressions(args.godot, repo)
    run_layout_check(args.godot, repo)


if __name__ == "__main__":
    main()
