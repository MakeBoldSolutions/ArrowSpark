# Contract: Showcase Content Collections

**Owner:** `web/` in this repository.
**Purpose:** one durable source per fact. Pages render from these collections; no page template restates a figure that a collection holds. The build fails on any schema violation.

## Global rules (enforced by `web/scripts/check-content.mjs` and the collection schemas)

- **R-1:** no content file, data file or built page contains the substring `.devspark.work`.
- **R-2:** every evidence `url` is either an internal site path (`/…`) or a commit-pinned repository permalink matching `^https://github\.com/MakeBoldSolutions/ArrowSpark/(blob|tree|commit)/[0-9a-f]{40}(/.*)?$`, or a merged pull request URL `^https://github\.com/MakeBoldSolutions/ArrowSpark/pull/\d+$`.
- **R-3:** no published file contains an author placeholder (`TODO(`, `<!-- TODO`, `[Mark`, `Mark:`).
- **R-4 (pre-play scan):** the built landing page, Play page and game-loading markup, plus the text of `scenes/menus/**/*.tscn` and `scenes/loading_screen/**/*.tscn`, contain none of: *neighborhood, neighbourhood, bridge arrow, insight chain, discovery beat, major release, meaningful density, spaghetti, zone*. The scan is case-insensitive.
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

The published set is parts 1-6 as refreshed, part 7 split (Spec 009 and the audit only), part 8 (Reference Knot, `spoiler: true`), and part 9 "Now It's Your Turn". Parts 5 and 7 are `spoiler: true` where they use design vocabulary.

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
