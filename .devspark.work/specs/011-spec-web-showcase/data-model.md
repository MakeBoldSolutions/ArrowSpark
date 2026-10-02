# Data Model: ArrowSpark Web Showcase

Temporary planning material. Entities from spec Key Entities, with fields, validation and ownership. The authority for each entity is named, and no entity is owned by two layers (FR-030).

| Entity | Authority | Lives in | Persistence |
|---|---|---|---|
| Puzzle content version | Godot rule core (pure helper) | `PuzzleContentVersion.of(definition)` | derived; Reference Knot value pinned in a test |
| Completed attempt (hand-off) | Godot controller → page bridge | iframe message → page memory | none (page visit only) |
| Game reaction | site UI → API | request → SQLite row | API storage only |
| Story reaction | site UI → API | request → SQLite row | API storage only |
| Reaction record | MakeBoldSpark API | existing SQLite database, new table | insert-only |
| Published chapter | Astro content | `web/src/content/chapters/*` | Git |
| Beat / Journey step / Evidence item / Lesson / Fact | Astro content | `web/src/content/*.yaml` | Git |
| Observed session record | owner (facilitator) | spec bundle `evidence/sessions/` | temporary, until release archival |
| Learning window | owner | spec bundle `evidence/window.md` | temporary |

## Puzzle content version

- **Input:** `PuzzleDefinition`, meaning `width`, `height`, `arrows` (head → direction) and `tails` (head → ordered cells).
- **Canonical text:** `w:<width>;h:<height>;` then, for each head sorted by (y, x): `<x>,<y>,<direction>:<tx>,<ty>|<tx>,<ty>…;`
- **Value:** `"g1-" + sha256(canonical).substr(0, 12)`. The prefix `g1` names the canonicalization scheme. Changing the scheme means `g2`.
- **Invariants:**
  - deterministic;
  - independent of the app version, catalog order, title or group;
  - changes if and only if geometry changes.
- **Pinning:** the Reference Knot's value is a literal constant in `tests/puzzle_catalog_check.gd` (FR-009).

## Completed attempt (`attemptCompleted` v1)

See [contracts/attempt-completed-event.md](contracts/attempt-completed-event.md).
- **State transitions:** none in the page. The bridge holds `latest: Attempt | null`. A valid event replaces it, and a page reload clears it.
- **Attached to a game reaction** only when the visitor submits one.

## Game reaction / Story reaction

See [contracts/reactions-api.md](contracts/reactions-api.md). Client-side form state:

```
idle --(visitor answers)--> editing --(Send)--> sending
sending --202--> sent            ("Thanks. Nothing here is required.")
sending --400/413/415--> invalid ("Something in this reaction couldn't be sent.")  # should not occur; the client validates first
sending --429/5xx/network/timeout--> unavailable ("Feedback is temporarily unavailable. Your game and the story are unaffected.")
```

- No retry loop and no local queue (FR-032, minimum fallback).
- `sent` disables the form for that page visit, so an accidental double click doesn't double-submit. A reload allows another submission, which is a valid independent observation.
- Timeout: 8 s. The form never blocks or delays the game iframe.

## Reaction record (API side)

| Column | Type | Notes |
|---|---|---|
| `RecordId` | TEXT (GUID), PK | random, server-generated, internal only |
| `SchemaVersion` | INTEGER | 1 |
| `ReceivedUtc` | TEXT (ISO 8601, minute precision) | truncated server time |
| `ReactionType` | TEXT | `game` / `story` |
| `Payload` | TEXT (JSON) | validated, canonical re-serialization |

- Insert-only.
- No IP, user agent, referrer, cookie, header or identity column.

## Observed session record (owner)

One Markdown file per session in the spec bundle, with these fields:
- session date, and a participant label that is a sequence number only (no name);
- **order followed** (must be: landing impression → fresh play → fresh-play interview → Built with DevSpark → DevSpark comprehension). Any deviation is recorded;
- **story seen before play?** (yes or no; yes excludes the session from SC-007);
- landing impression (SC-002);
- the facilitator checklist (showcase-research §13, 14 items), with the participant's words as given;
- discovery: Level Select opened? ArrowSpark Levels found? time taken? starting entry;
- facilitator influence;
- objective data: completed?, mistakes, assists, score (from the Results screen), elapsed time (facilitator's clock), and the puzzle content version. The version is the pinned Reference Knot value, which the Evidence page also lists among the board facts, so the facilitator copies it from there and never has to read it out of the game;
- DevSpark comprehension (SC-011): what DevSpark is, where it helped, and where it failed, in the participant's own words.

## Learning window

`evidence/window.md`:
- `published_reachable_at`: the date `https://arrow.makeboldspark.com` first served the showcase;
- `closes_at`: that date + 14 days;
- `api_available_from`: when the reactions endpoint began accepting submissions, if later.

It is never extended (FR-020).
