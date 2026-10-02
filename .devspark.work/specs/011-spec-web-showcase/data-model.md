# Data Model: ArrowSpark Web Showcase

Temporary planning material. Entities from spec Key Entities, with fields, validation and ownership. The authority for each entity is named, and no entity is owned by two layers (FR-030).

| Entity | Authority | Lives in | Persistence |
|---|---|---|---|
| Puzzle content version | Godot rule core (pure helper) | `PuzzleContentVersion.of(definition)` | derived; Reference Knot value pinned in a test |
| Completed attempt (hand-off) | Godot controller → page bridge | iframe message → page memory | none (page visit only) |
| Pending reaction (unsent) | site UI | visitor's browser storage: at most 5 entries of `{ body, savedOn }` | until sent (`202`), rejected (`4xx`), discarded, expired (7 days), or feedback closes |
| Game reaction | site UI → API | request → one JSON file | API host storage only, purged after closeout |
| Story reaction | site UI → API | request → one JSON file | API host storage only, purged after closeout |
| Reaction record | MakeBoldSpark API | `<recordId>.json` in a dedicated server directory (never in a repo) | write-once; purged after closeout |
| Published chapter | Astro content | `web/src/content/chapters/*` | Git |
| Beat / Journey step / Evidence item / Lesson / Fact | Astro content | `web/src/content/*.yaml` | Git |
| Observed session record (raw) | owner (facilitator) | private, outside any repository | deleted after closeout |
| Anonymized session summary | owner | spec bundle `evidence/sessions/` | temporary, until release archival |
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
sending --404/405/429/5xx/network/timeout/CORS/CSP--> pending  ("Saved on this device, not sent yet. It will be sent the next time you visit while feedback is available.")
sending --(storage blocked)--> unavailable ("Feedback is temporarily unavailable. Your game and the story are unaffected.")
pending --(queue full: 5)--> notSaved ("This one couldn't be saved; you already have 5 unsent reactions.")
```

**Pending queue (FR-032):** one browser-storage key holding an array of at most 5 entries `{ body, savedOn }`.
- `body` is the request exactly as it would be POSTed.
- `savedOn` is a UTC date (`YYYY-MM-DD`), used only for the 7-day expiry and never sent.
- There are no ids and no other fields.

```
on page load (once)       -> prune entries with savedOn older than 7 days (unsent), then flush()
on save when 5 remain     -> refuse the newest with a notice (no eviction)
before a new submission   -> flush(), then send the new one
flush(): under one cross-tab lock (Web Locks API: one lock name for this queue), for each item send once:
    202                                         -> remove
    400/413/415                                 -> remove (never acceptable)
    404/405/429/5xx/network/timeout/CORS/CSP    -> keep, stop flushing (the endpoint is down or not yet deployed)
    (no other outcome deletes an entry)
Discard            -> clear the key
feedback closed    -> clear the key on load, send nothing
```

- No timers, loops, service worker or background sync.
- `sent` disables the form for that page visit, so an accidental double click doesn't double-submit. A reload allows another submission, which is a valid independent observation.
- Timeout: 8 s. The form never blocks or delays the game iframe.

## Reaction record (API side)

One file per reaction, `<recordId>.json`:

```json
{"schemaVersion":1,"receivedUtc":"2026-10-20T14:03Z","recordId":"3f9c…","reactionType":"game","readStoryFirst":"no","finished":"finished","satisfaction":4,"playAnother":"yes","comment":"…","attempt":{"puzzleId":"reference_knot","puzzleVersion":"g1-…","mistakes":2,"openMoveAssists":2,"score":103,"elapsedSeconds":1260}}
```

- Written once: temporary name, then rename. Never modified afterwards.
- Contains no IP, user agent, referrer, cookie, header or identity field.
- **Lifecycle:** `written` → `copied privately for the closeout` → `purged`, together with all copies, after the closeout report. The purge date is recorded.

## Observed session record (owner)

The raw notes are private, outside any repository, and deleted after the closeout. One **anonymized summary** per session is committed in the spec bundle. Participants are told before the session that anonymized quotes may be published; anyone who declines is paraphrased only. Summary fields:
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
