import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { withRestore, writeOverride } from './override_cfg.mjs';

const tree = () => { const t = mkdtempSync(join(tmpdir(), 'ovr-')); mkdirSync(join(t, 'project')); return t; };

test('absent: written, then removed', () => {
  const t = tree(); const f = join(t, 'project', 'override.cfg');
  const restore = writeOverride(t, 'new');
  assert.equal(readFileSync(f, 'utf8'), 'new');
  restore();
  assert.equal(existsSync(f), false);
  rmSync(t, { recursive: true, force: true });
});

test('present: overwritten, then old content back', () => {
  const t = tree(); const f = join(t, 'project', 'override.cfg');
  writeFileSync(f, 'old');
  const restore = writeOverride(t, 'new');
  assert.equal(readFileSync(f, 'utf8'), 'new');
  restore();
  assert.equal(readFileSync(f, 'utf8'), 'old');
  rmSync(t, { recursive: true, force: true });
});

test('withRestore restores when the body throws', async () => {
  const t = tree(); const f = join(t, 'project', 'override.cfg');
  await assert.rejects(withRestore(async (hold) => { hold.restore = writeOverride(t, 'x'); throw new Error('boom'); }), /boom/);
  assert.equal(existsSync(f), false);
  rmSync(t, { recursive: true, force: true });
});
