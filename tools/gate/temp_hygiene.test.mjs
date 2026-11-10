// Guard: a Node tool test that makes a temp folder must also remove one.
// 280 test folders had piled up in %TEMP% since 11-07 from seven test files that never removed
// theirs (e1e478c1, and the check_baked/morning_run/reels follow-ups). This is a static check,
// not a proof of cleanup: it refuses a file that has no removal call at all.
// Run: node --test tools/gate/temp_hygiene.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const TOOLS = fileURLToPath(new URL('..', import.meta.url));
const MAKES = /\bmkdtemp(Sync)?\s*\(/;
const REMOVES = /\b(rmSync|rmdirSync|rm|rmdir)\s*\(|removeSnapshot\s*\(/;

/** Every *.test.mjs under `root`, skipping fixtures and node_modules. */
export function testFiles(root) {
  const out = [];
  for (const e of readdirSync(root, { withFileTypes: true })) {
    const p = join(root, e.name);
    if (e.isDirectory()) { if (e.name !== 'node_modules' && e.name !== 'fixtures') out.push(...testFiles(p)); }
    else if (e.name.endsWith('.test.mjs')) out.push(p);
  }
  return out;
}

/** True when `text` makes a temp folder and never calls anything that removes one. */
export function leaks(text) {
  return MAKES.test(text) && !REMOVES.test(text);
}

test('leaks: a mkdtemp with no removal call is a leak; with one, or with no mkdtemp, it is not', () => {
  assert.equal(leaks("const d = mkdtempSync(join(tmpdir(), 'x-'));"), true);
  assert.equal(leaks("const d = fs.mkdtempSync(p); after(() => fs.rmSync(d, { recursive: true }));"), false);
  assert.equal(leaks("const d = mkdtempSync(p); try {} finally { rmdirSync(d); }"), false);
  assert.equal(leaks("writeFileSync('a', 'b');"), false);
});

test('no tools/**/*.test.mjs makes a temp folder without removing one', () => {
  const bad = testFiles(TOOLS).filter((f) => leaks(readFileSync(f, 'utf8')))
    .map((f) => relative(TOOLS, f).split('\\').join('/'));
  assert.deepEqual(bad, [], `these tests make a temp folder and never remove it: ${bad.join(', ')}. `
    + 'Push each mkdtemp result to a list and rm it in after(), as tools/dev/run.test.mjs does.');
});
