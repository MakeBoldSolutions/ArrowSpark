# Browser smoke and queue evidence

## Local automated runs (2026-10-02), not the three-browser smoke test

These were driven by Playwright 1.63 (Chromium 153 headless) against `astro preview` of a local build with `PUBLIC_REACTIONS_URL=http://localhost:8787` and `web/scripts/mock-reactions.mjs`. They are **not** the FR-025 three-browser smoke test on the SWA preview, which is still **not performed** (needs the SWA preview environment, Firefox and Safari on macOS, and a human player).

### Pending-queue lifecycle (SC-014, SC-006)

| Step | Result |
|---|---|
| Story reaction with the mock in `unavailable` (503) | status "Saved on this device, not sent yet…"; storage holds `[{"body":{…contract fields…},"savedOn":"2026-10-03"}]`; pending note and Discard control shown |
| Game reaction while unavailable (no attempt held) | saved; 2 entries; 0 accepted by the mock |
| Mock switched to `accept`, page reloaded | both entries accepted once (#1 story, #2 game); storage cleared |
| Second reload | still 2 accepted (no duplicate sends) |
| Five more while unavailable, then a sixth | sixth refused: "This one couldn't be saved: you already have 5 unsent reactions on this device."; 5 entries kept |
| Discard unsent feedback | storage cleared; "Unsent feedback discarded from this device." |
| Requests (devtools-equivalent inspection) | body keys only `reactionType, madeSense, wouldUse, comment, readStoryFirst, satisfaction`; no cookie header on any request |
| Storage blocked (`localStorage` throws) | "Feedback is temporarily unavailable. Your game and the story are unaffected." |
| Page errors | none |

### Real two-tab flush (critic-015), Chromium

One browser profile, two tabs. Four story reactions saved while the mock was unavailable; mock switched to `accept`; both tabs reloaded at the same moment. Web Locks available (`'locks' in navigator` true). Repeated three times:

| Run | Mock log (accepted this run) | Each exactly once | Both queues empty |
|---|---|---|---|
| 1 | two-tab 1, 2, 3, 4 | yes (4) | yes |
| 2 | two-tab 1, 2, 3, 4 | yes (4) | yes |
| 3 | two-tab 1, 2, 3, 4 | yes (4) | yes |

### Production CSP enforced locally (critic-013), Chromium

`dist` served by a local stand-in that applies `dist/staticwebapp.config.json` exactly (global headers, `/game/*` and `/_astro/*` cache headers, `.wasm`/`.pck` MIME types). Local evidence only; the policy's authority is the SWA preview.

| Check | Result |
|---|---|
| Headers | `Content-Security-Policy` as generated; `Cache-Control: no-cache` on HTML; `public, max-age=31536000, immutable` and `application/wasm` on `/game/<build>/index.wasm` |
| Build-time inline check | first run **failed the build**: Astro's code highlighter put `style` attributes on `<pre>` in 8 chapters. Fixed by `markdown.syntaxHighlight: false` |
| Synthetic check, first policy | engine started, but **CSP violation**: `img-src` blocked a `blob:` image from the Godot runtime |
| Fix | `blob:` added to `img-src` only (no other directive changed) |
| Synthetic check after fix | `Game engine state: started`; "Synthetic check passed." (no console error, no CSP violation) |
| Full play-through under CSP (spike driver build) | Reference Knot cleared to results; exactly one `attemptCompleted` message; no CSP violation, no console error |
| Game reaction after completion | sent (`202` from the mock); body `{"reactionType":"game","finished":"finished","comment":"Tested end to end.","attempt":{"puzzleId":"reference_knot","puzzleVersion":"g1-7ce0942d4a5e","mistakes":0,"openMoveAssists":115,"score":0,"elapsedSeconds":4}}` |
| Queue lifecycle and two-tab flush under CSP (`connect-src` includes the mock origin) | same results as above; each of 4 entries exactly once; queues empty |

## Three-browser smoke on the SWA preview (FR-025)

Not performed. Requires the Azure Static Web App (owner action), Chromium-based (Windows), Firefox (Windows) and Safari (macOS), and a human player.
