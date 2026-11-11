import assert from 'node:assert/strict';
import test from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { dirtyLine, EXIT, main, pinRev } from './film.mjs';

const snap = (calls) => (value, opts) => { calls.push([value, opts.native]); return { tree: ROOT, label: 'abcdef12', snapshot: true }; };

test('pinRev: --rev sets the tree to the snapshot and says so; --native passes through', async () => {
  const calls = [];
  const flags = { rev: 'HEAD~1', native: 'donor' };
  const r = pinRev(flags, snap(calls));
  assert.equal(flags.tree, ROOT);
  assert.deepEqual(calls, [['HEAD~1', 'donor']]);
  assert.match(r.line, /^film: --rev=HEAD~1 films snapshot abcdef12 at /);
});

test('pinRev refuses --rev with --tree, --native without --rev, a bad --native, and a resolve error', async () => {
  const never = () => assert.fail('resolved');
  assert.match((pinRev({ rev: 'HEAD', tree: '.' }, never)).error, /not both/);
  assert.match((pinRev({ native: 'donor' }, never)).error, /goes with --rev/);
  assert.match((pinRev({ rev: 'HEAD', native: 'mine' }, never)).error, /only donor/);
  const refused = pinRev({ rev: 'HEAD~3' }, () => ({ error: 'compare: native/ at HEAD~3 differs' }));
  assert.equal(refused.error, 'film: native/ at HEAD~3 differs');
  assert.deepEqual(pinRev({}, never), {});
});

test('dirtyLine: null when clean; names up to 3 paths and the --rev way out', () => {
  assert.equal(dirtyLine([]), null);
  const line = dirtyLine(['project/a.gd', 'project/b.gd', 'project/c.gd', 'project/d.gd']);
  assert.match(line, /^film: 4 uncommitted project\/ path\(s\) \(project\/a\.gd, project\/b\.gd, project\/c\.gd, \.\.\.\)/);
  assert.match(line, /--rev=HEAD/);
});

test('main --dry-run: a live tree with edits warns; --rev films the snapshot and does not ask the live tree', async () => {
  const live = [];
  assert.equal(await main(['arena', '--out=build/film/x', '--dry-run'], { out: (l) => live.push(l), err: (l) => live.push(l), dirty: () => ['project/x.gd'] }), EXIT.pass);
  assert.ok(live.some((l) => /1 uncommitted project\/ path\(s\) \(project\/x\.gd\)/.test(l)), live.join('\n'));
  const pinned = [];
  const calls = [];
  const code = await main(['arena', '--out=build/film/x', '--rev=HEAD', '--dry-run'], {
    out: (l) => pinned.push(l), err: (l) => pinned.push(l), resolveSide: snap(calls), dirty: () => assert.fail('asked the live tree'),
  });
  assert.equal(code, EXIT.pass, pinned.join('\n'));
  assert.deepEqual(calls, [['HEAD', undefined]]);
  assert.match(pinned[0], /films snapshot abcdef12/);
});
