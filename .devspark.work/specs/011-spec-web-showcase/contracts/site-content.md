# Contract: Showcase Content Collections

**Owner:** `web/` in this repository.
**Purpose:** one durable source per fact. Pages render from these collections; no page template restates a figure that a collection holds. The build fails on any schema violation.

## Global rules (enforced by `web/scripts/check-content.mjs` and the collection schemas)

- **R-1:** no content file, data file or built page contains the substring `.devspark.work`, in any form (relative path, branch URL or commit-pinned URL). Published content never links to temporary spec, plan, task, gate or development documents, live or archived.
- **R-2 (evidence hierarchy):** every evidence `url` is one of the following, in order of preference:
  1. a durable `.knowledge/` document;
  2. code or tests;
  3. a merged PR (`^https://github\.com/MakeBoldSolutions/ArrowSpark/pull/\d+$`);
  4. a commit (`…/commit/<40-hex>`) or a commit-pinned durable file (`…/(blob|tree)/<40-hex>/<path>`, where `<path>` is not under `.devspark.work/`);
  5. an internal site path (`/…`).

  Temporary gate or planning evidence may appear only as a short quotation or paraphrase in the text, attributed and supported by an `evidence` entry pointing at the durable commit or PR that shows the resulting decision or change. Items 1 and 2 are linked as commit-pinned permalinks.
- **R-3:** no published file contains an author placeholder (`TODO(`, `<!-- TODO`, `[Mark`, `Mark:`).
- **R-4 (pre-play scan):** every surface a first-time visitor can reach before playing contains none of the words below. The scanned set is:
  - the built landing page, the Play page and the game-loading/pre-play shell markup;
  - the built Journey page (reachable before play);
  - the built site header, footer and the desktop-only notice;
  - the text of `scenes/menus/**/*.tscn` and `scenes/loading_screen/**/*.tscn`;
  - the string literals in `scenes/menus/**/*.gd`, including `puzzle_select_menu.gd`.

  Only visible text is scanned: HTML text nodes, plus `alt`, `title` and `aria-label` values. Script, style, other attributes and code are excluded, and matching is whole-word and case-insensitive. Pages behind a play-first note (spoiler chapters, design beats) and the rest of the repository are not scanned. The prohibited words are: *neighborhood, neighbourhood, bridge arrow, insight chain, discovery beat, major release, meaningful density, spaghetti, zone*. The scan is case-insensitive.
- **Link liveness:** fetching every external URL (`check-content.mjs --fetch-links`) runs as a pre-publication step and on a schedule, never on every push, to avoid rate-limit flakiness. The offline pattern checks (R-1, R-2) run on every build.
- **R-5:** every fact with a number carries a `source` (a permanent URL per R-2), and where the number is derived, a `command` that reproduces it.

## Collections

### `chapters` (Markdown or MDX, `src/content/chapters/NN-slug.md(x)`)

```yaml
title: string            # required
part: integer            # 1..9; 9 = closing chapter
slug: string             # url segment
description: string      # one paragraph summary for the index
spoiler: boolean         # true -> page renders the play-first note (FR-016)
status: draft | published # only `published` builds into the site
sources:                 # evidence the chapter relies on (R-2)
  - label: string
    url: string
updated: date
```

The published set is parts 1-6 as refreshed, part 7 split (Spec 009 and the audit only), part 8 (Reference Knot, `spoiler: true`), and part 9 "Now It's Your Turn". Any published chapter is `spoiler: true` if it contains Reference Knot design vocabulary or level-specific design details. This is decided from its final published text, not fixed by chapter number.

### `beats` (YAML data, `src/content/beats.yaml`): Built with DevSpark

```yaml
- n: integer
  title: string
  belief: string | null
  evidence: string
  decision: string
  sources: [{label, url}]   # at least one
  spoiler: boolean          # beats that discuss the Reference Knot's design
```

### `journey` (YAML data, `src/content/journey.yaml`): shared and spoiler-light

```yaml
- n: integer
  title: string
  changed: string
  learned: string
  chapter: slug | null      # link to the chapter that tells it
```

Journey entries must not contain R-4 words. The Journey is reachable before play.

### `evidence` (YAML data, `src/content/evidence.yaml`)

```yaml
automated:   [{title, detail, source, command?}]
human:       {baseline: string, sources: [{label, url}]}
notClaimed:  [string]
limitations: [{item, class: accepted-limitation | deferred | not-performed, source}]
```

### `lessons` (YAML data, `src/content/lessons.yaml`)

```yaml
worked:  [{text, source}]
didnt:   [{text, source}]
```

### `facts` (YAML data, `src/content/facts.yaml`): Reference Knot and clock figures

```yaml
referenceKnot: [{value, label, source}]     # descriptive only; rendered with the "describe, not judge" note
clock: {cutoffCommit: <40-hex>, items: [{label, value, command}]}
```
