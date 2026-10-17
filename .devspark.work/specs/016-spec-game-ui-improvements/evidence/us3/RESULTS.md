# US3 rendered evidence (2026-10-16, Godot 4.4.1 rendered, isolated user data)

## FR-010: Main Menu hero

Captures: main_menu_1280x720, main_menu_1920x1080, options_1280x720.

- An ink hero holds the mark tile, "Arrow" in cream with "Spark" in ember, and the tagline.
- The actions sit in the cream column; New Game is the rust primary.
- The hero stays visible behind Options and Level Select. Fixed by keying the title and tagline visible in OpenSubMenu, because AnimationTree reset them otherwise.
- Hero title share of window height: 0.128 at 1280×720 and 0.127 at 1920×1080. The play button is unchanged (0.068–0.069).

## FR-011 / QA-08: Level Select

- Two-column cards per group with accent edges: ArrowSpark Levels rust, Foundations ink, Puzzle Lab ember.
- Group headings, descriptions and Back each get their own row.
- Opened via the Results request path (PuzzleSession.request_level_select): opens directly. PASS.
- All 30 entries measured against their card width: 0 clipped titles. ls_puzzle_lab_end shows the longest Puzzle Lab titles fitting.
- Collapse, order, numbering and selection are pinned by tests/puzzle_layout_check.gd and tests/puzzle_canvas_check.gd (both 0 failures).

## Locale

main_menu_fr: no clipping. The template's French strings are partial (some labels stay English), which is pre-existing and outside this change.
