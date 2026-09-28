"""Run Godot persistence/input checks without touching the game's player data."""

from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile
import uuid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="arrowgame-regression-") as directory:
        root = Path(directory)
        # Redirect the platform's application-data root, with a unique project name
        # as a second isolation boundary if a platform ignores the environment.
        env = dict(os.environ)
        env["APPDATA"] = str(root / "userdata")
        env["XDG_DATA_HOME"] = str(root / "userdata")
        name = "ArrowGameRegression-" + uuid.uuid4().hex
        (root / "project.godot").write_text(
            f'config_version=5\n[application]\nconfig/name="{name}"\n'
            '[autoload]\nSceneLoader="*res://scene_loader_stub.gd"\n',
            encoding="utf-8",
        )
        for script in ("global_state", "global_state_data", "app_settings", "config"):
            shutil.copyfile(
                repo / "addons/maaacks_game_template/base/scripts" / f"{script}.gd",
                root / f"{script}.gd",
            )
        shutil.copyfile(
            repo / "addons/maaacks_game_template/base/scenes/menus/main_menu/main_menu.gd",
            root / "main_menu.gd",
        )
        # game_state.gd hardcodes FILE_PATH = "res://scripts/game_state.gd" for
        # GlobalState.get_state()'s dynamic load(), so it must keep that
        # relative path in the isolated project, not sit flat at the root.
        (root / "scripts").mkdir(exist_ok=True)
        for script in ("game_state", "level_state", "puzzle_session", "puzzle_scoreboard"):
            shutil.copyfile(repo / "scripts" / f"{script}.gd", root / "scripts" / f"{script}.gd")
        (root / "scripts/puzzle").mkdir(exist_ok=True)
        for script in ("puzzle_definition", "puzzle_catalog"):
            shutil.copyfile(
                repo / "scripts/puzzle" / f"{script}.gd",
                root / "scripts/puzzle" / f"{script}.gd",
            )
        shutil.copyfile(
            repo / "scenes/menus/main_menu/main_menu_with_animations.gd",
            root / "main_menu_with_animations.gd",
        )
        shutil.copyfile(repo / "tests/scene_loader_stub.gd", root / "scene_loader_stub.gd")
        shutil.copyfile(repo / "tests/save_input_regression.gd", root / "regression.gd")
        for flags in (("--editor", "--quit"), ("--script", "regression.gd")):
            command = [args.godot, "--headless", "--path", str(root), *flags]
            print("Running:", " ".join(command), flush=True)
            result = subprocess.run(command, env=env, check=True, timeout=45,
                                    capture_output=True, text=True)
            print(result.stdout, flush=True)
            print(result.stderr, flush=True)
            if "--script" in flags and "REGRESSION_FAILURES=0" not in result.stdout:
                raise RuntimeError("Godot did not report a completed passing regression run")


if __name__ == "__main__":
    main()
