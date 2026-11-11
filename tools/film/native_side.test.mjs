// A commit side's snapshot runs THIS tree's DLLs: when native/ differs at that commit, the side is not
// that commit's sim and compare refuses it (n15 t-4 film), unless --native=donor says the change is view-only.
import assert from 'node:assert/strict';
import test from 'node:test';
import { nativeRefusal, parseArgv, resolveSide } from './compare.mjs';

const SHA = 'd720e22da0000000000000000000000000000000';
const fakeEnsure = () => ({ path: '/nonexistent/snap' });

test('a commit whose native/ differs is refused, naming the commit and the way out', () => {
  const msg = nativeRefusal('d720e22da', SHA, true, undefined);
  assert.match(msg, /native\/ at d720e22da \(d720e22d\) differs/);
  assert.match(msg, /worktree at d720e22da that has its own DLLs/);
  assert.match(msg, /--native=donor/);
});

test('the same native/, or --native=donor, films the commit', () => {
  assert.equal(nativeRefusal('x', SHA, false, undefined), null);
  assert.equal(nativeRefusal('x', SHA, true, 'donor'), null);
});

test('resolveSide asks before making a snapshot, and never asks for a worktree side', () => {
  let asked = 0;
  let made = 0;
  const ensure = () => { made += 1; return fakeEnsure(); };
  const differs = () => { asked += 1; return true; };
  const rev = () => SHA; // no real git: CI and WSL see this worktree differently
  const r = resolveSide('HEAD', { ensure, differs, rev });
  assert.match(r.error, /differs from this tree's HEAD/);
  assert.equal(made, 0, 'no 1.7 GB snapshot for a side that is refused');
  const here = resolveSide(new URL('../..', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'), { ensure, differs, rev });
  assert.equal(here.snapshot, false);
  assert.equal(asked, 1, 'a worktree side runs its own DLLs: no question');
});

test('--native takes only donor', () => {
  const base = ['city', '--a=HEAD~1', '--b=HEAD', '--at=10', '--out=o'];
  assert.equal(parseArgv([...base, '--native=donor']).flags.native, 'donor');
  assert.match(parseArgv([...base, '--native=yes']).error, /--native takes only donor/);
});

test('a lane running this kit by path films ITS tree: native/ is compared against the tree it stands in', async () => {
  const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import('node:fs');
  const { join } = await import('node:path');
  const { tmpdir } = await import('node:os');
  const { filmedRoot } = await import('./side.mjs');
  const { ROOT } = await import('../lib/repo.mjs');
  const lane = mkdtempSync(join(tmpdir(), 'gtai-lane-'));
  mkdirSync(join(lane, 'project'));
  writeFileSync(join(lane, 'project', 'project.godot'), '');
  assert.equal(filmedRoot(lane), lane);
  assert.equal(filmedRoot(tmpdir()), ROOT, 'outside a game tree: the kit\'s own');
  let root = null;
  const prev = process.cwd();
  process.chdir(lane);
  try {
    resolveSide('HEAD', { differs: (r) => { root = r; return true; }, rev: () => SHA, ensure: fakeEnsure });
  } finally { process.chdir(prev); rmSync(lane, { recursive: true, force: true }); }
  assert.equal(root, lane, 'the native guard asked about the lane\'s HEAD, not the kit\'s');
});
