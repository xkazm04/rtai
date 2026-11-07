#!/usr/bin/env node
// The BC7 arm (LEDGER E10, perf's L4): sets every `features/{characters,city,vehicles}/art/**/*.png.import`
// under <project dir> to VRAM-compressed BC7 (`compress/mode=2`, `compress/high_quality=true`). Run it on a
// scratch copy (a detached worktree), never on the checkout you commit from; then `--import` that copy once.
// Prints how many files changed. A handheld build step would run the same on its export copy.
// Usage: node tools/handheld/bc7_arm.mjs <project dir>
import { readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const ART_DIRS = ['features/characters/art', 'features/city/art', 'features/vehicles/art'];

/** The import file's text with BC7 set (unchanged if it is not a texture import). */
export function toBc7(text) {
  if (!/^importer="texture"/m.test(text)) return text;
  return text.replace(/^compress\/mode=\d+$/m, 'compress/mode=2')
    .replace(/^compress\/high_quality=(true|false)$/m, 'compress/high_quality=true');
}

function* walk(dir) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) yield* walk(p);
    else if (name.endsWith('.png.import')) yield p;
  }
}

function main() {
  const root = process.argv[2];
  if (!root) { console.error('usage: node tools/handheld/bc7_arm.mjs <project dir>'); process.exit(2); }
  let changed = 0;
  let seen = 0;
  for (const d of ART_DIRS) {
    for (const f of walk(join(resolve(root), d))) {
      seen += 1;
      const before = readFileSync(f, 'utf8');
      const after = toBc7(before);
      if (after !== before) { writeFileSync(f, after); changed += 1; }
    }
  }
  console.log(`bc7_arm: ${changed} of ${seen} texture imports set to BC7 under ${resolve(root)}`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
