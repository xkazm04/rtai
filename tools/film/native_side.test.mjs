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
