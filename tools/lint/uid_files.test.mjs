import assert from 'node:assert/strict';
import test from 'node:test';
import { missingUids, uidCheck } from '../style/uid_files.mjs';

test('an own .gd without its .uid in the index is named; addons, non-.gd and paired files are not', () => {
  const issues = missingUids([
    'project/dev/sim/a.gd', 'project/core/b.gd', 'project/core/b.gd.uid', 'project/addons/gut/c.gd',
    'project/data/x.json', 'tools/canary.gd', 'project/core/b.gdshader',
  ]);
  assert.equal(issues.length, 1);
  assert.match(issues[0], /^project\/dev\/sim\/a\.gd: .*git add project\/dev\/sim\/a\.gd\.uid/);
});

test('uidCheck: red on a missing uid, green on none, not judged outside git', () => {
  assert.equal(uidCheck(() => ['project/a.gd']).ok, false);
  assert.equal(uidCheck(() => ['project/a.gd', 'project/a.gd.uid']).ok, true);
  const plain = uidCheck(() => null);
  assert.equal(plain.ok, true);
  assert.match(plain.warnings[0], /not judged/);
});

