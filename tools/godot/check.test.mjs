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

test('a cascade with nothing behind it does not fail by itself, but a bare parse error does', () => {
  assert.deepEqual(errorLines('SCRIPT ERROR: Compile Error: Failed to compile depended scripts.', autoloads), []);
  assert.ok(errorLines('SCRIPT ERROR: Parse Error: Expected end of statement', autoloads).length);
});
