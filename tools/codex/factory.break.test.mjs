import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { gradeFrom, main } from './factory.mjs';
import { append, queue, read, rows, totals } from './ledger.mjs';
import { MAX_TUNED_CONSTS, pick } from './pick.mjs';

const path = 'project/features/rules/fixture.gd';
// All GDScript is inert text. No factory run/dispatch command is used.
const source = (extra = '', cls = 'Fixture') => `class_name ${cls}\nextends RefCounted\n${extra}
func value() -> int:
\treturn 1
${'\n'.repeat(32)}`;
const eligible = (text, tests = []) => pick([{ path, text }], tests).ok;
const task = (id) => ({ type: 'task', id, machine: { pass: true, score: 100 }, codex_secs: 10 });
const review = (id, iteration) => ({ type: 'review', id, verdict: 'accepted', iteration, changed_lines: 2 });

function ledger(t) {
  const dir = mkdtempSync(join(tmpdir(), 'factory-break-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return join(dir, 'events.jsonl');
}

for (const [kind, body] of [
  ['generator', 'var rng: RandomNumberGenerator = RandomNumberGenerator.new()'],
  ['stream generator', 'func sample(ctx) -> void:\n\tctx.rng.stream(&"fixture")'],
  ['drawing', 'func render() -> void:\n\tdraw_line(Vector2.ZERO, Vector2.ONE, Color.WHITE)'],
  ['scene', 'func scene() -> void:\n\tget_tree()'],
  ['disk', 'func disk() -> void:\n\tFileAccess.open("fixture", FileAccess.READ)'],
]) {
  test(`never picks ${kind} code even when an eligible rule appears beside it`, () => {
    const r = pick([{ path, text: source(body) },
      { path: 'project/core/rules/safe.gd', text: source('', 'Safe') }], []);
    assert.deepEqual(r.ok.map((u) => u.cls), ['Safe']);
    assert.equal(r.no.length, 1);
    assert.ok(r.no[0].why);
  });
}

// The hash is in a string, so the following semicolon and call are executable GDScript.
for (const [kind, statement] of [
  ['generator', 'RandomNumberGenerator.new()'],
  ['drawing', 'draw_line(Vector2.ZERO, Vector2.ONE, Color.WHITE)'],
  ['scene', 'get_tree()'],
]) {
  test(`never picks ${kind} code hidden after a hash inside a string`, () => {
    assert.equal(eligible(source(`func sample() -> void:\n\tvar marker: String = "#"; ${statement}`)).length, 0);
  });
}

test('never picks scene or disk access through singleton methods', () => {
  for (const body of ['func clock() -> int:\n\treturn Engine.get_frames_drawn()',
    'func environment() -> String:\n\treturn OS.get_environment("HOME")',
    'func asset() -> Image:\n\treturn Image.load_from_file("fixture.png")']) {
    assert.equal(eligible(source(body)).length, 0, body);
  }
});

test('never picks drawing calls with legal whitespace before the opening parenthesis', () => {
  assert.equal(eligible(source('func render() -> void:\n\tdraw_line (a, b, c)')).length, 0);
});

test('never picks tuned tables when numeric constants use inferred types', () => {
  const constants = Array.from({ length: MAX_TUNED_CONSTS + 1 }, (_, i) => `const TUNE_${i} := ${i + 1}`).join('\n');
  assert.equal(eligible(source(constants)).length, 0);
});

test('pure rules remain eligible when comments contain scene, drawing and generator vocabulary', () => {
  assert.equal(eligible(source('# get_tree() draw_line() RandomNumberGenerator\n# const TABLE = 42')).length, 1);
});

for (const literal of ['"draw_line(a, b, c)"', '"get_tree()"', '\'escaped \\\' draw_circle()\'']) {
  test(`pure rules remain eligible when ${literal} is a string rather than a call`, () => {
    assert.equal(eligible(source(`const DESCRIPTION: String = ${literal}`)).length, 1, literal);
  });
}

test('already tested classes cannot be hidden by decoy class declarations inside string constants', () => {
  const text = source('const DOC: String = """\nclass_name Decoy\n"""', 'Actual');
  assert.equal(eligible(text, ['var instance: Actual = Actual.new()']).length, 0,
    'the actual class already has a test; a docstring must not hide it');
});

test('hostile regex metacharacters in class names cannot crash the picker', () => {
  // Invalid identifiers are hostile input, not valid classes requiring dispatch.
  for (const cls of ['[', '.*', '(?<x>', '$', '\\', 'A[evil]']) {
    assert.doesNotThrow(() => eligible(source('', cls), ['unrelated test text']));
  }
});

test('already tested means the exact class identifier, not a substring of a different class', () => {
  assert.equal(eligible(source('', 'Rule'), ['var x: RuleBook = RuleBook.new()']).length, 1);
  assert.equal(eligible(source('', 'Rule'), ['var x: Rule = Rule.new()']).length, 0);
});

test('a mutation score can only queue for review and never records an acceptance', () => {
  for (const score of [0, 69, 70, 99.9, 100]) {
    const machine = gradeFrom({ unit: true, lint: true, score, extra: [] });
    const r = rows([{ ...task('candidate'), machine }]);
    assert.equal(totals(r).measured.accepted, 0);
    assert.equal(totals(r).measured.accepted_after_revision, 0);
    assert.equal(r[0].review, null);
    assert.equal(queue(r).length, machine.pass ? 1 : 0);
  }
});

test('a perfect score cannot override red tests, red lint or out of scope changes', () => {
  for (const override of [{ unit: false }, { lint: false }, { extra: ['project/features/rules/fixture.gd'] }]) {
    assert.equal(gradeFrom({ unit: true, lint: true, score: 100, extra: [], ...override }).pass, false);
  }
});

test('missing costs stay null even when a review has no iteration to look up', () => {
  const t = totals(rows([task('a'), review('a', null)]));
  assert.equal(t.measured.review_sessions_usd, null);
  assert.equal(t.estimated.review_usd_per_task, null);
});

test('one missing session cost cannot be hidden by another measured or zero cost session', () => {
  for (const costUsd of [0, 5]) {
    const t = totals(rows([task('a'), task('b'), review('a', 1), review('b', 2)]),
      { iterations: [{ n: 1, costUsd }, { n: 2 }] });
    assert.equal(t.measured.review_sessions_usd, null);
    assert.equal(t.estimated.review_usd_per_task, null);
  }
});

test('unattributed reviews cannot dilute the estimated share of a measured session', () => {
  const t = totals(rows([task('a'), task('b'), review('a', 1), review('b', null)]),
    { iterations: [{ n: 1, costUsd: 8 }] });
  assert.equal(t.estimated.review_usd_per_task, null,
    'the aggregate per-task cost is unknown when one review has no session attribution');
});

test('measured session totals count a shared session once and estimates never become savings', () => {
  const t = totals(rows([task('a'), task('b'), review('a', 7), review('b', 7)]),
    { iterations: [{ n: 7, costUsd: 6 }, { n: 8, costUsd: 999 }] });
  assert.equal(t.measured.review_sessions_usd, 6);
  assert.equal(t.estimated.review_usd_per_task, 3);
  assert.ok(t.estimated.note);
  assert.ok(t.unmeasured.length);
  assert.ok(!Object.keys(t.measured).some((k) => /saving|per_task/.test(k)));
});

test('malformed ledger JSON cannot silently erase events or fabricate measured totals', async (t) => {
  const file = ledger(t);
  append(file, task('a'));
  writeFileSync(file, '{not json}\n', { flag: 'a' });
  append(file, review('a', 7));
  const before = readFileSync(file, 'utf8');
  const output = [];
  // Refusal or a thrown parse error are both safe; a successful summary is not.
  let code;
  try { code = await main(['ledger', `--ledger=${file}`], { out: (s) => output.push(s), err: () => {} }); }
  catch (e) { assert.ok(e instanceof SyntaxError); }
  assert.notEqual(code, 0);
  assert.deepEqual(output, []);
  assert.equal(readFileSync(file, 'utf8'), before);
});

test('unknown id reviews never append a verdict or change an existing task', async (t) => {
  const file = ledger(t);
  append(file, task('__proto__'));
  append(file, task('constructor'));
  const before = readFileSync(file, 'utf8');
  for (const id of ['missing', 'toString', 'hasOwnProperty', 'a b', '--hostile']) {
    assert.equal(await main(['review', id, '--verdict=accepted', `--ledger=${file}`],
      { out: () => {}, err: () => {} }), 2);
    assert.equal(readFileSync(file, 'utf8'), before);
  }
  assert.equal(read(file).length, 2);
});

test('append-only ledger preserves task and review events with hostile JSON strings', (t) => {
  const file = ledger(t);
  const events = [task('a\n{"type":"review"}'),
    { ...review('a\n{"type":"review"}', 3), notes: '"\\\n\r\t' }];
  for (const event of events) append(file, event);
  assert.deepEqual(read(file), events);
  assert.equal(rows(read(file)).length, 1);
});
