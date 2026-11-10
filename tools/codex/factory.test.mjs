import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { LAWS, buildTask, equivalentInitialisers, freshId, gradeFrom, main, refusedByMeter, scoreOf, taskId } from './factory.mjs';
import { append, queue, read, rows, totals } from './ledger.mjs';
import { MAX_TUNED_CONSTS, pick, refusal } from './pick.mjs';
import { ROOT } from '../lib/repo.mjs';

const padded = (body, n = 40) => `${body}\n${Array(n).fill('').join('\n')}`;
const module = (name = 'Boss', extra = '') => padded(`class_name ${name}\nextends RefCounted\n\nfunc a() -> int:\n\treturn 1\n${extra}`);

test('a pure, untested module in features may go', () => {
  assert.equal(refusal('project/features/x/boss.gd', module(), []), null);
});

test('scope: only features and core', () => {
  assert.match(refusal('project/dev/x.gd', module(), []), /only features/);
  assert.match(refusal('project/boot/x.gd', module(), []), /only features/);
});

test('generators and tuned tables stay with Claude, by path and by what they contain', () => {
  assert.match(refusal('project/features/city/gen/kerb.gd', module(), []), /generator/);
  assert.match(refusal('project/features/x/spawn_table.gd', module(), []), /generator or table/);
  assert.match(refusal('project/features/x/a.gd', module('A', 'var r = ctx.rng.stream(&"x")'), []), /random/);
  const tuned = Array.from({ length: MAX_TUNED_CONSTS + 1 }, (_, i) => `const K${i}: float = ${i}.5`).join('\n');
  assert.match(refusal('project/features/x/a.gd', module('A', tuned), []), /tuned table/);
});

test('a module at the tuned limit still goes', () => {
  const ok = Array.from({ length: MAX_TUNED_CONSTS }, (_, i) => `const K${i}: float = ${i}.5`).join('\n');
  assert.equal(refusal('project/features/x/a.gd', module('A', ok), []), null);
});

test('impure code, wrong size and existing tests are refused with the reason', () => {
  assert.match(refusal('project/features/x/a.gd', module('A', 'func b():\n\tget_tree()'), []), /touches get_tree/);
  assert.match(refusal('project/features/x/a.gd', module('A', 'var x = load("res://y")'), []), /not pure/);
  assert.match(refusal('project/features/x/a.gd', 'class_name A\nextends RefCounted\nfunc a():\n\tpass\n', []), /too small/);
  assert.match(refusal('project/features/x/a.gd', module('A', Array(250).fill('#').join('\n')), []), /too big/);
  assert.match(refusal('project/features/x/a.gd', module('A').replace('RefCounted', 'Node'), []), /not a RefCounted/);
  assert.match(refusal('project/features/x/a.gd', module('Boss'), ['var b := Boss.new()']), /already tested/);
});

test('drawing code is not a pure rule: what it should do is how it looks', () => {
  assert.match(refusal('project/features/x/fight_nuke_art.gd', module('A'), []), /drawing code/);
  assert.match(refusal('project/features/x/a.gd', module('A', 'func b():\n\tdraw_line(a, b, c)'), []), /drawing code/);
  assert.match(refusal('project/features/x/a.gd', module('A', 'const INK: Color = Color(0.1, 0.1, 0.1)'), []), /drawing code/);
});

test('a word inside a comment is not a scene call, and a class named only in a comment is untested', () => {
  assert.equal(refusal('project/features/x/a.gd', module('A', '# get_tree is not used here'), []), null);
});

test('pick sorts so a run repeats and sets the reasons aside', () => {
  const { ok, no } = pick([{ path: 'project/features/z.gd', text: module('Z') }, { path: 'project/features/a.gd', text: module('A') }, { path: 'project/dev/b.gd', text: module('B') }], []);
  assert.deepEqual(ok.map((u) => u.stem), ['a', 'z']);
  assert.equal(no.length, 1);
});

test('the task carries the laws against pinning accident and the n11t- id', () => {
  const t = buildTask({ stem: 'boss_zone', cls: 'BossZone', path: 'project/features/bosses/boss_zone.gd' }, { repo: 'R', base: 'B', from: 'F', godot: 'G' });
  assert.equal(taskId('boss_zone'), 'n11t-fac-boss-zone');
  assert.equal(t.id, 'n11t-fac-boss-zone');
  assert.deepEqual(t.scope, ['project/tests/unit/test_boss_zone.gd']);
  assert.equal(t.access, 'write-verified');
  assert.ok(LAWS.some((l) => /accidental behaviour/.test(l)));
  assert.deepEqual(t.laws, LAWS);
  assert.match(t.goal, /Do not change BossZone/);
  assert.equal(t.repo, 'R');
  assert.equal(t.base, 'B');
});

test('a re-run of a discarded task gets a new id: the dispatcher refuses one with a run record', () => {
  assert.equal(freshId('oil_leak', () => false), 'n11t-fac-oil-leak');
  const taken = new Set(['n11t-fac-oil-leak', 'n11t-fac-oil-leak-r2']);
  assert.equal(freshId('oil_leak', (x) => taken.has(x)), 'n11t-fac-oil-leak-r3');
});

test('a machine grade can only reject or hand over; there is no accept', () => {
  const pass = gradeFrom({ unit: true, lint: true, score: 100, extra: [] });
  assert.equal(pass.pass, true);
  assert.match(pass.why, /Claude reviews/);
  assert.equal(gradeFrom({ unit: false, lint: true, score: 100, extra: [] }).pass, false);
  assert.equal(gradeFrom({ unit: true, lint: false, score: 100, extra: [] }).pass, false);
  assert.equal(gradeFrom({ unit: true, lint: true, score: null, extra: [] }).pass, false);
  assert.equal(gradeFrom({ unit: true, lint: true, score: 69.9, extra: [] }).pass, false);
  assert.equal(gradeFrom({ unit: true, lint: true, score: 70, extra: [] }).pass, true);
  assert.match(gradeFrom({ unit: true, lint: true, score: 90, extra: ['x.gd'] }).why, /outside scope: x.gd/);
});

test('scoreOf reads the final percentage and says nothing when there is none', () => {
  assert.equal(scoreOf('killed 10 of 12 (83.3 %)\nscore: 66.67 %\n'), 66.67);
  assert.equal(scoreOf('no numbers at all'), null);
});

test('refusedByMeter sees the dispatcher refusal', () => {
  assert.equal(refusedByMeter('Error: weekly usage is at 80 %: refused (limit 75)'), true);
  assert.equal(refusedByMeter('worktree add failed'), false);
});

function ledgerFile() {
  const dir = mkdtempSync(join(tmpdir(), 'gtai-factory-'));
  return { file: join(dir, 'l.jsonl'), done: () => rmSync(dir, { recursive: true, force: true }) };
}
const passed = (id) => ({ type: 'task', id, unit: id, machine: { pass: true, score: 90 }, codex_secs: 100 });

test('the queue holds what passed the machine and is not yet reviewed; failures never queue', () => {
  const { file, done } = ledgerFile();
  try {
    append(file, passed('a'));
    append(file, { type: 'task', id: 'b', machine: { pass: false, why: 'red' }, codex_secs: 50 });
    append(file, passed('c'));
    append(file, { type: 'review', id: 'c', verdict: 'accepted', changed_lines: 3, iteration: 7 });
    assert.deepEqual(queue(rows(read(file))).map((r) => r.id), ['a']);
  } finally { done(); }
});

test('totals: machine results are measured, a session split is labelled an estimate, no saving is invented', () => {
  const { file, done } = ledgerFile();
  try {
    append(file, passed('a'));
    append(file, passed('b'));
    append(file, { type: 'task', id: 'c', refused: true });
    append(file, { type: 'review', id: 'a', verdict: 'accepted-after-revision', changed_lines: 4, iteration: 7 });
    append(file, { type: 'review', id: 'b', verdict: 'rejected', changed_lines: 0, iteration: 7 });
    const t = totals(rows(read(file)), { iterations: [{ n: 7, costUsd: 4 }] });
    assert.equal(t.measured.tasks, 3);
    assert.equal(t.measured.refused_by_meter, 1);
    assert.equal(t.measured.machine_pass, 2);
    assert.equal(t.measured.codex_secs, 200);
    assert.equal(t.measured.accepted_after_revision, 1);
    assert.equal(t.measured.rejected, 1);
    assert.equal(t.measured.review_lines_changed, 4);
    assert.equal(t.measured.review_sessions_usd, 4, 'one session counted once');
    assert.equal(t.estimated.review_usd_per_task, 2);
    assert.match(t.estimated.note, /even split/);
    assert.match(t.unmeasured[0], /no control run/);
  } finally { done(); }
});

test('a run killed from outside still shows: started and never finished, and a later result clears it', () => {
  const { file, done } = ledgerFile();
  try {
    append(file, { type: 'started', id: 'a', at: 'x' });
    assert.deepEqual(totals(rows(read(file))).measured.started_and_never_finished, ['a']);
    assert.deepEqual(queue(rows(read(file))), [], 'a dead run is not reviewable');
    append(file, passed('a'));
    assert.deepEqual(totals(rows(read(file))).measured.started_and_never_finished, []);
  } finally { done(); }
});

test('a control run (Claude alone on the same module) is kept apart from tasks and named as measured in tokens, not dollars', () => {
  const { file, done } = ledgerFile();
  try {
    append(file, passed('n11t-fac-a'));
    append(file, { type: 'control', id: 'control-a', unit: 'a', claude_tokens: 50000, secs: 300 });
    const t = totals(rows(read(file)));
    assert.equal(t.measured.tasks, 1, 'a control is not a Codex task');
    assert.deepEqual(t.controls.map((c) => c.unit), ['a']);
    assert.match(t.unmeasured[0], /tokens and seconds/);
  } finally { done(); }
});

test('totals: a review session with no cost on record is null, not zero', () => {
  const r = [{ id: 'a', task: passed('a'), review: { verdict: 'accepted', iteration: 9 } }];
  assert.equal(totals(r, { iterations: [] }).measured.review_sessions_usd, null);
  assert.equal(totals(r, null).estimated.review_usd_per_task, null);
});

test('review: unknown task and double review are refused, an unknown verdict is usage', async () => {
  const { file, done } = ledgerFile();
  const out = [];
  const err = [];
  const opts = { out: (l) => out.push(l), err: (l) => err.push(l) };
  try {
    assert.equal(await main(['review', 'nope', '--verdict=accepted', `--ledger=${file}`], opts), 2);
    append(file, passed('a'));
    assert.equal(await main(['review', 'a', '--verdict=great', `--ledger=${file}`], opts), 2);
    assert.equal(await main(['review', 'a', '--verdict=accepted', '--changed=2', `--ledger=${file}`], opts), 0);
    assert.equal(await main(['review', 'a', '--verdict=rejected', `--ledger=${file}`], opts), 2);
    assert.equal(read(file).filter((e) => e.type === 'review').length, 1);
  } finally { done(); }
});

test('control: records measured numbers only, refuses a missing or made-up-looking one', async () => {
  const { file, done } = ledgerFile();
  const err = [];
  const opts = { out: () => {}, err: (l) => err.push(l) };
  const ok = ['--tokens=50249', '--secs=309', '--tests=12', '--killed=12', '--mutants=15', '--changed=0', `--ledger=${file}`];
  try {
    assert.equal(await main(['control', 'oil_leak', ...ok.filter((a) => !a.startsWith('--tokens'))], opts), 2);
    assert.match(err[0], /--tokens/);
    assert.equal(await main(['control', 'oil_leak', '--tokens=about 50k', ...ok.slice(1)], opts), 2);
    assert.equal(await main(['control', 'oil_leak', ...ok.slice(0, 3), '--killed=16', ...ok.slice(4)], opts), 2);
    assert.equal(read(file).length, 0, 'nothing written on a refusal');
    assert.equal(await main(['control', 'oil_leak', ...ok], opts), 0);
    const t = totals(rows(read(file)));
    assert.deepEqual(t.controls[0].mutation, { killed: 12, of: 15 });
    assert.equal(t.measured.tasks, 0);
  } finally { done(); }
});

test('a review done by a subagent records its measured tokens, and a module with a control is paired in tokens both sides', async () => {
  const { file, done } = ledgerFile();
  const err = [];
  const opts = { out: () => {}, err: (l) => err.push(l) };
  try {
    append(file, passed('a'));
    assert.equal(await main(['review', 'a', '--verdict=accepted', '--review-tokens=12000', `--ledger=${file}`], opts), 2, 'tokens without seconds');
    assert.equal(await main(['review', 'a', '--verdict=accepted', '--review-tokens=about12k', '--review-secs=90', `--ledger=${file}`], opts), 2);
    assert.match(err.at(-1), /never estimate/);
    assert.equal(read(file).filter((e) => e.type === 'review').length, 0, 'a refused review writes nothing');
    assert.equal(totals(rows(read(file))).paired.length, 0);
    assert.equal(await main(['review', 'a', '--verdict=accepted-after-revision', '--changed=3', '--review-tokens=12000', '--review-secs=90', `--ledger=${file}`], opts), 0);
    assert.deepEqual(totals(rows(read(file))).paired, [], 'no control yet: nothing to pair');
    append(file, { type: 'control', id: 'control-a', unit: 'a', claude_tokens: 50000, secs: 300, review_changed: 0 });
    const [p] = totals(rows(read(file))).paired;
    assert.equal(p.claude_alone_tokens, 50000);
    assert.equal(p.review_tokens, 12000);
    assert.equal(p.claude_tokens_saved, 38000);
    assert.equal(p.codex_secs, 100);
    assert.equal(p.review_changed_lines, 3);
  } finally { done(); }
});

test('a review without measured tokens is never paired, even beside a control', () => {
  const r = [{ id: 'a', task: passed('a'), review: { verdict: 'accepted', iteration: 4 } },
    { id: 'control-a', control: { unit: 'a', claude_tokens: 50000, secs: 300 } }];
  assert.deepEqual(totals(r).paired, []);
});

test('survivors on member initialisers that _init reassigns are named as likely equivalent, nothing else', () => {
  const src = readFileSync(join(ROOT, 'project/features/city/city_spawn_plan.gd'), 'utf8');
  const out = readFileSync(join(ROOT, 'tools/codex/fixtures/city_spawn_plan.mutate.txt'), 'utf8');
  assert.deepEqual(equivalentInitialisers(out, src), [10, 11]);
  const gd = 'var a: int = 0\nvar b: int = 0\nvar c: int = 0\n\n\nfunc _init() -> void:\n\ta = 3\n\tif c > 0:\n\t\tb = 2\n';
  const surv = (n) => `  x.gd:${n} literal  0 -> 1  survived\n`;
  assert.deepEqual(equivalentInitialisers(surv(1) + surv(2) + surv(3), gd), [1], 'b is reassigned only under an if');
  assert.deepEqual(equivalentInitialisers(surv(1).replace('survived', 'killed'), gd), []);
  assert.deepEqual(equivalentInitialisers(surv(1), 'var a: int = 0\n'), [], 'no _init, nothing is equivalent');
});
