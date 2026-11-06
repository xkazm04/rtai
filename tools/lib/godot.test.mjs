// node --test tools/lib/
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { join } from 'node:path';
import { candidates, describe, pinnedVersion, resolveGodot, runProcess, versionMatches } from './godot.mjs';

const ROOT = '/repo';
const TOML = '[godot]\nversion = "4.7.2-stable"\nwindows_url = "x"\n\n[gdtoolkit]\nversion = "4.5.0"\n';

/** A fake filesystem: files = {path: text}, dirs = {path: [names]}. */
const fakeFs = (files = {}, dirs = {}) => ({
  exists: (p) => p in files,
  read: (p) => { if (!(p in files)) throw new Error(`ENOENT ${p}`); return files[p]; },
  list: (d) => dirs[d] ?? [],
});
const toml = { [join(ROOT, 'versions.toml')]: TOML };
const good = (...bins) => (bin) => (bins.includes(bin) ? '4.7.2.stable.official.deadbeef' : null);

test('pinned version is read from [godot], not [gdtoolkit]', () => {
  assert.equal(pinnedVersion(fakeFs(toml), ROOT), '4.7.2-stable');
});

test('versionMatches maps 4.7.2-stable onto the printed 4.7.2.stable...', () => {
  assert.ok(versionMatches('4.7.2.stable.official.abc', '4.7.2-stable'));
  assert.ok(!versionMatches('4.6.1.stable.official.abc', '4.7.2-stable'));
  assert.ok(!versionMatches('4.7.2.rc1.official.abc', '4.7.2-stable'));
  assert.ok(!versionMatches(null, '4.7.2-stable'));
});

test('order: GODOT_BIN > POF_GODOT_BIN > tools/local.json > known path > PATH', () => {
  const local = join(ROOT, 'tools', 'local.json');
  const known = join(ROOT, '..', 'gtai-spike', 'tools', 'godot');
  const fs = fakeFs({ ...toml, [local]: '{"godot": "L"}' }, { [known]: ['Godot_v4.7.2-stable_win64_console.exe', 'notes.txt'] });
  const sources = (env) => candidates({ env, fs, root: ROOT }).map((c) => c.source);
  assert.deepEqual(sources({ GODOT_BIN: 'E', POF_GODOT_BIN: 'P' }),
    ['GODOT_BIN', 'POF_GODOT_BIN', 'tools/local.json', 'known path', 'PATH']);
  const pick = (env, ok) => resolveGodot({ env, fs, root: ROOT, probe: good(...ok) }).source;
  assert.equal(pick({ GODOT_BIN: 'E' }, ['E', 'P', 'L']), 'GODOT_BIN');
  assert.equal(pick({ POF_GODOT_BIN: 'P' }, ['P', 'L']), 'POF_GODOT_BIN');
  assert.equal(pick({}, ['L']), 'tools/local.json');
  const knownBin = join(known, 'Godot_v4.7.2-stable_win64_console.exe');
  assert.equal(resolveGodot({ env: {}, fs: fakeFs(toml, { [known]: ['Godot_v4.7.2-stable_win64_console.exe'] }),
    root: ROOT, probe: good(knownBin, 'godot') }).source, 'known path');
  assert.equal(resolveGodot({ env: {}, fs: fakeFs(toml), root: ROOT, probe: good('godot') }).source, 'PATH');
});

test('an unusable explicit GODOT_BIN fails with one actionable line (no silent fallthrough)', () => {
  const r = resolveGodot({ env: { GODOT_BIN: '/nope' }, fs: fakeFs(toml), root: ROOT, probe: good('godot') });
  assert.equal(r.ok, false);
  assert.match(r.message, /^Godot 4\.7\.2 not usable: GODOT_BIN=\/nope cannot be run; set GODOT_BIN or tools\/local\.json/);
  assert.ok(!r.message.includes('\n'));
});

test('a wrong-version explicit binary is refused, naming both versions', () => {
  const probe = () => '4.6.1.stable.official.abc';
  const r = resolveGodot({ env: { GODOT_BIN: 'old' }, fs: fakeFs(toml), root: ROOT, probe });
  assert.equal(r.ok, false);
  assert.match(r.message, /prints 4\.6\.1\.stable\.official\.abc, need 4\.7\.2-stable/);
});

test('nothing found: the one-line message', () => {
  const r = resolveGodot({ env: {}, fs: fakeFs(toml), root: ROOT, probe: () => null });
  assert.equal(r.message, 'Godot 4.7.2 not found: set GODOT_BIN or tools/local.json {"godot": "<path>"}');
});

const alive = (pid) => { try { process.kill(pid, 0); return true; } catch { return false; } };

test('timeout kills the whole tree (child + grandchild) and keeps the partial output', async () => {
  const hang = 'setInterval(()=>{},1000)';
  const parent = `const c=require('node:child_process').spawn(process.execPath,['-e','${hang}'],{stdio:'ignore'});`
    + `console.log('PARTIAL grandchild='+c.pid);${hang}`;
  const r = await runProcess(process.execPath, ['-e', parent], { timeoutMs: 1500 });
  assert.equal(r.timedOut, true);
  assert.notEqual(r.status, 0);
  assert.match(r.out, /PARTIAL grandchild=\d+/);
  assert.match(r.out, /killed the process tree/);
  assert.match(describe(r), /^TIMED OUT after/);
  const grandchild = Number(/grandchild=(\d+)/.exec(r.out)[1]);
  await new Promise((res) => setTimeout(res, 500));
  assert.equal(alive(grandchild), false, 'grandchild must be gone');
});

test('a normal run returns its status, output and duration', async () => {
  const r = await runProcess(process.execPath, ['-e', 'console.log("hi");console.error("err");process.exit(3)']);
  assert.equal(r.status, 3);
  assert.equal(r.timedOut, false);
  assert.match(r.out, /hi/);
  assert.match(r.out, /err/);
  assert.ok(r.durationMs >= 0);
});

test('a missing executable is status -1 with the error text, not a throw', async () => {
  const r = await runProcess('definitely-not-a-binary-xyz', []);
  assert.equal(r.status, -1);
  assert.match(r.out, /ENOENT/);
});

test('removeStale only deletes explicit files under <repo>/build or the temp dir', async () => {
  const { mkdtempSync, writeFileSync, existsSync, mkdirSync, rmdirSync } = await import('node:fs');
  const { tmpdir } = await import('node:os');
  const { removeStale, inSafeRoot } = await import('./godot.mjs');
  const dir = mkdtempSync(join(tmpdir(), 'lotA-stale-'));
  const file = join(dir, 'old.xml');
  writeFileSync(file, 'x');
  removeStale(file);
  assert.equal(existsSync(file), false);
  removeStale(join(dir, 'missing.xml')); // absent is fine
  // a directory in the safe zone is refused, never removed recursively
  const sub = join(dir, 'sub');
  mkdirSync(sub);
  assert.throws(() => removeStale(sub), /a directory/);
  assert.equal(existsSync(sub), true);
  // anything outside build/ and the temp dir is refused (project/, repo root, tools/)
  const repo = join(import.meta.dirname, '..', '..');
  for (const bad of ['project', 'project/.gutconfig.json', 'tools/lib/repo.mjs', 'build', 'package.json']) {
    assert.equal(inSafeRoot(join(repo, bad)), false, bad);
    assert.throws(() => removeStale(join(repo, bad)), /refuses/);
  }
  assert.equal(inSafeRoot(join(repo, 'build', 'test-results', 'a.xml')), true);
  rmdirSync(sub); // non-recursive cleanup of the test's own empty mkdtemp dirs
  rmdirSync(dir);
});
