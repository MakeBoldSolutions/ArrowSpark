#!/usr/bin/env node
// Writes dist/staticwebapp.config.json with the production Content-Security-Policy.
//
// Every directive is explicit. Scripts and styles must come from files on this origin; the only
// inline code allowed is the Godot shell's single bootstrap script, allowed by its SHA-256 hash
// (computed here from the exported game, since the export writes its configuration into it).
// connect-src is this origin plus the origin of PUBLIC_REACTIONS_URL, read from the same build
// setting the site uses, so the two cannot drift. The build fails if any page carries an inline
// <script> or <style>, or a style attribute, that the policy would not allow.
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const webDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const distDir = join(webDir, 'dist');
const problems = [];

function htmlFiles(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) out.push(...htmlFiles(full));
    else if (entry.endsWith('.html')) out.push(full);
  }
  return out;
}

const rel = (path) => relative(webDir, path).split(sep).join('/');
const isGamePage = (path) => rel(path).startsWith('dist/game/');
const sha256 = (text) => `'sha256-${createHash('sha256').update(text, 'utf8').digest('base64')}'`;

const scriptHashes = new Set();
for (const file of htmlFiles(distDir)) {
  const html = readFileSync(file, 'utf8');
  const inlineScripts = [...html.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi)].map((m) => m[1] ?? '');
  const inlineStyles = [...html.matchAll(/<style[^>]*>[\s\S]*?<\/style>/gi)];
  const styleAttributes = [...html.matchAll(/<[^>]+\sstyle\s*=\s*["'][^"']*["']/gi)];
  if (inlineStyles.length > 0) problems.push(`${rel(file)}: ${inlineStyles.length} inline <style> block(s)`);
  if (styleAttributes.length > 0) problems.push(`${rel(file)}: ${styleAttributes.length} style attribute(s)`);
  if (isGamePage(file)) {
    if (inlineScripts.length !== 1) problems.push(`${rel(file)}: expected exactly one inline bootstrap script, found ${inlineScripts.length}`);
    for (const script of inlineScripts) scriptHashes.add(sha256(script));
  } else if (inlineScripts.length > 0) {
    problems.push(`${rel(file)}: ${inlineScripts.length} inline <script> block(s); site scripts must be bundled files`);
  }
}

let reactionsOrigin = '';
const reactionsUrl = process.env.PUBLIC_REACTIONS_URL;
if (reactionsUrl) {
  try {
    reactionsOrigin = new URL(reactionsUrl).origin;
  } catch {
    problems.push(`PUBLIC_REACTIONS_URL is not a valid URL: ${reactionsUrl}`);
  }
}

if (problems.length > 0) {
  console.error('build-csp: the production Content-Security-Policy would block this build:');
  for (const problem of problems) console.error(`  ${problem}`);
  process.exit(1);
}

const directives = [
  ["default-src", "'self'"],
  ['script-src', ["'self'", "'wasm-unsafe-eval'", ...scriptHashes].join(' ')],
  ['style-src', "'self'"],
  // blob: — the Godot runtime hands images it generates (for example the window icon) to the
  // browser as blob URLs; observed as a violation under this policy, so allowed here only.
  ['img-src', "'self' data: blob:"],
  ['font-src', "'self'"],
  ['worker-src', "'self'"],
  ['connect-src', ["'self'", reactionsOrigin].filter(Boolean).join(' ')],
  ['media-src', "'self'"],
  ['object-src', "'none'"],
  ['base-uri', "'self'"],
  ['form-action', "'self'"],
  ['frame-src', "'self'"],
  ['frame-ancestors', "'self'"],
];
const csp = directives.map(([name, value]) => `${name} ${value}`).join('; ');

const template = readFileSync(join(webDir, 'staticwebapp.config.json'), 'utf8');
const config = JSON.parse(template);
delete config.$comment;
config.globalHeaders['Content-Security-Policy'] = csp;
const outFile = join(distDir, 'staticwebapp.config.json');
writeFileSync(outFile, `${JSON.stringify(config, null, 2)}\n`);
console.log(`build-csp: wrote ${rel(outFile)}`);
console.log(`build-csp: ${csp}`);
if (!existsSync(join(distDir, 'game'))) console.log('build-csp: no exported game in this build (no shell hash needed)');
