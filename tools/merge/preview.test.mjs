import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { autoResolved, main, mergeTree, report } from './preview.mjs';

/** A throwaway repo that never reads this machine's git config or this repo's GIT_* variables. */
function repo() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-merge-preview-'));
  const cfg = join(dir, 'empty.gitconfig');
  writeFileSync(cfg, '');
  const env = { ...Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^GIT_/i.test(k))), GIT_CONFIG_GLOBAL: cfg, GIT_CONFIG_NOSYSTEM: '1' };
  const wt = join(dir, 'wt');
  mkdirSync(wt);
  const git = (args) => {
    const r = spawnSync('git', ['-C', wt, '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', ...args], { encoding: 'utf8', env });
    return { status: r.status, stdout: r.stdout ?? '', stderr: r.stderr ?? '' };
  };
  const sh = (...args) => { const r = git(args); assert.equal(r.status, 0, `git ${args.join(' ')}: ${r.stderr}`); return r.stdout.trim(); };
  const put = (f, text) => { mkdirSync(join(wt, f, '..'), { recursive: true }); writeFileSync(join(wt, f), text); sh('add', f); };
  return { wt, git, sh, put, done: () => rmSync(dir, { recursive: true, force: true }) };
}

/** main + lanes a, b, c: a and b both write JOURNAL.md and the baseline; b and c change one code line. */
function lanes(r) {
  r.sh('init', '-q', '-b', 'main');
  r.put('code.gd', 'one\ntwo\nthree\nfour\nfive\nsix\n');
  r.put('tools/debt/baseline.json', '{"x": 1}\n');
  r.sh('commit', '-q', '-m', 'base');
  const lane = (name, files) => {
    r.sh('checkout', '-q', '-b', name, 'main');
    for (const [f, t] of Object.entries(files)) r.put(f, t);
    r.sh('commit', '-q', '-m', name);
  };
  lane('a', { 'JOURNAL.md': 'a\n', 'tools/debt/baseline.json': '{"x": 2}\n' });
  lane('b', { 'JOURNAL.md': 'b\n', 'tools/debt/baseline.json': '{"x": 3}\n', 'code.gd': 'one\nTWO-b\nthree\nfour\nfive\nsix\n' });
  lane('c', { 'code.gd': 'one\nTWO-c\nthree\nfour\nfive\nsix\n' });
  r.sh('checkout', '-q', 'main');
}

test('autoResolved: the root JOURNAL and REPORT and the debt baseline only', () => {
  assert.deepEqual(['JOURNAL.md', 'REPORT.md', 'tools/debt/baseline.json', 'docs/JOURNAL.md', 'code.gd'].map(autoResolved), [true, true, true, false, false]);
});

test('the morning order: docs and baseline are morning\'s, a code clash stops it at the lane that brings it; refs untouched', () => {
  const r = repo();
  try {
    lanes(r);
    const refs = r.sh('for-each-ref');
    const said = [];
    const code = main(['--lanes=a,b,c'], { git: r.git, out: (l) => said.push(l), err: (l) => said.push(l) });
    assert.equal(code, 1, said.join('\n'));
    assert.deepEqual(said.slice(1, 4), [
      'preview: + a: clean',
      'preview: + b: morning resolves JOURNAL.md, tools/debt/baseline.json',
      'preview: + c: STOP on code.gd',
    ]);
    assert.ok(said.includes('preview: b x c conflict on code: code.gd'), said.join('\n'));
    assert.match(said.at(-1), /morning would STOP at c \(1 code file/);
    assert.equal(r.sh('for-each-ref'), refs, 'no ref was written');
    assert.equal(r.sh('status', '--porcelain'), '', 'the worktree and index are untouched');
    const clean = [];
    assert.equal(main(['--lanes=a,c'], { git: r.git, out: (l) => clean.push(l) }), 0, clean.join('\n'));
    assert.match(clean.at(-1), /merges all 2 lane\(s\) without a person/);
  } finally { r.done(); }
});

test('mergeTree lists each conflicted path once; unknown lanes and bad args exit 2 before any merge', () => {
  const r = repo();
  try {
    lanes(r);
    assert.deepEqual(mergeTree(r.git, 'b', 'c').files, ['code.gd']);
    assert.deepEqual(mergeTree(r.git, 'a', 'c').files, []);
    const errs = [];
    assert.equal(main(['--lanes=a,nope'], { git: r.git, out: () => {}, err: (l) => errs.push(l) }), 2);
    assert.match(errs[0], /no such commit: nope/);
    assert.equal(main(['--lanes=a', '--x=1'], { git: r.git, out: () => {}, err: () => {} }), 2);
    assert.equal(main([], { git: r.git, out: () => {}, err: () => {} }), 2);
  } finally { r.done(); }
});

test('report: clean lanes say clean, and no stop means exit 0', () => {
  const r = report('main', [{ lane: 'x', auto: [], code: [] }], []);
  assert.deepEqual(r.lines, ['preview: main + x (the morning order)', 'preview: + x: clean', 'preview: morning merges all 1 lane(s) without a person']);
  assert.equal(r.code, 0);
});
