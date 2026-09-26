from pathlib import Path
import os
import subprocess
import tempfile
import json

gate = Path(__file__).resolve().parent
repo = gate.parents[3]
logs = []
with tempfile.TemporaryDirectory(prefix="arrowgame-e2e-") as directory:
    env = dict(os.environ, APPDATA=directory, XDG_DATA_HOME=directory)
    data = Path(directory) / "Godot/app_userdata/Game Template"
    data.mkdir(parents=True)
    originals = {"global_state.tres": "INVALID_PROGRESS", "config.cfg": "[AudioSettings]\nbroken=INVALID_SETTINGS\n"}
    for name, value in originals.items():
        (data / name).write_text(value)
    for phase in ("cancel", "reset", "restart"):
        env["VERIFY_PHASE"] = phase
        command = ["godot", "--headless", "--path", str(repo), "--script", str(gate / "drive_recovery.gd")]
        result = subprocess.run(command, env=env, timeout=30, capture_output=True, text=True)
        record = {"phase": phase, "command": command, "exit": result.returncode, "stdout": result.stdout, "stderr": result.stderr}
        logs.append(record)
        (gate / "end_to_end_output.json").write_text(json.dumps(logs, indent=2), encoding="utf-8")
        print(phase, result.stdout, result.stderr, flush=True)
        assert result.returncode == 0 and f"END_TO_END_PHASE_PASS={phase}" in result.stdout
        if phase == "cancel":
            assert all((data / name).read_text() == value for name, value in originals.items())
            print("PASS: cancel retains both originals byte-for-byte", flush=True)
        if phase == "reset":
            assert all((data / (name + ".recovery")).read_text() == value for name, value in originals.items())
            print("PASS: reset retains both original backups byte-for-byte", flush=True)
print("END_TO_END_PASS", flush=True)
