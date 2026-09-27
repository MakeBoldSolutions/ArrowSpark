# Human Calibration Records

Collected 2026-09-27 from a real play session (Mark Hazleton) of the six new experimental puzzles,
launched via `Godot_v4.4.1-stable_win64.exe --path .` (non-headless) and played through Level
Select. Session methodology note, disclosed honestly: the tester played all six in one sitting and
gave primarily an **aggregate** reaction across all six plus one puzzle-specific follow-up
(Cascade / Key Arrow's unlock moment), rather than filling out the full per-puzzle worksheet
independently for each. Per-puzzle `score`/`mistakes`/`accuracy` were not separately recorded
during this session. Fields below are marked accordingly rather than fabricated — this is an
intentionally lightweight process (spec FR-022), and an aggregate-but-real reaction is still real
data, not a substitute for it being invented.

## Aggregate observations (apply to all six unless noted otherwise)

- **Overall perceived challenge**: 2 / 5 ("still very simple")
- **Overall scanning load**: low ("legal arrows were usually obvious at a glance")
- **Sequence discoverability**: obvious (consistent with low scanning load and the low challenge
  rating — the tester did not report needing to trace or hunt for dependencies)
- **Gameplay/scoring/performance**: explicitly called out as good, with no load or play issues —
  this is a positive result for the underlying engine work (spec 001–005), not specific to the six
  new puzzles' structural design
- **Interesting because**: none of the six specifically stood out as interesting; the tester's
  strongest reaction was to what was *missing* (see "frustrating because")
- **Frustrating because**: too many single-cell arrows across the six puzzles — "there are just
  too many single arrows which can get boring." The tester's stated hypothesis for what *would*
  create real challenge: "tightly coupled longer arrows of varying lengths" making up a level,
  requiring the player to "really think about how to sort it out," rather than dependency
  depth/density/cascade structure built mostly from single-cell arrows (which is what all six
  puzzles in this catalog actually did — see Findings Summary)

## nested_chain — Nested Chain

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: no (aggregate; not specifically distinguished from the others)
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above)
- frustrating because: too many single-cell arrows (aggregate)

## cascade_key_arrow — Cascade / Key Arrow

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: **no — explicitly asked and explicitly flat.** Removing the key arrow did
  not register as a noticeable or satisfying "that opened things up" moment, despite the analyzer
  confirming a real fan-out-3 cascade. This is the single most direct, puzzle-specific data point
  from this session (see Findings Summary — cascade-as-designed does not automatically produce
  cascade-as-felt).
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above)
- frustrating because: too many single-cell arrows (aggregate)

## dense_unravel — Dense Unravel

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: no (aggregate; not specifically distinguished from the others)
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above)
- frustrating because: too many single-cell arrows (aggregate) — notably, all 24 arrows in this
  puzzle are single-cell by design (six independent depth-3 chains); the tester's core complaint
  applies to this puzzle especially directly

## bent_network — Bent Network

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: no (aggregate; not specifically distinguished from the others)
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above)
- frustrating because: too many single-cell arrows (aggregate) — this puzzle has only 2 of its 4
  arrows bent (multi-cell); the other 2 are single-cell, and its two dependency pairs are fully
  independent of each other, which may explain why it did not read as more complex than the others
  despite having the most tail-cell-driven geometry of the six

## long_range_blocker — Long-Range Blocker

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: no (aggregate; not specifically distinguished from the others)
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above)
- frustrating because: too many single-cell arrows (aggregate) — only 1 of this puzzle's 2 arrows
  is multi-cell; with only 2 arrows total the puzzle is inherently small regardless of the ray
  distance between them

## composed_shaped — Composed / Shaped

- score / mistakes / accuracy: not recorded this session
- perceived challenge (1-5): 2 (aggregate)
- scanning load: low (aggregate)
- sequence discoverability: obvious (aggregate)
- aha / unlock moment: no (aggregate; not specifically distinguished from the others)
- felt solved before completion: not specifically recorded
- interesting because: (see aggregate notes above; the diamond shape itself was not called out
  positively or negatively)
- frustrating because: too many single-cell arrows (aggregate) — all 25 arrows in this puzzle are
  single-cell by design; the tester's core complaint applies to this puzzle especially directly
