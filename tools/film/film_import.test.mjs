import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { filmOne } from './film.mjs';

const HASH = '0123456789abcdef0123456789abcdef';

function staleTree(t) {
  const tree = mkdtempSync(join(tmpdir(), 'film-import-'));
  t.after(() => rmSync(tree, { recursive: true, force: true }));
  const write = (rel, body) => { const f = join(tree, 'project', rel); mkdirSync(dirname(f), { recursive: true }); writeFileSync(f, body); };
  write('art/a.png', 'new bytes');
  write('art/a.png.import', `source_file="res://art/a.png"
dest_files=["res://.godot/imported/a.png-${HASH}.ctex"]
`);
  write(`.godot/imported/a.png-${HASH}.ctex`, 'x');
  write(`.godot/imported/a.png-${HASH}.md5`, `source_md5="${createHash('md5').update('old bytes').digest('hex')}"
`);
  return tree;
}

test('an --import that changes nothing leaves the film unverifiable: it would draw the old pixels', async (t) => {
  const tree = staleTree(t);
  const dir = join(tree, 'out');
  const calls = [];
  const runner = async (args) => { calls.push(args); return { status: 0, out: '', timedOut: false }; };
  const r = await filmOne({ shot: null, opts: { dir, tree, timeoutMs: 1000, label: 't' } }, { runner });
  assert.equal(r.outcome, 'unverifiable');
  assert.match(r.reasons[0], /still do not match/);
  assert.deepEqual(calls, [['--import']], 'no film is launched on stale pixels');
  assert.deepEqual(readdirSync(dir), []);
});
