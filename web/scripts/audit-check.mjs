#!/usr/bin/env node
// Fails on any high or critical npm advisory except the ones explicitly allowed below.
//
// `npm audit` has no per-advisory ignore, so this runs `npm audit --json` and checks each
// advisory itself. An allowed advisory needs a reason and is removed once a fixed version can
// be installed; any advisory not listed here still fails the build.
import { spawnSync } from 'node:child_process';

const ALLOWED = {
  // http-cache-semantics <= 4.2.0 (no patched release), pulled in only by astro. Astro uses it
  // only to cache remote images at build time; this site has no remote images and ships static
  // files with no server-side HTTP cache, so the max-stale disclosure cannot occur.
  // Remove when a patched http-cache-semantics reaches astro.
  'GHSA-ch52-4w7c-c8xp': 'build-time only; no remote images; static output',
};

const BLOCKING = new Set(['high', 'critical']);

const result = spawnSync('npm audit --json', { encoding: 'utf8', shell: true });
let report;
try {
  report = JSON.parse(result.stdout);
} catch {
  console.error('audit-check: npm audit did not return JSON');
  console.error(result.stderr || result.stdout);
  process.exit(2);
}
if (report.error) {
  console.error(`audit-check: npm audit failed: ${report.error.summary ?? JSON.stringify(report.error)}`);
  process.exit(2);
}

// Each vulnerable package lists its own advisories as objects in `via`; string entries only
// point at another vulnerable package, whose own entry carries the advisory.
const advisories = new Map();
for (const [name, entry] of Object.entries(report.vulnerabilities ?? {})) {
  for (const via of entry.via ?? []) {
    if (typeof via !== 'object' || !BLOCKING.has(via.severity)) continue;
    const id = String(via.url ?? '').split('/').pop() || String(via.source);
    advisories.set(id, `${name}: ${via.title} (${via.severity}) ${via.url ?? ''}`.trim());
  }
}

let failed = false;
for (const [id, description] of advisories) {
  if (id in ALLOWED) {
    console.log(`audit-check: allowed ${id} — ${description} — ${ALLOWED[id]}`);
  } else {
    console.error(`audit-check: ${id} — ${description}`);
    failed = true;
  }
}
for (const id of Object.keys(ALLOWED)) {
  if (!advisories.has(id)) console.log(`audit-check: ${id} no longer reported; remove it from the allowlist`);
}
if (failed) process.exit(1);
console.log('audit-check: ok (no unallowed high or critical advisories)');
