import assert from 'node:assert/strict';
import test from 'node:test';
import { errorLines } from './check.mjs';

const autoloads = new Set(['Log', 'LaunchArgs']);
const lines = (...l) => l.join('\n');

test('autoload noise and its cascade through dependent scripts are not failures', () => {
  const out = lines(
    'SCRIPT ERROR: Compile Error: Identifier not found: Log',
    '   at: GDScript::reload (res://core/log/log_user.gd:3)',
    'SCRIPT ERROR: Compile Error: Failed to compile depended scripts.',
    '   at: GDScript::reload (res://features/x.gd:0)',
    'ERROR: Failed to load script "res://features/x.gd" with error "Compilation failed".',
    '   at: load (modules/gdscript/gdscript_resource_format.cpp:46)',
  );
  assert.deepEqual(errorLines(out, autoloads), []);
});

test('a real parse error in a dependency is still reported, with the cascade around it', () => {
  const out = lines(
    'SCRIPT ERROR: Compile Error: Identifier not found: Log',
    '   at: GDScript::reload (res://a.gd:3)',
    'SCRIPT ERROR: Parse Error: The argument 1 of the constructor "float()" requires the subtype "float"',
    '   at: GDScript::reload (res://b.gd:5)',
    'SCRIPT ERROR: Compile Error: Failed to compile depended scripts.',
    '   at: GDScript::reload (res://c.gd:0)',
  );
  const got = errorLines(out, autoloads);
  assert.ok(got.some((l) => l.includes('float()')));
  assert.ok(got.some((l) => l.includes('depended scripts')));
});

test('an identifier that is not an autoload is a real error', () => {
  assert.ok(errorLines('SCRIPT ERROR: Compile Error: Identifier not found: Fightr', autoloads).length);
});

test('a cascade is excused only by autoload noise in the same run; a bare parse error always fails', () => {
  const cascade = lines(
    'SCRIPT ERROR: Compile Error: Failed to compile depended scripts.',
    '   at: GDScript::reload (res://features/x.gd:0)',
    'ERROR: Failed to load script "res://features/x.gd" with error "Compilation failed".',
  );
  // Nothing explains it: the cause was not observed, so it must not read as ok.
  assert.ok(errorLines(cascade, autoloads).some((l) => l.includes('depended scripts')));
  const excused = lines('SCRIPT ERROR: Compile Error: Identifier not found: Log', cascade);
  assert.deepEqual(errorLines(excused, autoloads), []);
  assert.ok(errorLines('SCRIPT ERROR: Parse Error: Expected end of statement', autoloads).length);
});

test('a resource whose script file is missing keeps every line (real Godot 4.7.2 output, 05:11)', () => {
  const out = lines(
    "ERROR: Attempt to open script 'res://dev/zz_probe/gone.gd' resulted in error 'File not found'.",
    '   at: load_source_code (modules/gdscript/gdscript.cpp:1139)',
    'ERROR: Failed loading resource: res://dev/zz_probe/gone.gd.',
    'ERROR: res://dev/zz_probe/missing_script.tscn:6 - Parse Error: [ext_resource] referenced non-existent resource at: res://dev/zz_probe/gone.gd.',
  );
  assert.equal(errorLines(out, autoloads).filter((l) => !/^\s+at: /.test(l)).length, 3);
});
