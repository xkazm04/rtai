import assert from 'node:assert/strict';
import test from 'node:test';
import { causeUnseen, errorLines, otherLines, verdictCode } from './check.mjs';

const compile = 'SCRIPT ERROR: Compile Error: Failed to compile depended scripts.';
const load = 'ERROR: Failed to load script "res://features/example.gd" with error "Compilation failed".';
const frames = [
  '\tat: GDScript::reload (res://features/example.gd:0)',
  '    at: load (modules/gdscript/gdscript_resource_format.cpp:46)',
];
const autoloads = new Set(['Log', 'LaunchArgs']);
const noise = 'SCRIPT ERROR: Compile Error: Identifier not found: Log';
const parse = 'SCRIPT ERROR: Parse Error: Expected end of statement after expression.';

test('causeUnseen requires non-empty lines and accepts exact cascades with optional periods', () => {
  assert.equal(causeUnseen([]), false);
  for (const line of [compile, compile.slice(0, -1), load, load.slice(0, -1)]) {
    assert.equal(causeUnseen([line]), true, line);
    assert.equal(causeUnseen([frames[0], line, frames[1]]), true, line);
  }
});

const visibleCauses = [
  ['a Parse Error', parse],
  ['a different Compile Error', 'SCRIPT ERROR: Compile Error: Cannot resolve class "Missing".'],
  ['an ERROR quoting compile cascade words', `ERROR: Dependency diagnostic: ${compile}`],
  ['an ERROR quoting a load cascade', `ERROR: Dependency diagnostic: ${load}`],
  ['compile cascade text plus more', `${compile} The dependency is missing.`],
  ['load cascade text plus more', `${load} The dependency is missing.`],
  ['compile cascade text prefixed by context', `res://features/example.gd:7: ${compile}`],
  ['a load failure with another reason', load.replace('Compilation failed', 'File not found')],
  ['an unindented at line', 'at: GDScript::reload (res://features/example.gd:0)'],
  ['a blank line', ''],
  ['a whitespace-only line', '\t   '],
];

for (const [label, line] of visibleCauses) {
  test(`causeUnseen rejects ${label} anywhere among otherwise valid cascades`, () => {
    for (const position of [0, 2, 4]) {
      const lines = [compile, frames[0], load, frames[1]];
      lines.splice(position, 0, line);
      assert.equal(causeUnseen(lines), false, `position ${position}: ${line}`);
    }
  });
}

// The final words deliberately resemble a second trailer. They are extra diagnostic text,
// not part of the script path, which has already closed before the first `with error`.
const extendedLoad = `${load} Dependency diagnostic: "missing class" with error "Compilation failed".`;

test('causeUnseen rejects a load cascade plus more even when the suffix repeats the trailer', () => {
  assert.equal(causeUnseen([compile, frames[0], extendedLoad, frames[1]]), false);
});

for (const [label, eol] of [['LF', '\n'], ['CRLF', '\r\n']]) {
  test(`otherLines keeps only the LAST n eligible lines in original order with ${label}`, () => {
    const eligible = [
      'Godot Engine v4.7.2.stable - https://godotengine.org',
      'WARNING: Dependency scan started.',
      parse,
      `ERROR: Diagnostic quotes ${compile}`,
      'WARNING: Dependency scan ended.',
    ];
    const out = [
      eligible[0], '', compile, frames[0], eligible[1], load, frames[1],
      eligible[2], '\t ', compile.slice(0, -1), eligible[3],
      load.slice(0, -1), '  ', eligible[4], '',
    ].join(eol);
    for (const n of [1, 2, 3, 5, 6, 20]) {
      const got = otherLines(out, n);
      assert.ok(got.length <= n, `line budget ${n}`);
      assert.deepEqual(got, eligible.slice(-n), `line budget ${n}`);
    }
    assert.deepEqual(otherLines(out), eligible, 'default budget is six');
  });

  test(`otherLines returns no lines for a zero budget with ${label}`, () => {
    const out = ['Godot Engine v4.7.2.stable', compile, frames[0], 'WARNING: Last diagnostic.'].join(eol);
    assert.deepEqual(otherLines(out, 0), []);
  });

  test(`otherLines returns no cascade, frame or blank lines when nothing else exists with ${label}`, () => {
    for (const out of ['', ['', '  ', '\t', compile, ...frames, load, ''].join(eol)]) {
      assert.deepEqual(otherLines(out, 4), []);
    }
  });

  test(`errorLines plus causeUnseen excuses only same-run autoload cascades with ${label}`, () => {
    const cascade = [compile, frames[0], load, frames[1]].join(eol);
    const bare = errorLines(cascade, autoloads);
    assert.ok(bare.length > 0, 'unexplained cascade must remain');
    assert.equal(causeUnseen(bare), true);
    for (const out of [
      [noise, frames[0], cascade].join(eol),
      [cascade, noise, frames[1]].join(eol),
    ]) {
      const excused = errorLines(out, autoloads);
      assert.deepEqual(excused, []);
      assert.equal(causeUnseen(excused), false);
    }
    const nextRun = errorLines(cascade, autoloads);
    assert.equal(causeUnseen(nextRun), true, 'prior calls must not excuse a later run');
    const unregistered = errorLines([noise, frames[0], cascade].join(eol), new Set());
    assert.ok(unregistered.includes(noise));
    assert.equal(causeUnseen(unregistered), false, 'the unregistered identifier is a visible cause');
  });

  test(`errorLines preserves real causes beside autoload noise and cannot call them unseen with ${label}`, () => {
    for (const [, cause] of visibleCauses.slice(0, 6)) {
      const out = [noise, frames[0], compile, cause, frames[1], load].join(eol);
      const bad = errorLines(out, autoloads);
      assert.ok(bad.includes(cause), cause);
      assert.equal(causeUnseen(bad), false, cause);
    }
    const nonAutoload = 'SCRIPT ERROR: Compile Error: Identifier not found: Logger';
    const bad = errorLines([nonAutoload, frames[0], compile, load].join(eol), autoloads);
    assert.ok(bad.includes(nonAutoload), 'an autoload-name prefix is not that autoload');
    assert.equal(causeUnseen(bad), false);
  });
}

test('otherLines retains extra error text even when it repeats a load-cascade trailer', () => {
  assert.deepEqual(otherLines([compile, extendedLoad, ...frames, load].join('\r\n'), 2), [extendedLoad]);
});

test('verdictCode enforces usage then real failure then unverifiable then success for every small combination', () => {
  const states = [
    { ok: true },
    { ok: false },
    { ok: false, note: 'unverifiable' },
    { ok: true, note: 'unverifiable' },
    { ok: false, note: 'usage' },
    { ok: true, note: 'usage' },
    { ok: false, note: 'timedout' },
  ];
  const sequences = [[]];
  let level = [[]];
  for (let length = 1; length <= 3; length += 1) {
    level = level.flatMap((prefix) => states.map((state) => [...prefix, state]));
    sequences.push(...level);
  }
  for (const results of sequences) {
    const notes = new Set(results.map((result) => result.note));
    const failures = results.filter((result) => !result.ok && result.note !== 'unverifiable');
    const expected = notes.has('usage') ? 2 : failures.length ? 1 : notes.has('unverifiable') ? 3 : 0;
    assert.equal(verdictCode(results), expected, JSON.stringify(results));
  }
});
