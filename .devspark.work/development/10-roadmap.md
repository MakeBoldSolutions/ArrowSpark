# ArrowSpark Roadmap

## Roadmap Philosophy

The roadmap is evidence-driven.

Do not add systems merely because successful games often contain them.

Each major step should remove one constraint or answer one uncertainty.

> **Status note (2026-11-08):** Specs 001--018 are complete and the next spec is not yet
> specified. Note that generation arrived earlier than this file planned (see below).
> (2026-10-11 note: Specs 001--012 were complete.)
> (2026-10-01 note: Specs 001--010 were complete and the next spec was
> expected to be a Web Showcase & Playtest.) (2026-09-28 note: Specs 001--007
> were complete and Spec 008 was in progress.) The detailed, living plan for Specs 008--010 is
> [13-roadmap-008-010.md](13-roadmap-008-010.md); it supersedes this file where
> they differ. This file remains the longer-range view.

## Done --- Specs 001--007

Spec 007 (Open Move and session scoring) is complete and merged. Its manual
desktop checks passed on 2026-09-28.

## Done --- Spec 008: Large Zoomable Puzzle Canvas

Status: complete; merged as PR #1 on 2026-09-28.

Question answered:

**Can puzzle size be independent of screen size?**

Capabilities: - zoom; - pan; - Fit Puzzle; - robust input transforms; -
keyboard/gamepad navigation; - off-screen assist reveal; - transformed
departure animation; - resize stability.

This is an enabling architecture specification.

## Done --- Spec 009: Gordian Knot Experiments

Status: complete; merged as PR #2 on 2026-09-29. Six hand-authored experiments
shipped, with one aggregate author playtest (per-puzzle detail not recorded).
The suggested experiment set below is the original plan; the shipped set is
in `.knowledge/reference/gordian-knot-experiments.md`.

## Done --- Spec 010: Reference Puzzle and Level Groups

Not in the original roadmap. Added purpose groups, accordion Level Select and a
hand-composed Reference Knot. Complete with documented limitations; merged as
PR #4 on 2026-10-01. See [08-current-state.md](08-current-state.md).

## Done --- Spec 011: Web Showcase and Spec 012: Mobile Web Play

Spec 011 shipped the playable Web build, story site and anonymous reactions
client (PR #5, 2026-10-03). Spec 012 made it a mobile web beta: PR #6
(2026-10-03) admitted touch landscape screens, and PR #8 (2026-10-11) made touch
modeless (tap, one-finger pan, pinch). Modeless touch was later verified on one
Pixel 7 Pro in Chrome; iPhone remains unrun. See [08-current-state.md](08-current-state.md).

## Done --- Specs 013--018

Progression levels and world canvas (013, PR #9), codebase consolidation (014,
PR #10), deferred follow-ups (015 quickfix, PR #11), game UI (016, PR #13),
portrait play (017, PR #14), level packs and a seeded generator (018, PR #16).
History is in [01-project-history.md](01-project-history.md), sections 18--22.

## Now --- Get outside players (not yet specified)

The site exists to bring in outside players and with them the deferred
fresh-player validation (the SC-009 protocol). It remains open; the owner is still
the only tester. The real-phone portrait check was closed on 2026-11-08.

### Original Spec 009 plan (historical)

Question answered:

**What kind of hard puzzle is satisfying to untangle?**

Suggested experimental set:

### Experiment A --- Long Lines

Moderate board. 8--10 arrows. Most arrows 3--6+ cells. Several bends.
Whitespace remains.

Purpose: establish baseline payoff of long geometry.

### Experiment B --- Interwoven

10--14 arrows. Most multi-cell. Tails occupy each other's visual
neighborhoods. Cross-board relationships.

Purpose: test geometric tracing without extreme density.

### Experiment C --- Dense Knot

15--20 arrows. Long, multi-bend paths. Dense central structure.
Dependencies frequently created by tails.

Purpose: test the core Gordian-knot experience.

### Experiment D --- Spaghetti

Deliberately excessive entanglement.

Purpose: find the readability boundary.

Potential additional experiments: - regional knot with open perimeter; -
one huge key arrow whose removal transforms the board; - multiple nested
regions; - composed macro shape.

## Playtest Questions

For each experiment: - How challenging did it feel? - How long before
the first confident move? - Did you trace arrows or simply scan heads? -
Did any removal produce an "aha"? - Did the board visibly simplify? -
Were there too many trivial singles? - Did any region become
unreadable? - How often was Open Move used? - Did Open Move restore
momentum or spoil discovery? - Did zoom/pan help reasoning or become
friction?

## Web Playtest Build

Once the game has a few genuinely interesting puzzles, Web becomes a
strong distribution channel.

Purpose:

`send a link → play immediately → get human feedback`

Web should not become a large platform project.

Initial acceptance (met for desktop; mobile web is a beta): - modern desktop/mobile browser; - play catalog; -
zoom/pan where supported; - Open Move; - results; - session scoring; -
no install; - no login.

## Anonymous Feedback API

Purpose:

**Learn how to evolve the game.**

Not: - remember users; - build profiles; - track people.

Boundary: one submitted gameplay session is one independent observation.

Potential aggregate fields: - puzzle/version; - completion; - elapsed
time; - mistakes; - Open Move assists; - final score; - replay count
within session; - local session-best improvement; - optional perceived
challenge; - optional free-text feedback.

No persistent player ID is required.

The game must continue if feedback submission fails or is unavailable.

## Correlating Three Evidence Sources

Future design research can combine:

### PuzzleAnalyzer

What structure does the puzzle objectively contain?

### Gameplay observations

What did players actually do?

### Human feedback

What did players think/feel?

This triangulation is more valuable than any one source alone.

## Later --- Difficulty Characterization

Only after enough playtesting: - identify geometry that correlates with
challenge; - identify geometry that correlates with satisfaction; -
distinguish difficulty from annoyance; - characterize the spaghetti
boundary; - determine useful puzzle families.

Avoid collapsing everything into one "difficulty score" prematurely.

## Later --- Tuning Procedural Generation

Status (2026-11-08): the generator itself shipped in Spec 018 as developer
tooling, ahead of the evidence this section asked for. It targets analyzer metric
ranges and has not been tuned. The condition below now applies to *tuning* it and
to shipping generated content as more than a labelled sample.

Generation becomes appropriate only when the project can state useful
constraints such as: - desired long-arrow ratio; - bend distribution; -
density range; - entanglement characteristics; - visual payoff; -
solvability; - readability; - regional structure.

Every generated puzzle would still require: - structural validation; -
solver confirmation; - potentially analyzer thresholds.

Human calibration remains essential.

## Possible Much-Later Product Questions

These are intentionally undecided: - durable progress; - persistent
scores; - achievements; - daily puzzles; - mobile stores; -
monetization; - competitive features.

None should be assumed.

ArrowSpark currently benefits from being a clean puzzle rather than a
retention system.
