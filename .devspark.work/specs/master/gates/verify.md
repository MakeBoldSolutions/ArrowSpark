---
gate: verify
status: pass
blocking: false
summary: Headless recovery-to-restart flow passes on Godot 4.7.2; visual/hardware
  validation is outside this proof.
modes:
- mode: end-to-end
  status: pass
  evidence: "Command: python .devspark.work/specs/master/gates/run_end_to_end.py\n\
    \nPhase: cancel\nCommand: godot --headless --path C:\\GitHub\\MakeBoldSolutions\\\
    ArrowGame --script C:\\GitHub\\MakeBoldSolutions\\ArrowGame\\.devspark.work\\\
    specs\\master\\gates\\drive_recovery.gd\nExit: 0\nGodot Engine v4.7.2.stable.official.ed1daf0bf\
    \ - https://godotengine.org\n\nPASS: real startup shows progress recovery\nPASS:\
    \ settings recovery follows progress dialog\nPASS: cancel preserves write protection\
    \ for both files\nEND_TO_END_PHASE_PASS=cancel\n\nSTDERR:\nERROR: user://global_state.tres:1\
    \ - Parse Error: Expected '['.\n   at: _printerr (scene/resources/resource_format_text.cpp:41)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Failed loading resource: user://global_state.tres.\n   at: _load (core/io/resource_loader.cpp:317)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Error loading resource: 'user://global_state.tres'.\n   at: load (core/core_bind.cpp:82)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Save could not be loaded. Original preserved; saving disabled until explicit\
    \ reset.\n   at: push_error (core/variant/variant_utility.cpp:1023)\n   GDScript\
    \ backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:33)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: ConfigFile parse error at user://config.cfg:1: Unexpected identifier 'INVALID_SETTINGS'.\n\
    \   at: _parse (core/io/config_file.cpp:293)\n   GDScript backtrace (most recent\
    \ call first):\n       [0] load_config_file (res://addons/maaacks_game_template/base/scripts/config.gd:29)\n\
    \       [1] get_config (res://addons/maaacks_game_template/base/scripts/config.gd:65)\n\
    \       [2] get_config_input_events (res://addons/maaacks_game_template/base/scripts/app_settings.gd:23)\n\
    \       [3] set_input_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:40)\n\
    \       [4] set_inputs_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:81)\n\
    \       [5] set_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:171)\n\
    \       [6] set_from_config_and_window (res://addons/maaacks_game_template/base/scripts/app_settings.gd:175)\n\
    \       [7] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:5)\n\
    ERROR: Settings could not be loaded. Original preserved; settings writes disabled.\n\
    \   at: push_error (core/variant/variant_utility.cpp:1023)\n   GDScript backtrace\
    \ (most recent call first):\n       [0] load_config_file (res://addons/maaacks_game_template/base/scripts/config.gd:34)\n\
    \       [1] get_config (res://addons/maaacks_game_template/base/scripts/config.gd:65)\n\
    \       [2] get_config_input_events (res://addons/maaacks_game_template/base/scripts/app_settings.gd:23)\n\
    \       [3] set_input_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:40)\n\
    \       [4] set_inputs_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:81)\n\
    \       [5] set_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:171)\n\
    \       [6] set_from_config_and_window (res://addons/maaacks_game_template/base/scripts/app_settings.gd:175)\n\
    \       [7] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:5)\n\
    \nPhase: reset\nCommand: godot --headless --path C:\\GitHub\\MakeBoldSolutions\\\
    ArrowGame --script C:\\GitHub\\MakeBoldSolutions\\ArrowGame\\.devspark.work\\\
    specs\\master\\gates\\drive_recovery.gd\nExit: 0\nGodot Engine v4.7.2.stable.official.ed1daf0bf\
    \ - https://godotengine.org\n\nPASS: real startup shows progress recovery\nPASS:\
    \ settings recovery follows progress dialog\nPASS: confirm resets both files and\
    \ enables persistence\nPASS: real progress and input settings written for restart\n\
    END_TO_END_PHASE_PASS=reset\n\nSTDERR:\nERROR: user://global_state.tres:1 - Parse\
    \ Error: Expected '['.\n   at: _printerr (scene/resources/resource_format_text.cpp:41)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Failed loading resource: user://global_state.tres.\n   at: _load (core/io/resource_loader.cpp:317)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Error loading resource: 'user://global_state.tres'.\n   at: load (core/core_bind.cpp:82)\n\
    \   GDScript backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:28)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: Save could not be loaded. Original preserved; saving disabled until explicit\
    \ reset.\n   at: push_error (core/variant/variant_utility.cpp:1023)\n   GDScript\
    \ backtrace (most recent call first):\n       [0] _load_or_new (res://addons/maaacks_game_template/base/scripts/global_state.gd:33)\n\
    \       [1] open (res://addons/maaacks_game_template/base/scripts/global_state.gd:40)\n\
    \       [2] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:4)\n\
    ERROR: ConfigFile parse error at user://config.cfg:1: Unexpected identifier 'INVALID_SETTINGS'.\n\
    \   at: _parse (core/io/config_file.cpp:293)\n   GDScript backtrace (most recent\
    \ call first):\n       [0] load_config_file (res://addons/maaacks_game_template/base/scripts/config.gd:29)\n\
    \       [1] get_config (res://addons/maaacks_game_template/base/scripts/config.gd:65)\n\
    \       [2] get_config_input_events (res://addons/maaacks_game_template/base/scripts/app_settings.gd:23)\n\
    \       [3] set_input_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:40)\n\
    \       [4] set_inputs_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:81)\n\
    \       [5] set_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:171)\n\
    \       [6] set_from_config_and_window (res://addons/maaacks_game_template/base/scripts/app_settings.gd:175)\n\
    \       [7] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:5)\n\
    ERROR: Settings could not be loaded. Original preserved; settings writes disabled.\n\
    \   at: push_error (core/variant/variant_utility.cpp:1023)\n   GDScript backtrace\
    \ (most recent call first):\n       [0] load_config_file (res://addons/maaacks_game_template/base/scripts/config.gd:34)\n\
    \       [1] get_config (res://addons/maaacks_game_template/base/scripts/config.gd:65)\n\
    \       [2] get_config_input_events (res://addons/maaacks_game_template/base/scripts/app_settings.gd:23)\n\
    \       [3] set_input_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:40)\n\
    \       [4] set_inputs_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:81)\n\
    \       [5] set_from_config (res://addons/maaacks_game_template/base/scripts/app_settings.gd:171)\n\
    \       [6] set_from_config_and_window (res://addons/maaacks_game_template/base/scripts/app_settings.gd:175)\n\
    \       [7] _ready (res://addons/maaacks_game_template/base/scenes/autoloads/app_config.gd:5)\n\
    \nPhase: restart\nCommand: godot --headless --path C:\\GitHub\\MakeBoldSolutions\\\
    ArrowGame --script C:\\GitHub\\MakeBoldSolutions\\ArrowGame\\.devspark.work\\\
    specs\\master\\gates\\drive_recovery.gd\nExit: 0\nGodot Engine v4.7.2.stable.official.ed1daf0bf\
    \ - https://godotengine.org\n\nPASS: restart loads recovered files without blocking\n\
    PASS: progress survives actual process restart\nPASS: keyboard remap and unchanged\
    \ gamepad axis survive restart\nEND_TO_END_PHASE_PASS=restart\n\nSTDERR:\n\nPASS:\
    \ cancel retains both originals byte-for-byte\nPASS: reset retains both original\
    \ backups byte-for-byte\nEND_TO_END_PASS\n"
---

# End-to-End Verification

Scope: current progress/settings recovery and persisted input restoration. The user
explicitly selected this mode; there was no spec or quickfix declaring other modes.
The prerequisite helper failed with `Feature directory not found` for master. The
resolved directory now holds this standalone gate, not an invented feature spec.

The ad hoc driver executes actual project autoloads and emits the actual dialog
buttons' pressed signals through their production connections. It seeds corrupt
files, exercises cancellation and reset in separate processes, and launches a third
process against the same isolated data to verify persisted state. No production
code or committed tests were written or changed by verification. The driver and
runner are temporary proof artifacts, not committed tests; no test_ref is claimed.

Evidence includes expected parse errors for intentionally malformed originals.
The restart process emitted no stderr. Full per-process output is also recorded in
`end_to_end_output.json`. The Python runner verifies byte-exact original/backup
contents before the temporary data directory is removed.

Limitations: headless, no main-scene gameplay traversal, no rendered layout review,
no physical input-device navigation, and no Godot 4.4 execution. Thus this gate
passes the scoped recovery/persistence flow; it does not waive the constitution's
outstanding interactive smoke checks or establish release readiness on Godot 4.4.

Proof drivers: `drive_recovery.gd`, `run_end_to_end.py` in this directory.

Captured: 2026-09-26T17:10:38.495811+00:00

HEAD: d5e6010f6347648b722350b248baa2c7b01a32c0

Source SHA-256 (re-run on drift):

- `addons/maaacks_game_template/base/scripts/global_state.gd`: `e65d4e5a68258c845686ba19090b1af21a6f42c5294cc49644d03cf940b82415`
- `addons/maaacks_game_template/base/scripts/config.gd`: `598777b19adaef3aae49d7a7b19a7c0fff997f46f6c4703eab89651ba69a5e02`
- `addons/maaacks_game_template/base/scripts/app_settings.gd`: `75334d06bfceb8b28f50a4c6f07508c8c043d643f7551644ae36137464245c16`
- `addons/maaacks_game_template/base/scenes/autoloads/app_config.gd`: `240e7104378ae3ed294ee60ce2c8125cee6c419176984927170b20d8347d571b`
