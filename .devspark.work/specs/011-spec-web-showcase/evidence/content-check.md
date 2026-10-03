# Content check (2026-10-02)

| Check | Command | Result |
|---|---|---|
| Types and schemas | `npx astro check` (in `web/`) | 0 errors, 0 warnings, 0 hints (42 files); every content collection validates (R-2 evidence URLs enforced in the schema) |
| Unit tests | `npx vitest run` | pass (game bridge 9/9 at this point) |
| Source publication checks (R-1, R-2, R-3, R-5, theme literals, pre-play words) | `node scripts/check-content.mjs` | `check-content: ok` |
| Built-output checks (R-1 on `dist`, R-4 on landing, Play, Journey) | `npm run build` (runs `check-content.mjs --dist`) | 15 pages built; `check-content: ok` |
| Link liveness | `node scripts/check-content.mjs --fetch-links` | 103 URLs checked; **1 failure**: `commit/b859b4bf8c3dde72bc124f55d7b894b3fd8714a8` → HTTP 404. That commit (the development-corpus refresh recording "Web gate: Not met") is on this branch and not yet pushed; it resolves once the branch is pushed and stays permanent after merge. Re-run before publication |

- Chapters 01-08: `status: published`. Chapter 09: `status: draft` pending owner confirmation of its framing.
- Spoiler flags (from final text): 05, 07, 08 `true` (design vocabulary or Reference Knot design detail); 01-04, 06, 09 `false`.
- Planning identifiers: chapters describe findings in words; commit subjects quoted in receipts tables have `FR-`/`SC-`/`T`/review IDs replaced by a short description (stated in each receipts intro).
- Puzzle content version is **not yet** among the published board facts: its only durable source (`tests/puzzle_catalog_check.gd` with the pin) exists only in uncommitted work. Add it to `facts.yaml` with a commit-pinned link once committed.
- **Owner review of chapters 01-09 not yet performed.**
