import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { lines, main, newClashes, siblings } from './clash.mjs';
import { clashCheck } from '../gate/precommit.mjs';

/** Main + three worktrees (n9-a, n9-b, x9-c) in a throwaway repo with an empty git config and no
 *  GIT_* variables. n9-b changes code.gd line 2 and JOURNAL.md; x9-c (another night) changes line 4. */
function fleet() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-merge-clash-'));
  const cfg = join(dir, 'empty.gitconfig');
  writeFileSync(cfg, '');
  const env = { ...Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^GIT_/i.test(k))), GIT_CONFIG_GLOBAL: cfg, GIT_CONFIG_NOSYSTEM: '1' };
  const gitAt = (cwd) => (args) => {
    const r = spawnSync('git', ['-C', cwd, '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', ...args], { encoding: 'utf8', env });
    return { status: r.status, stdout: r.stdout ?? '', stderr: r.stderr ?? '' };
  };
  const main = join(dir, 'main');
  mkdirSync(main);
  const ok = (git, ...args) => { const r = git(args); assert.equal(r.status, 0, `git ${args.join(' ')}: ${r.stderr}`); return r.stdout.trim(); };
  const put = (cwd, f, text) => { writeFileSync(join(cwd, f), text); ok(gitAt(cwd), 'add', f); };
  const g = gitAt(main);
  ok(g, 'init', '-q', '-b', 'main');
  put(main, 'code.gd', 'one\ntwo\nthree\nfour\nfive\nsix\nseven\neight\n');
  put(main, 'JOURNAL.md', 'base\n');
  ok(g, 'commit', '-q', '-m', 'base');
  const wt = {};
  for (const name of ['n9-a', 'n9-b', 'x9-c']) {
    wt[name] = join(dir, name);
    ok(g, 'worktree', 'add', '-q', '-b', name, wt[name], 'main');
  }
  put(wt['n9-b'], 'code.gd', 'one\nTWO-b\nthree\nfour\nfive\nsix\nseven\neight\n');
  put(wt['n9-b'], 'JOURNAL.md', 'b\n');
  ok(gitAt(wt['n9-b']), 'commit', '-q', '-m', 'b');
  put(wt['x9-c'], 'code.gd', 'one\ntwo\nthree\nFOUR-c\nfive\nsix\nseven\neight\n');
  ok(gitAt(wt['x9-c']), 'commit', '-q', '-m', 'c');
  return { wt, gitAt, put, ok, env, done: () => rmSync(dir, { recursive: true, force: true }) };
}

test('siblings: worktree branches with the same prefix; the env names or switches them off', () => {
  const f = fleet();
  try {
    const git = f.gitAt(f.wt['n9-a']);
    assert.deepEqual(siblings(git, 'n9-a', {}), ['n9-b']);
    assert.deepEqual(siblings(git, 'n9-a', { GTAI_MERGE_LANES: 'x9-c,n9-a' }), ['x9-c']);
    assert.deepEqual(siblings(git, 'n9-a', { GTAI_MERGE_LANES: 'off' }), []);
    assert.deepEqual(siblings(git, 'main', {}), []);
  } finally { f.done(); }
});

test('a staged line on the sibling\'s line is a NEW clash; HEAD, index and the tree stay as they were', () => {
  const f = fleet();
  try {
    const a = f.wt['n9-a'];
    const git = f.gitAt(a);
    const head = f.ok(git, 'rev-parse', 'HEAD');
    f.put(a, 'code.gd', 'one\nTWO-a\nthree\nfour\nfive\nsix\nseven\neight\n');
    const index = f.ok(git, 'write-tree');
    const r = newClashes(git, {});
    assert.deepEqual(r.clashes, [{ lane: 'n9-b', files: ['code.gd'] }]);
    assert.match(lines(r)[0], /^merge-clash: WARNING this commit makes code\.gd conflict with n9-b/);
    assert.equal(f.ok(git, 'rev-parse', 'HEAD'), head);
    assert.equal(f.ok(git, 'write-tree'), index);
    assert.equal(f.ok(git, 'status', '--porcelain'), 'M  code.gd');
  } finally { f.done(); }
});

test('a staged line elsewhere, or only a JOURNAL clash (morning resolves it), is no new clash', () => {
  const f = fleet();
  try {
    const a = f.wt['n9-a'];
    f.put(a, 'code.gd', 'one\ntwo\nthree\nfour\nfive\nsix\nseven\nEIGHT-a\n');
    f.put(a, 'JOURNAL.md', 'a\n');
    const r = newClashes(f.gitAt(a), {});
    assert.deepEqual(r.clashes, []);
    assert.deepEqual(lines(r), ['merge-clash: no new code conflict with n9-b']);
  } finally { f.done(); }
});

test('a clash HEAD already has is counted as known, not reported again', () => {
  const f = fleet();
  try {
    const a = f.wt['n9-a'];
    const git = f.gitAt(a);
    f.put(a, 'code.gd', 'one\nTWO-a\nthree\nfour\nfive\nsix\nseven\neight\n');
    f.ok(git, 'commit', '-q', '-m', 'a clashes');
    f.put(a, 'code.gd', 'one\nTWO-a\nthree\nfour\nfive\nsix\nseven\nEIGHT-a\n');
    const r = newClashes(git, {});
    assert.deepEqual(r.clashes, []);
    assert.equal(r.known, 1);
    assert.match(lines(r)[0], /\(1 known, unchanged\)$/);
  } finally { f.done(); }
});

test('the pre-commit hook runs it through its own git runner, and a fake git cannot make it throw', () => {
  const f = fleet();
  try {
    const a = f.wt['n9-a'];
    f.put(a, 'code.gd', 'one\nTWO-a\nthree\nfour\nfive\nsix\nseven\neight\n');
    const git = (cmd, args, o) => spawnSync(cmd, ['-c', 'user.name=t', '-c', 'user.email=t@example.invalid', ...args], { ...o, env: f.env });
    assert.match(clashCheck(a, git, {})[0], /WARNING .*code\.gd conflict with n9-b/);
    assert.deepEqual(clashCheck(a, () => ({ status: 0, stdout: 'a.gd\0' }), {}), []);
    assert.deepEqual(clashCheck(a, () => null, {}), []);
  } finally { f.done(); }
});

test('--repo checks another worktree on a COPY of its index: their index file is not rewritten', () => {
  const f = fleet();
  try {
    const a = f.wt['n9-a'];
    f.put(a, 'code.gd', 'one\nTWO-a\nthree\nfour\nfive\nsix\nseven\neight\n');
    const indexPath = f.ok(f.gitAt(a), 'rev-parse', '--path-format=absolute', '--git-path', 'index');
    const before = readFileSync(indexPath);
    const out = [];
    assert.equal(main([`--repo=${a}`], { err: (l) => out.push(l), env: f.env }), 0);
    assert.match(out[0], /WARNING .*code\.gd conflict with n9-b/);
    assert.ok(readFileSync(indexPath).equals(before), 'their index bytes changed');
    assert.equal(main(['--nope'], { err: () => {}, env: f.env }), 2);
  } finally { f.done(); }
});
