import assert from 'node:assert/strict';
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { test } from 'node:test';
import { ROOT, readJson } from '../lib/repo.mjs';
import { BASELINE, clamped, ensureBaseline, git, inventory, TABLES, withLock } from './tune_state.mjs';

const catalog = 'tools/gauntlet/knobs.json';

function write(root, file, data) {
  const path = join(root, file);
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
}

function repository(t, branch = 'fixture') {
  const root = mkdtempSync(join(tmpdir(), 'gauntlet-tune-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  git(root, 'init', '-b', branch);
  git(root, 'config', 'user.name', 'Gauntlet test');
  git(root, 'config', 'user.email', 'gauntlet@example.invalid');
  git(root, 'config', 'core.autocrlf', 'false');
  git(root, 'config', 'core.hooksPath', '.test-no-hooks');
  const files = [catalog];
  for (const table of ['combat', 'enemies', 'gauntlet', 'weapons']) {
    files.push(TABLES + table + '.json', 'project/data/schemas/' + table + '.schema.json');
  }
  for (const file of files) {
    mkdirSync(dirname(join(root, file)), { recursive: true });
    cpSync(join(ROOT, file), join(root, file));
  }
  git(root, 'add', '--', ...files);
  git(root, 'commit', '-m', 'fixture tables');
  return root;
}

test('nightly and first-night bounds intersect in both directions, including integer rounding', () => {
  const k = { kind: 'float', min: 0, max: 1000 };
  assert.equal(clamped(k, 12, 12, 99), 15);
  assert.equal(clamped(k, 10, 10, 0), 8);
  assert.equal(clamped(k, 19, 10, 45), 20);
  assert.equal(clamped(k, 5.5, 10, 1), 5);
  assert.equal(clamped({ ...k, min: 5.4 }, 5.5, 10, 1), 5.4);
  assert.equal(clamped({ ...k, max: 11 }, 10, 10, 99), 11);
  assert.equal(clamped(k, 0, 0, 1), 0);
  k.kind = 'int';
  assert.equal(clamped(k, 12, 12, 11.9), 11);
  assert.equal(clamped(k, 12, 12, 12.1), 13);
  assert.equal(clamped(k, 12, 12, 1), 10);
  assert.equal(clamped(k, 11, 11, 99), 13);
  assert.equal(clamped(k, 2, 2, 9), 2);
});

test('first-night values and provenance survive reruns and additions', (t) => {
  const root = repository(t);
  const save = (items) => withLock(root, () => ensureBaseline(root, new Map(items)));
  const baseline = save([['a', { value: 10 }]]);
  const bytes = readFileSync(join(root, BASELINE));
  const again = save([['a', { value: 12 }]]);
  assert.deepEqual(again, baseline);
  assert.deepEqual(readFileSync(join(root, BASELINE)), bytes);
  const added = save([['a', { value: 12 }], ['b', { value: 4 }]]);
  assert.deepEqual(added, { ...baseline, values: { a: 10, b: 4 } });
});

test('shipped pointers resolve and missing, reordered or pending rows are reported and skipped', (t) => {
  const root = repository(t);
  const rows = readJson(join(root, catalog));
  assert.equal(inventory(root, assert.fail).entries.size, rows.length);
  const a = rows.find((k) => k.id === 'war_machine.hp');
  write(root, catalog, [{ ...a, pointer: '/archetypes/999/hp' },
    { ...a, id: 'new_robot.hp' }, { ...a, id: 'new_robot.damage', pending: true }]);
  const warnings = [];
  assert.equal(inventory(root, (s) => warnings.push(s)).entries.size, 0);
  assert.equal(warnings.length, 3);
  assert.match(warnings[0], /war_machine.hp unresolved.*999/);
  assert.match(warnings[1], /new_robot.hp unresolved/);
  assert.match(warnings[2], /pending/);
});
