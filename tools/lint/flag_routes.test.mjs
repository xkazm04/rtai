import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { test } from 'node:test';
import { ROOT } from '../lib/repo.mjs';
import { flagRoutesCheck, guardTerms, unroutedFlags } from '../style/flag_routes.mjs';

// c8d71e34a's shape: the multi-line guard routes three prefixes, the helper matches two more flags.
const BROKEN = [
  'static func apply(args: PackedStringArray) -> void:',
  '\tfor arg: String in args:',
  '\t\tif arg == "--gun-grey":',
  '\t\t\tpass',
  '\t\telif (',
  '\t\t\targ.begins_with("--rivet-walk=")',
  '\t\t\tor arg.begins_with("--rivet-bob")',
  '\t\t):',
  '\t\t\t_walk(arg)',
  '\t\telif arg in WINDUP_FLAGS:',
  '\t\t\t_windup(arg)',
  '',
  '',
  'static func _walk(arg: String) -> void:',
  '\tmatch arg:',
  '\t\t"--rivet-walk=4":',
  '\t\t\tpass',
  '\t\t"--rivet-stride=off":  # the flag c8d71e34a stranded',
  '\t\t\tpass',
  '\t\t"--rivet-bob=drawn":',
  '\t\t\tpass',
  '',
  '',
  'static func _windup(arg: String) -> void:',
  '\tif arg == "--rivet-windup=off":',
  '\t\tpass',
  '',
].join('\n');
const LIST = 'const WINDUP_FLAGS: PackedStringArray = [\n\t"--rivet-windup=off", "--rivet-blade-left=off"\n]\n';

test('the stranded flag is named with its line and the guard; a prefix-routed one is not', () => {
  const issues = unroutedFlags('x.gd', LIST + BROKEN);
  assert.equal(issues.length, 1, issues.join('\n'));
  assert.match(issues[0], /^x\.gd:21: "--rivet-stride=off" is matched in _walk\(\) but no caller routes it there/);
  assert.match(issues[0], /guard: arg\.begins_with\("--rivet-walk="\) or arg\.begins_with\("--rivet-bob"\)/);
});

test('an `in CONST` guard routes exactly its list', () => {
  const missing = LIST.replace(', "--rivet-blade-left=off"', '').replace('"--rivet-windup=off"', '"--rivet-left=off"');
  assert.match(unroutedFlags('x.gd', missing + BROKEN).join('\n'), /"--rivet-windup=off" is matched in _windup\(\)/);
});

test('a guard with anything but or-joined begins_with / == / in is not judged (no claim, no alarm)', () => {
  assert.equal(guardTerms('arg.begins_with("--a") and not quiet', 'arg', new Map()), null);
  assert.equal(guardTerms('(arg == "--a") or (arg.begins_with("--b"))', 'arg', new Map()).test('--b=1'), true);
  const judged = BROKEN.replace('\t\t\tor arg.begins_with("--rivet-bob")', '\t\t\tor arg.length() > 99');
  assert.deepEqual(unroutedFlags('x.gd', LIST + judged), []);
});

test('the real tree: cast_flags.gd routes every flag its helpers match; tests/ are skipped', () => {
  const src = readFileSync(join(ROOT, 'project/features/characters/cast_flags.gd'), 'utf8');
  assert.deepEqual(unroutedFlags('cast_flags.gd', src.replace(/\r\n/g, '\n')), []);
  const r = flagRoutesCheck(() => [{ path: 'project/tests/unit/t.gd', src: LIST + BROKEN }, { path: 'project/a.gd', src: LIST + BROKEN }]);
  assert.equal(r.ok, false);
  assert.equal(r.issues.length, 1);
  assert.match(r.issues[0], /^project\/a\.gd:/);
});
