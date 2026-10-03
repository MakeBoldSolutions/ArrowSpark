#!/usr/bin/env node
// Publication checks for the showcase. Fails (exit 1) on any finding.
//
//   node scripts/check-content.mjs                 source checks (every build)
//   node scripts/check-content.mjs --dist          also checks the built site in dist/
//   node scripts/check-content.mjs --fetch-links   also requests every external URL once
//                                                  (pre-publication and scheduled, never per push)
//
// Rules:
//   no-planning-links  nothing in src/, public/ text or dist/ names the temporary planning directory
//   evidence-links     every content source URL is a permanent evidence link
//   placeholders       no author placeholders in published content
//   sourced-numbers    every fact with a number has a source, and a command when derived
//   pre-play-words     no internal design vocabulary on any surface reached before play
//   theme-literals     no raw hex colors, px sizes or other fonts outside the theme and
//                      src/styles/arrowspark.css
import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parse as parseYaml } from 'yaml';
import { JSDOM } from 'jsdom';
import {
  PLANNING_DIR,
  PLACEHOLDER_MARKERS,
  evidenceUrlProblem,
  prePlayWordPattern,
} from '../src/lib/content-rules.mjs';

const webDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = resolve(webDir, '..');
const args = new Set(process.argv.slice(2));
const findings = [];

const rel = (path) => relative(repoRoot, path).split(sep).join('/');
const report = (rule, path, message) => findings.push(`${rule}: ${rel(path)}: ${message}`);

function walk(dir, filter = () => true) {
  if (!existsSync(dir)) return [];
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      if (entry === 'node_modules' || entry === 'game') continue;
      out.push(...walk(full, filter));
    } else if (filter(full)) {
      out.push(full);
    }
  }
  return out;
}

const TEXT_EXT = new Set(['.astro', '.ts', '.mjs', '.js', '.css', '.md', '.mdx', '.yaml', '.yml', '.json', '.html', '.txt', '.svg', '.xml']);
const isText = (path) => TEXT_EXT.has(extname(path));
const read = (path) => readFileSync(path, 'utf8');

// --- no-planning-links -------------------------------------------------------------------
const rulesFile = resolve(webDir, 'src/lib/content-rules.mjs');
for (const file of [...walk(join(webDir, 'src'), isText), ...walk(join(webDir, 'public'), isText)]) {
  if (file === rulesFile) continue; // defines the forbidden name itself
  if (read(file).includes(PLANNING_DIR)) report('no-planning-links', file, `contains "${PLANNING_DIR}"`);
}

// --- content collections -----------------------------------------------------------------
const contentDir = join(webDir, 'src', 'content');

function frontmatter(text) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text);
  return match ? parseYaml(match[1]) : {};
}

function checkSources(file, sources, where) {
  for (const source of sources ?? []) {
    const url = typeof source === 'string' ? source : source?.url;
    const problem = evidenceUrlProblem(url);
    if (problem) report('evidence-links', file, `${where}: ${url ?? '(none)'}: ${problem}`);
  }
}

const hasNumber = (value) => /\d/.test(String(value ?? ''));

for (const file of walk(join(contentDir, 'chapters'), (p) => /\.mdx?$/.test(p))) {
  const text = read(file);
  const data = frontmatter(text);
  if (data.status !== 'published') continue;
  checkSources(file, data.sources, 'sources');
  for (const marker of PLACEHOLDER_MARKERS) {
    if (text.includes(marker)) report('placeholders', file, `contains "${marker}"`);
  }
}

function loadYaml(name) {
  const file = join(contentDir, name);
  if (!existsSync(file)) return [file, undefined];
  const text = read(file);
  for (const marker of PLACEHOLDER_MARKERS) {
    if (text.includes(marker)) report('placeholders', file, `contains "${marker}"`);
  }
  return [file, parseYaml(text)];
}

{
  const [file, beats] = loadYaml('beats.yaml');
  for (const beat of beats ?? []) {
    if (!beat.sources?.length) report('evidence-links', file, `beat ${beat.n}: needs at least one source`);
    checkSources(file, beat.sources, `beat ${beat.n}`);
  }
}
{
  const [file, lessons] = loadYaml('lessons.yaml');
  for (const kind of ['worked', 'didnt']) {
    for (const [i, item] of (lessons?.[kind] ?? []).entries()) {
      checkSources(file, [item.source], `${kind}[${i}]`);
    }
  }
}
{
  const [file, evidence] = loadYaml('evidence.yaml');
  for (const [i, item] of (evidence?.automated ?? []).entries()) {
    checkSources(file, [item.source], `automated[${i}]`);
    if ((hasNumber(item.title) || hasNumber(item.detail)) && !item.command) {
      report('sourced-numbers', file, `automated[${i}] "${item.title}": a number needs the command that reproduces it`);
    }
  }
  checkSources(file, evidence?.human?.sources, 'human');
  for (const [i, item] of (evidence?.limitations ?? []).entries()) {
    checkSources(file, [item.source], `limitations[${i}]`);
  }
}
{
  const [file, facts] = loadYaml('facts.yaml');
  for (const [i, item] of (facts?.referenceKnot ?? []).entries()) {
    checkSources(file, [item.source], `referenceKnot[${i}]`);
    if (hasNumber(item.value) && !item.command) {
      report('sourced-numbers', file, `referenceKnot[${i}] "${item.label}": a derived number needs its command`);
    }
  }
  if (facts?.clock) {
    if (!/^[0-9a-f]{40}$/.test(facts.clock.cutoffCommit ?? '')) {
      report('sourced-numbers', file, 'clock.cutoffCommit must be a full commit SHA');
    }
    checkSources(file, [facts.clock.source], 'clock.source');
    for (const [i, item] of (facts.clock.items ?? []).entries()) {
      if (!item.command) report('sourced-numbers', file, `clock.items[${i}] "${item.label}": needs its command`);
    }
  }
}

// --- theme-literals ----------------------------------------------------------------------
const extensionFile = resolve(webDir, 'src/styles/arrowspark.css');
const HEX = /(?<![&\w])#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b/g;
const PX = /(?<![\w-])\d*\.?\d+px\b/g;
const FONT_FAMILY = /font-family\s*:\s*([^;}]+)/g;
for (const file of walk(join(webDir, 'src'), (p) => /\.(astro|css|ts|mjs)$/.test(p))) {
  if (file === extensionFile) continue;
  const text = read(file);
  for (const match of text.matchAll(HEX)) report('theme-literals', file, `raw color ${match[0]}`);
  for (const match of text.matchAll(PX)) report('theme-literals', file, `raw size ${match[0]}`);
  for (const match of text.matchAll(FONT_FAMILY)) {
    const value = match[1].trim();
    // Theme tokens everywhere; the theme's own two family names only inside @font-face.
    if (!/^(var\(--font-(display|body|mono)\)|inherit|"Be Vietnam Pro"|"Inter Tight")$/.test(value)) {
      report('theme-literals', file, `font-family must use a theme font token, got "${value}"`);
    }
  }
}

// --- pre-play-words ----------------------------------------------------------------------
const wordPattern = prePlayWordPattern();

function visibleText(html) {
  const { document } = new JSDOM(html).window;
  for (const node of document.querySelectorAll('script, style, template')) node.remove();
  const parts = [document.body?.textContent ?? '', document.title ?? ''];
  for (const node of document.querySelectorAll('[alt], [title], [aria-label]')) {
    parts.push(node.getAttribute('alt') ?? '', node.getAttribute('title') ?? '', node.getAttribute('aria-label') ?? '');
  }
  return parts.join('\n');
}

function scanWords(file, text, where = '') {
  for (const match of text.matchAll(wordPattern)) {
    report('pre-play-words', file, `${where}"${match[0]}"`);
  }
}

// The game's menus and loading screens, shown before the first puzzle.
for (const dir of ['scenes/menus', 'scenes/loading_screen']) {
  for (const file of walk(join(repoRoot, dir), (p) => p.endsWith('.tscn'))) {
    for (const match of read(file).matchAll(/^(?:text|tooltip_text|placeholder_text)\s*=\s*"((?:[^"\\]|\\.)*)"/gm)) {
      scanWords(file, match[1]);
    }
  }
}
for (const file of walk(join(repoRoot, 'scenes/menus'), (p) => p.endsWith('.gd'))) {
  for (const line of read(file).split('\n')) {
    const code = line.replace(/#.*$/, '');
    for (const match of code.matchAll(/"((?:[^"\\]|\\.)*)"/g)) scanWords(file, match[1]);
  }
}
// The game's loading shell.
{
  const shell = join(webDir, 'game-shell', 'shell.html');
  if (existsSync(shell)) scanWords(shell, visibleText(read(shell)));
}

// --- built output --------------------------------------------------------------------------
if (args.has('--dist')) {
  const distDir = join(webDir, 'dist');
  if (!existsSync(distDir)) {
    findings.push('dist: web/dist does not exist; run the build first');
  } else {
    for (const file of walk(distDir, isText)) {
      if (read(file).includes(PLANNING_DIR)) report('no-planning-links', file, `contains "${PLANNING_DIR}"`);
    }
    // Pages a first-time visitor reaches before playing. Header, footer and the desktop-only
    // notice are part of each.
    for (const page of ['index.html', 'play/index.html', 'journey/index.html']) {
      const file = join(distDir, page);
      if (!existsSync(file)) {
        findings.push(`pre-play-words: ${rel(file)} was not built`);
        continue;
      }
      scanWords(file, visibleText(read(file)));
    }
  }
}

// --- link liveness -------------------------------------------------------------------------
if (args.has('--fetch-links')) {
  const urls = new Set();
  const collect = (value) => {
    if (typeof value === 'string' && /^https?:\/\//.test(value)) urls.add(value);
    else if (Array.isArray(value)) value.forEach(collect);
    else if (value && typeof value === 'object') Object.values(value).forEach(collect);
  };
  for (const name of ['beats.yaml', 'lessons.yaml', 'evidence.yaml', 'facts.yaml', 'journey.yaml']) collect(loadYaml(name)[1]);
  for (const file of walk(join(contentDir, 'chapters'), (p) => /\.mdx?$/.test(p))) {
    const text = read(file);
    if (frontmatter(text).status !== 'published') continue;
    collect(frontmatter(text).sources);
    for (const match of text.matchAll(/\]\((https?:\/\/[^)\s]+)\)/g)) urls.add(match[1]);
  }
  for (const url of urls) {
    try {
      const response = await fetch(url, { method: 'GET', redirect: 'follow', signal: AbortSignal.timeout(20000) });
      if (!response.ok) findings.push(`link-liveness: ${url}: HTTP ${response.status}`);
    } catch (error) {
      findings.push(`link-liveness: ${url}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
  console.log(`link-liveness: checked ${urls.size} URL(s)`);
}

if (findings.length > 0) {
  console.error(`check-content: ${findings.length} finding(s)`);
  for (const finding of findings) console.error(`  ${finding}`);
  process.exit(1);
}
console.log('check-content: ok');
