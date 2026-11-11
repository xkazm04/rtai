// n15 item 4: a debt baseline conflict no longer stops the morning merge. A real throwaway repo (its
// own empty global config, no inherited GIT_ variables) where a lane and the integration branch both
// moved tools/debt/baseline.json and JOURNAL.md.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { canonicalJson } from '../lib/canonical_json.mjs';
import { mergeBaselines, resolveConflict } from '../debt/merge_baseline.mjs';
import { BASELINE, STEP_RUNNERS, git } from './morning.mjs';

const base = (devLoc, unused, accepted = {}) => ({
  metrics: {
    dev_loc: { ...(accepted.dev ? { accepted: accepted.dev } : {}), files: devLoc, total: Object.values(devLoc).reduce((a, b) => a + b, 0) },
    unused_class_names: { files: unused, total: Object.keys(unused).length },
  },
  schema: 'gtai.debt-baseline/1',
});

function repo() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-morning-baseline-'));
  const cfg = join(dir, 'empty.gitconfig');
  writeFileSync(cfg, '');
  const env = { ...Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^GIT_/i.test(k))), GIT_CONFIG_GLOBAL: cfg, GIT_CONFIG_NOSYSTEM: '1' };
  const wt = join(dir, 'wt');
  mkdirSync(wt);
  const sh = (...args) => {
    const r = spawnSync('git', ['-C', wt, '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', ...args], { encoding: 'utf8', env });
    assert.equal(r.status, 0, `git ${args.join(' ')}: ${r.stderr}`);
    return r.stdout.trim();
  };
  const put = (f, text) => { mkdirSync(join(wt, f, '..'), { recursive: true }); writeFileSync(join(wt, f), text); sh('add', f); };
  const g = (args) => git(wt, args, (cmd, a, o) => spawnSync(cmd, [a[0], a[1], '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', ...a.slice(2)], { ...o, env }));
  return { dir, wt, sh, put, g, done: () => rmSync(dir, { recursive: true, force: true }) };
}

test('a baseline conflict merges to the looser side per file, keeps both reasons, and the lane goes on', () => {
  const r = repo();
  try {
    r.sh('init', '-q', '-b', 'integ');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 10 }, { 'project/x.gd': 1 })));
    r.put('JOURNAL.md', 'base\n');
    r.sh('commit', '-q', '-m', 'base');
    r.sh('checkout', '-q', '-b', 'lane-x');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 12 }, { 'project/x.gd': 1 }, { dev: ['lane-x grew a'] })));
    r.put('JOURNAL.md', 'lane-x journal\n');
    r.sh('commit', '-q', '-m', 'lane-x work');
    r.sh('checkout', '-q', 'integ');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 10, 'project/dev/b': 5 }, {}, { dev: ['integ added b'] })));
    r.put('JOURNAL.md', 'integ journal\n');
    r.sh('commit', '-q', '-m', 'integ work');
    const seen = [];
    const res = STEP_RUNNERS.merge({ git: r.g, cwd: r.wt, lanes: ['lane-x'], date: '2026-11-11', out: (l) => seen.push(l), done: [], mark: () => {} });
    assert.equal(res.ok, true, JSON.stringify(res.advice));
    assert.ok(seen.some((l) => /baseline\.json conflicted merging lane-x: took the looser/.test(l)), seen.join('\n'));
    const merged = JSON.parse(readFileSync(join(r.wt, BASELINE), 'utf8'));
    assert.deepEqual(merged.metrics.dev_loc.files, { 'project/dev/a': 12, 'project/dev/b': 5 });
    assert.equal(merged.metrics.dev_loc.total, 17);
    assert.deepEqual(merged.metrics.dev_loc.accepted, ['integ added b', 'lane-x grew a']);
    assert.deepEqual(merged.metrics.unused_class_names.files, { 'project/x.gd': 1 });
    assert.equal(r.sh('status', '--porcelain'), '', 'merge committed, tree clean');
    assert.equal(existsSync(join(r.wt, '.git', 'MERGE_HEAD')), false);
    assert.equal(readFileSync(join(r.wt, 'docs/day/2026-11-11/lane-x/JOURNAL.md'), 'utf8'), 'lane-x journal\n');
  } finally { r.done(); }
});

test('mergeBaselines never goes looser than the looser side, and refuses two schemas', () => {
  const a = base({ f: 3, g: 9 }, { u: 1 });
  const b = base({ f: 7 }, { v: 1 });
  const m = mergeBaselines(a, b);
  assert.deepEqual(m.metrics.dev_loc.files, { f: 7, g: 9 });
  assert.equal(m.metrics.dev_loc.total, 16);
  assert.equal(m.metrics.unused_class_names.total, 2);
  assert.deepEqual(mergeBaselines(a, a), a, 'one side merged with itself is itself');
  assert.throws(() => mergeBaselines(a, { ...b, schema: 'other/1' }), /schemas differ/);
});

test('beside a code conflict the stop names merge_baseline.mjs, and it stages the looser baseline by hand (real git)', () => {
  const r = repo();
  try {
    r.sh('init', '-q', '-b', 'integ');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 10 }, {})));
    r.put('project/a.gd', 'var a: int = 0\n');
    r.sh('commit', '-q', '-m', 'base');
    r.sh('checkout', '-q', '-b', 'lane-x');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 12 }, {})));
    r.put('project/a.gd', 'var a: int = 1\n');
    r.sh('commit', '-q', '-m', 'lane-x');
    r.sh('checkout', '-q', 'integ');
    r.put(BASELINE, canonicalJson(base({ 'project/dev/a': 10, 'project/dev/b': 5 }, {})));
    r.put('project/a.gd', 'var a: int = 2\n');
    r.sh('commit', '-q', '-m', 'integ');
    const res = STEP_RUNNERS.merge({ git: r.g, cwd: r.wt, lanes: ['lane-x'], date: '2026-11-11', out: () => {}, done: [], mark: () => {} });
    assert.equal(res.ok, false);
    assert.ok(res.advice.some((l) => /baseline\.json: node tools\/debt\/merge_baseline\.mjs/.test(l)), res.advice.join('\n'));
    const gitEnv = (cmd, args, o) => spawnSync(cmd, args, { ...o, env: { ...o.env, ...Object.fromEntries(Object.entries(process.env).filter(([k]) => !/^GIT_/i.test(k))) } });
    assert.match(resolveConflict(r.wt, gitEnv), /looser of both sides per metric and file, staged \(2 metrics\)/);
    assert.deepEqual(JSON.parse(readFileSync(join(r.wt, BASELINE), 'utf8')).metrics.dev_loc.files, { 'project/dev/a': 12, 'project/dev/b': 5 });
    assert.match(r.sh('status', '--porcelain', BASELINE), /^M {2}tools\/debt\/baseline\.json$/, 'staged, no longer unmerged');
    assert.match(r.sh('status', '--porcelain', 'project/a.gd'), /^UU /, 'the code conflict is left to the person');
    assert.throws(() => resolveConflict(r.wt, gitEnv), /not in conflict here/);
  } finally { r.done(); }
});
