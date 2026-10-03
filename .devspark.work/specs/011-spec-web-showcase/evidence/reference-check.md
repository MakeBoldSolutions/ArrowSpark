# Reference, infrastructure and knowledge checks (pre-publication pre-check, 2026-10-02)

## Planning references

- `bash .devspark/scripts/bash/check-planning-references.sh --json` → `ok: false` with two findings, both **pre-existing on `main`** and not touched by this branch: `.knowledge/guides/repo-story/history.json:703` (`T025`, `T026`, quoted commit subjects; introduced in `8101b00`). Classified: Deferred Work (generated repo-story file; regenerate or redact separately).
- The script scans tracked files only, so the new untracked durable files were scanned by hand: `grep -rnIE "\.devspark\.work|\bFR-[0-9]{3}\b|\bSC-[0-9]{3}\b|\bT[0-9]{3}\b|011-spec|spec\.md|plan\.md|tasks\.md|critic-0[0-9]|analyze-[A-Z][0-9]"` over `scripts scenes tests web/src web/scripts web/theme web/THEME.md web/game-shell web/staticwebapp.config.json web/astro.config.mjs .knowledge .github CLAUDE.md AGENTS.md export_presets.cfg`:
  - fixed: a comment in `web/scripts/check-content.mjs` named the planning directory; reworded;
  - pre-existing, not from this branch: `tests/puzzle_regression.gd:268` (`analyze-F1`, since `0ec2dda`);
  - accepted: chapter 05's receipts table quotes a historical commit subject containing the word `tasks.md` (no path, no link);
  - framework conventions, not references to a planning document: `CLAUDE.md`, `AGENTS.md` and the constitution describe the `.devspark.work/` directory itself;
  - `web/src/lib/content-rules.mjs` defines the forbidden name for the checker; the checker excludes it.
- Published content: chapters describe review and criterion findings in words; receipts replace planning IDs with descriptions. `node web/scripts/check-content.mjs` and `--dist`: ok.

## No new identity or platform infrastructure

`grep -rnIiE "analytics|gtag|google-analytics|plausible|segment\.io|mixpanel|sentry|login|signin|account|document\.cookie|fingerprint|uuid|randomUUID|indexedDB|sessionStorage|serviceWorker|sendBeacon"` over `web/src web/scripts web/game-shell`: only prose matches ("account for", "isEntry"). No authentication, accounts, visitor identity, tracking, analytics, dashboard, survey engine, CMS or database. The only browser storage the site uses is the pending-reaction queue key; the game shell's service-worker branch was removed.

## Knowledge index

`python .devspark/scripts/build_knowledge_index.py --repo-root .` → 10 nodes, no dangling references, no stale entities. New or updated: `web-showcase` (`appliesTo: web/**, export_presets.cfg, .github/workflows/showcase.yml`), `arrow-puzzle` (adds `puzzle_content_version.gd`, `web_attempt_emitter.gd`, `puzzle_select_menu.gd`), `save-progression`, `product-branding` (adds the site header and footer), `arrowgame-constitution` (adds `export_presets.cfg`, `web/**`). Every new file is covered by at least one node's `appliesTo`.

**To re-run after the window closes (T079 proper).**
