---
id: web-dependency-updates
type: authoritative-reference
title: Updating the Showcase Site's npm Packages
appliesTo:
  - web/package.json
  - web/package-lock.json
---

# Updating the Showcase Site's npm Packages

Owner direction (2026-11-08): keep `web/` dependencies aggressively current, major versions included. Hold a package back only when it demonstrably breaks a required gate, and record the hold here with the condition for lifting it.

## Current hold: TypeScript stays on 6.x

`typescript` is pinned at 6.0.3, the newest 6.x release. The latest release is 7.0.2. `npm outdated` and `npm-check-updates` will keep listing it, and that is expected.

**Lift the hold when either of these is true:**

1. A release of `@astrojs/check` lists TypeScript 7 in its `typescript` peer range. Check with `npm view @astrojs/check peerDependencies`. On 2026-11-08 the latest (0.9.12) allowed `^5.0.0 || ^6.0.0`, and its alpha and beta tags were older than that.
2. TypeScript 7.1 ships as a stable release. Then evaluate moving type checking to `@astrojs/ts-content-mapper`, described below. On 2026-11-08, 7.1 was available only as `7.1.0-beta` and dev builds.

## What happened when we tried TypeScript 7.0.2

| Attempt | Result |
| --- | --- |
| `npm install` after `npm-check-updates -u` | Failed with `ERESOLVE`: `@astrojs/check` 0.9.12 does not allow TypeScript 7 |
| Same versions with an npm `overrides` entry forcing `typescript` to `$typescript` | Installed cleanly, 0 vulnerabilities |
| `vitest run` on that install | All 59 tests passed |
| `npm run build` on that install | Passed, all 20 pages built |
| `astro check` on that install | Refused to run: "astro check does not currently support TypeScript 7.0" |

The override was removed and TypeScript returned to 6.0.3, after which `npm run check` and `npm run build` both passed again.

## Lessons

1. **The peer conflict was accurate.** `ERESOLVE` reported a real incompatibility. An override silenced npm but did not make the tools compatible, so the failure moved from install time to the check step.
2. **A green build and green tests do not validate a TypeScript upgrade.** Vitest and `astro build` both passed on a compiler that `astro check` would not run with. Only `astro check`, the first step of `npm run check`, exercises the type checker here. Treat that step as the deciding result for any TypeScript or `@astrojs/check` change.
3. **`npm run check` is a required CI step.** CI runs it in `web/`, so an override that gets past install would still fail the pipeline and block deployment.
4. **A failed install leaves `package.json` ahead of `node_modules`.** `npm-check-updates -u` rewrites `package.json` before `npm install` runs. After an `ERESOLVE`, the manifest names versions that are not installed. To recover, install the held package at its old version, for example `npm install -D -E typescript@6.0.3`, which resolves everything else in the same step.
5. **Read the "Latest" column of `npm outdated`.** Every package in `web/` is pinned to an exact version, so "Wanted" always equals "Current" and says nothing about available updates.
6. **Error messages can carry the roadmap.** The `astro check` refusal also said it will be deprecated in a future Astro release, and that experimental type checking of Astro files with TypeScript 7.1+ is available through `@astrojs/ts-content-mapper`. That replaces a required gate, so plan it as its own change rather than as part of a routine update.

## Routine update procedure

Run from `web/`:

1. `npm outdated`, `npx npm-check-updates` and `npm audit` to see the current state.
2. `npx npm-check-updates -u --reject typescript`, leaving out `--reject` once the hold above is lifted.
3. `npm install`.
4. `npm run check` and `npm run build`.
5. `npm audit` again, then a browser smoke test, which web builds require.

If a new peer conflict appears, test a way through before holding the package back, and add any new hold to this document with its lifting condition.
