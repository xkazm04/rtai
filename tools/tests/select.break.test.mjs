// Planning only: importing the runner is safe; never call runUnit or its CLI.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { buildPlan, parseArgs, selectMiss, UsageError } from './run_unit.mjs';

const ALPHA = ['tests/integration/test_alpha.gd', 'tests/unit/test_alpha.gd'];
const BETA = 'tests/unit/test_beta.gd';
const ALL = [...ALPHA, BETA, 'tests/unit/test_alphabet.gd', 'tests/unit/test_gamma.gd'].sort();
const index = {
  // Deliberately insert paths out of order, with a duplicate basename in two tiers.
  tests: {
    'tests/unit/test_gamma.gd': 'func test_gamma_only() -> void:\n\tpass\n',
    [BETA]: 'func test_beta_only() -> void:\n\tpass\n',
    [ALPHA[1]]: 'func test_shared() -> void:\n\tpass\n',
    'tests/unit/test_alphabet.gd': '',
    [ALPHA[0]]: 'func test_shared() -> void:\n\tpass\n',
  },
  classNames: () => [],
};
const plan = (argv, fixture = index, changes = null) =>
  buildPlan(parseArgs(argv), fixture, [], changes);

function assertSelection(result, files, misses = []) {
  assert.deepEqual(result.files, [...new Set(files)].sort());
  // Occurrence counts matter; no promise about the order of misses or notes.
  assert.deepEqual([...result.unmatched].sort(), [...misses].sort());
  assert.equal(result.notes.length, misses.length, 'one note per unmatched occurrence');
  for (const name of new Set(misses)) {
    const notes = result.notes.filter((n) => n.startsWith(`--select=${name} matches no test file`));
    assert.equal(notes.length, misses.filter((m) => m === name).length, name);
    for (const note of notes) assert.ok(note.includes('cannot pass'), note);
  }
}

for (const name of ['test_alpha', 'alpha', 'test_alpha.gd']) {
  test(`matching --select=${name} adds every exact basename and never marks it unmatched`, () => {
    assertSelection(plan([`--select=${name}`]), ALPHA);
  });
}

test('the promised x.gd shorthand matches test_x instead of throwing when it is the only name', () => {
  assertSelection(plan(['--select=alpha.gd']), ALPHA);
});

test('the promised x.gd shorthand is included and is not falsely unmatched beside a valid name', () => {
  assertSelection(plan(['--select=beta,alpha.gd']), [...ALPHA, BETA]);
});

for (const [name, files] of [
  ['test_alpha*', [...ALPHA, 'tests/unit/test_alphabet.gd']],
  ['*alpha*', [...ALPHA, 'tests/unit/test_alphabet.gd']],
  ['test_*a', [...ALPHA, BETA, 'tests/unit/test_gamma.gd']],
  ['**alpha**.gd', [...ALPHA, 'tests/unit/test_alphabet.gd']],
  ['*', ALL],
]) {
  test(`glob --select=${name} adds exactly its matches, sorted and never unmatched`, () => {
    assertSelection(plan([`--select=${name}`]), files);
  });
}

test('repeatable comma selections union overlapping aliases and globs without duplicate files', () => {
  assertSelection(plan(['--select=beta,alpha,test_alpha*', '--select=test_alpha.gd,beta,*']), ALL);
});

test('each unmatched occurrence gets its own note without dropping other matched files', () => {
  const misses = ['lost_alpha', 'lost_beta', 'lost_alpha', 'lost_alpha'];
  assertSelection(plan([
    '--select=lost_alpha,alpha,lost_beta,lost_alpha', '--select=beta,lost_alpha',
  ]), [...ALPHA, BETA], misses);
});

test('unmatched names before and after a matching glob cannot discard or broaden its files', () => {
  assertSelection(plan(['--select=absent_first,test_alpha*,absent_last']),
    [...ALPHA, 'tests/unit/test_alphabet.gd'], ['absent_first', 'absent_last']);
});

test('no matching selection throws UsageError naming every miss, including repeated arguments', () => {
  const misses = ['missing_one', 'missing_two.gd', 'missing_*', 'missing_one'];
  assert.throws(() => plan(['--select=missing_one,missing_two.gd', '--select=missing_*,missing_one']),
    (error) => error instanceof UsageError && misses.every((g) => error.message.includes(g)));
});

test('an empty index cannot return a plan even for the all-files glob and names every miss', () => {
  assert.throws(() => plan(['--select=*,alpha'], { tests: {}, classNames: () => [] }),
    (error) => error instanceof UsageError && ['*', 'alpha'].every((g) =>
      error.message.includes(`--select=${g} matches no test file`)));
});

test('matching mixed-case basenames and lowercase .gd suffixes never become unmatched', () => {
  // Exact case only: the documentation does not promise case-insensitive matching.
  const path = 'tests/unit/test_MiXeD.gd';
  const fixture = { tests: { [path]: '' }, classNames: () => [] };
  for (const name of ['test_MiXeD', 'MiXeD', 'test_MiXeD.gd', '*MiXeD*.gd']) {
    assertSelection(plan([`--select=${name}`], fixture), [path]);
  }
});

test('non-star regex metacharacters in names are literal and cannot select unrelated files', () => {
  const misses = ['test_alph.', 'test_alph[ab]', 'test_alph(a)', 'test_alpha|test_beta',
    'test_alpha$', '^test_alpha', 'test_alpha?', 'test_alpha+', 'test_alpha{1}', 'test_alpha\\'];
  for (const miss of misses) {
    assertSelection(plan([`--select=beta,${miss}`]), [BETA], [miss]);
  }
});

test('select wins over changed mapping and retains misses instead of falling back to the changed suite', () => {
  assertSelection(plan(['--changed', '--select=alpha,missing_changed'], index, ['docs/only.md']),
    ALPHA, ['missing_changed']);
});

test('an entirely unmatched select still throws when changed mapping would require no unit tests', () => {
  assert.throws(() => plan(['--changed=unused-ref', '--select=missing_changed'], index, ['docs/only.md']),
    (error) => error instanceof UsageError && error.message.includes('missing_changed'));
});

test('test-function filtering keeps unmatched select diagnostics when selected files define it', () => {
  assertSelection(plan(['--select=alpha,beta,missing_function', '--test=test_shared']),
    ALPHA, ['missing_function']);
});

test('test-function filtering cannot escape selected files to satisfy an unmatched select plus --test', () => {
  // test_gamma_only exists elsewhere: broadening the search would silently run the wrong file.
  assert.throws(() => plan(['--select=alpha,missing_function', '--test=test_gamma_only']),
    (error) => error instanceof UsageError && error.message.includes('test_gamma_only'));
});

test('test-function filtering with an entirely absent function cannot return a silent empty plan', () => {
  assert.throws(() => plan(['--select=alpha,missing_function', '--test=test_nowhere']),
    (error) => error instanceof UsageError && error.message.includes('test_nowhere'));
});

test('an unmatched select plus --test cannot pass planning when only a longer function name exists', () => {
  // Both selected alpha files define test_shared, but neither defines test_share.
  assert.throws(() => plan(['--select=alpha,missing_function', '--test=test_share']),
    (error) => error instanceof UsageError && error.message.includes('test_share'));
});

function suggestion(message, name) {
  const prefix = `--select=${name} matches no test file`;
  assert.ok(message.startsWith(prefix), 'the original name must start the diagnostic verbatim');
  if (message === prefix) return null;
  // Extract the current suggestion notation without asserting punctuation or surrounding prose.
  return /did you mean ([^?]+)\?/.exec(message.slice(prefix.length))?.[1] ?? null;
}

test('selectMiss suggests the unique nearest typo stem that actually exists in the supplied paths', () => {
  const paths = ['tests/unit/test_sim_clock.gd', 'tests/integration/test_inventory.gd'];
  for (const name of ['test_sim_clok', 'sim_clok', 'test_sim_clok.gd']) {
    assert.equal(suggestion(selectMiss(name, paths), name), 'test_sim_clock');
  }
});

test('selectMiss substring suggestions name existing stems rather than invented aliases or paths', () => {
  const paths = ['tests/unit/test_ghost_stride.gd', 'tests/unit/test_rivet_x15.gd'];
  const existing = paths.map((p) => p.split('/').at(-1).slice(0, -3));
  for (const name of ['ghost', 'rivet', 'stride', 'ghost_strid']) {
    const near = suggestion(selectMiss(name, paths), name);
    assert.ok(near === null || existing.includes(near), String(near));
  }
});

test('selectMiss never makes a substring guess for a glob whose literal fragment is in a stem', () => {
  const paths = ['tests/unit/test_very_long_distinctive_ghost_stride.gd'];
  for (const name of ['ghost*absent', '*ghost*absent*', 'very_long*absent.gd']) {
    assert.equal(selectMiss(name, paths), `--select=${name} matches no test file`);
  }
});

test('selectMiss never throws for regex syntax, empty-ish names or long input and only suggests existing stems', () => {
  const paths = ['tests/unit/test_alpha.gd', 'tests/integration/test_beta.gd'];
  const existing = ['test_alpha', 'test_beta'];
  const names = ['', ' ', '\t', '.gd', 'test_', '[', ']', '(', ')', '\\', '^$',
    'a+b?', '${x}', 'a|b', '{2}', 'a'.repeat(8192)];
  for (const name of names) {
    for (const all of [[], paths]) {
      const near = suggestion(selectMiss(name, all), name);
      assert.ok(near === null || (all.length > 0 && existing.includes(near)), String(near));
    }
  }
});
