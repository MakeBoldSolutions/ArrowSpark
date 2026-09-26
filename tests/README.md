# Save and Input Regression Checks

Run `python tests/run_regressions.py` (Python 3 and Godot on PATH), or use
`python tests/run_regressions.py --godot C:/path/to/godot.exe`.

The runner copies the relevant production scripts into a temporary project and
isolates player data. Expected engine errors exercise failure handling; success
requires exit code zero and `REGRESSION_FAILURES=0`. Each Godot process has a
45-second timeout.

Before releasing, manually check recovery-dialog layout and both choices,
keyboard/gamepad menu navigation, remapping across restart, and level progress
persistence on the supported Godot version. Headless regression checks do not
replace those interactive checks.
