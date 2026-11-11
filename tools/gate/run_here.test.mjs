// The gate works from the caller's game tree (n16 s6, kills-new REQUEST: `node ../n16-tools/tools/gate/run.mjs`
// wrote its results into the tools tree and gave the snapshot the tools tree's DLLs).
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { filmedRoot } from '../film/side.mjs';
import { main, nativeLine } from './run.mjs';

test('the gate root is the game tree the caller stands in, not the kit', (t) => {
  const lane = mkdtempSync(join(tmpdir(), 'gate-here-'));
  t.after(() => rmSync(lane, { recursive: true, force: true }));
  mkdirSync(join(lane, 'project', 'features'), { recursive: true });
  writeFileSync(join(lane, 'project', 'project.godot'), '');
  assert.equal(filmedRoot(join(lane, 'project', 'features')), lane);
});

test('a snapshot that would run another native/ build says so; the same native/ says nothing', () => {
  const sha = 'b9dba1da8ac6'.padEnd(40, '0');
  assert.equal(nativeLine('C:/lane', sha, () => false), null);
  const line = nativeLine('C:/lane', sha, (here, s) => here === 'C:/lane' && s === sha);
  assert.match(line, /^gate: WARNING native\/ at b9dba1da differs from C:\/lane's HEAD: the snapshot runs that tree's DLLs/);
});

test('an unknown rev is refused from the caller tree before anything runs', async () => {
  const lines = [];
  const code = await main(['--rev=no-such-rev-xyz'], { out: (l) => lines.push(l), err: (l) => lines.push(l), here: process.cwd() });
  assert.equal(code, 2);
  assert.match(lines.join('\n'), /git does not know no-such-rev-xyz/);
});
