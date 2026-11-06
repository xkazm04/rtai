// One planted violation per layers.mjs rule, plus the comment/string false positives that must
// stay quiet. Fixtures are throwaway project trees under os.tmpdir().
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { check, guarded, scan } from './layers.mjs';

const BASE = {
  'dev/arena/arena_rigs.gd': 'class_name ArenaRigs\nextends Node\n',
  'tests/support/helper.gd': 'class_name TestHelper\nextends RefCounted\n',
  'features/combat/hook.gd': 'class_name Hook\nextends Node\nfunc run() -> void:\n\tpass\n',
  'core/log/log.gd': 'class_name Log\nextends RefCounted\n',
  'boot/world.gd': 'class_name World\nextends Node\n',
};

function project(extra = {}) {
  const root = mkdtempSync(join(tmpdir(), 'gtai-layers-test-'));
  for (const [f, text] of Object.entries({ ...BASE, ...extra })) {
    mkdirSync(dirname(join(root, f)), { recursive: true });
    writeFileSync(join(root, f), text);
  }
  const done = () => {
    if (root.includes('gtai-layers-test-')) rmSync(root, { recursive: true, force: true });
  };
  return { root, done };
}

const run = (extra) => {
  const p = project(extra);
  try {
    return check(p.root);
  } finally {
    p.done();
  }
};

test('a clean tree passes', () => {
  const r = run({});
  assert.deepEqual(r.issues, []);
  assert.ok(r.ok);
});

test('dev and tests types named by shipped code are caught', () => {
  const r = run({
    'features/combat/view.gd': 'extends Node\nvar host: ArenaRigs = null\n',
    'core/log/bad.gd': 'extends Node\nfunc f() -> void:\n\tTestHelper.new()\n',
    'boot/bad.gd': 'extends Node\nfunc f(n: Node) -> bool:\n\treturn n is ArenaRigs\n',
  });
  assert.ok(!r.ok);
  assert.equal(r.issues.filter((i) => /names ArenaRigs/.test(i)).length, 2);
  assert.ok(r.issues.some((i) => i.includes('core/log/bad.gd:3') && i.includes('TestHelper')));
});

test('an unguarded res://dev path is caught, a debug-guarded one is not', () => {
  const bad = run({
    'core/log/loader.gd':
      'extends Node\nfunc f() -> void:\n\tvar s: Script = load("res://dev/x/tool.gd")\n',
  });
  assert.ok(bad.issues.some((i) => i.includes('core/log/loader.gd:3') && i.includes('unguarded')));
  const good = run({
    'core/log/loader.gd':
      'extends Node\nfunc f() -> void:\n\tif not OS.is_debug_build():\n\t\treturn\n\tvar s: Script = load("res://dev/x/tool.gd")\n',
  });
  assert.deepEqual(good.issues, []);
});

test('core naming a features class is caught; features naming core is fine', () => {
  const r = run({
    'core/log/up.gd': 'extends Node\nvar h: Hook = null\n',
    'features/combat/down.gd': 'extends Node\nvar l: Log = null\n',
  });
  assert.equal(r.issues.length, 1);
  assert.match(r.issues[0], /core\/log\/up\.gd:2: core names Hook/);
});

test('a new kebab-case directory or file fails LAY-02', () => {
  const r = run({ 'features/new-thing/a.gd': 'extends Node\n', 'data/tables/Bad.json': '{}' });
  assert.ok(r.issues.some((i) => i.includes('features/new-thing')));
  assert.ok(r.issues.some((i) => i.includes('data/tables/Bad.json')));
});

test('comments and string contents never trip the type match', () => {
  const r = run({
    'features/combat/prose.gd': [
      'extends Node',
      '## Wraps ArenaRigs and TestHelper for the dev arena.',
      '# ArenaRigs again',
      'var msg: String = "an ArenaRigs in a string, res://dev/x.gd in prose"',
      'var s2: String = """',
      'ArenaRigs in a triple string',
      '"""',
      'var ok: int = 1  # trailing ArenaRigs comment',
      '',
    ].join('\n'),
  });
  assert.deepEqual(r.issues, []);
});

test('scan blanks strings and comments but keeps lines aligned', () => {
  const s = scan('var a = "x#y"  # c\nvar b = \'q\'\n');
  assert.equal(s.code[0], 'var a = ""  ');
  assert.equal(s.code[1], "var b = ''");
  assert.deepEqual(s.strings.map((x) => x.text), ['x#y', 'q']);
});

test('guarded looks only inside the same function', () => {
  const code = ['func a():', '\tif OS.is_debug_build():', '\t\tpass', 'func b():', '\tload("x")'];
  assert.equal(guarded(code, 5), false);
  assert.equal(guarded(code, 3), true);
});
