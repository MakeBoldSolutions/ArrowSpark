#!/usr/bin/env node
// Synthetic load check for the showcase: one headless browser visit, no visitor data.
//
//   node scripts/synthetic-check.mjs <base-url>
//
// Loads the landing page and the story pages, then the Play page, and waits for the game
// inside the iframe to report engineState=started. Fails on any console error, page error or
// Content-Security-Policy violation.
//
// Hosted CI runners have no GPU, so the browser uses a software WebGL backend (ANGLE on
// SwiftShader) and logs the renderer it got. If the runner cannot create a WebGL2 context at
// all, the result is inconclusive rather than a failure: the game cannot start there for a
// reason that says nothing about the site.
//
// Exit codes: 0 pass, 1 fail, 3 inconclusive (no WebGL2 in this runner).
import { chromium } from 'playwright';

const EXIT_PASS = 0;
const EXIT_FAIL = 1;
const EXIT_INCONCLUSIVE = 3;
const ENGINE_TIMEOUT_MS = 120_000;

const base = (process.argv[2] ?? process.env.SYNTHETIC_BASE_URL ?? '').replace(/\/$/, '');
if (!base) {
  console.error('Usage: node scripts/synthetic-check.mjs <base-url>');
  process.exit(2);
}

const STORY_PAGES = ['/', '/devspark/', '/journey/', '/evidence/', '/story/'];
const problems = [];

const browser = await chromium.launch({
  args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'],
});

try {
  const context = await browser.newContext({ viewport: { width: 1280, height: 900 } });
  // Report CSP violations from every document, including the game iframe.
  await context.addInitScript(() => {
    document.addEventListener('securitypolicyviolation', (event) => {
      console.error(`CSP violation: ${event.violatedDirective} blocked ${event.blockedURI || 'inline'}`);
    });
  });
  const page = await context.newPage();
  page.on('console', (message) => {
    if (message.type() === 'error') problems.push(`console error on ${page.url()}: ${message.text()}`);
  });
  page.on('pageerror', (error) => problems.push(`page error on ${page.url()}: ${error.message}`));

  const renderer = await page.evaluate(() => {
    const gl = document.createElement('canvas').getContext('webgl2');
    if (!gl) return null;
    const debug = gl.getExtension('WEBGL_debug_renderer_info');
    return String(debug ? gl.getParameter(debug.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER));
  });
  console.log(`WebGL2 renderer: ${renderer ?? 'unavailable'}`);

  for (const path of STORY_PAGES) {
    const response = await page.goto(base + path, { waitUntil: 'load' });
    if (!response || !response.ok()) problems.push(`${path}: HTTP ${response?.status() ?? 'no response'}`);
  }

  if (renderer === null) {
    if (problems.length > 0) {
      report();
      process.exit(EXIT_FAIL);
    }
    console.log('::warning::Synthetic check inconclusive: this runner cannot create a WebGL2 context, so the game was not started. Story pages passed.');
    process.exit(EXIT_INCONCLUSIVE);
  }

  const response = await page.goto(`${base}/play/`, { waitUntil: 'load' });
  if (!response || !response.ok()) problems.push(`/play/: HTTP ${response?.status() ?? 'no response'}`);
  const frameHandle = await page.waitForSelector('iframe[data-game-frame]', { timeout: 15_000 });
  const frame = await frameHandle.contentFrame();
  if (!frame) {
    problems.push('/play/: game iframe has no document');
  } else {
    const state = await frame
      .waitForFunction(() => document.body?.dataset.engineState !== 'loading' ? document.body?.dataset.engineState : false, null, {
        timeout: ENGINE_TIMEOUT_MS,
      })
      .then((handle) => handle.jsonValue())
      .catch(() => 'timeout');
    console.log(`Game engine state: ${state}`);
    if (state !== 'started') problems.push(`/play/: game engine did not start (state: ${state})`);
  }
  // Let late console errors from the engine arrive.
  await page.waitForTimeout(3_000);
} finally {
  await browser.close();
}

function report() {
  for (const problem of problems) console.error(`  ${problem}`);
}

if (problems.length > 0) {
  console.error(`Synthetic check failed: ${problems.length} problem(s)`);
  report();
  process.exit(EXIT_FAIL);
}
console.log('Synthetic check passed.');
process.exit(EXIT_PASS);
