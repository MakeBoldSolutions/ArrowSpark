#!/usr/bin/env node
// Exports the Godot "Web" preset into a build-unique folder under web/public/game/ and
// copies the shell stylesheet next to it. Usage (from the repository root or web/):
//   node web/scripts/export-game.mjs --godot <path-to-godot-4.4> [--build <id>]
// The build id defaults to the current commit's short SHA. It is printed on success so CI
// can pass it to the site build as PUBLIC_GAME_BUILD.
import { execFileSync } from 'node:child_process';
import { copyFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const webDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = resolve(webDir, '..');

function argValue(name) {
  const index = process.argv.indexOf(name);
  return index !== -1 ? process.argv[index + 1] : undefined;
}

const godot = argValue('--godot') ?? process.env.GODOT_BIN;
if (!godot) {
  console.error('Missing --godot <path-to-godot-4.4> (or GODOT_BIN).');
  process.exit(2);
}

const build =
  argValue('--build') ??
  execFileSync('git', ['rev-parse', '--short', 'HEAD'], { cwd: repoRoot, encoding: 'utf8' }).trim();
if (!/^[0-9a-z]{4,40}$/.test(build)) {
  console.error(`Build id must be lowercase letters and digits, got "${build}".`);
  process.exit(2);
}

const outDir = join(webDir, 'public', 'game', build);
mkdirSync(outDir, { recursive: true });
execFileSync(godot, ['--headless', '--path', repoRoot, '--export-release', 'Web', join(outDir, 'index.html')], {
  stdio: 'inherit',
});
if (!existsSync(join(outDir, 'index.wasm'))) {
  console.error(`Export did not produce ${join(outDir, 'index.wasm')}.`);
  process.exit(1);
}
copyFileSync(join(webDir, 'game-shell', 'shell.css'), join(outDir, 'shell.css'));
console.log(build);
