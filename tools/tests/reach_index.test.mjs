import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { buildReach, formatChain, parseAutoloads, reachOf } from './reach_index.mjs';

const TEST_MAP = fileURLToPath(new URL('./test_map.mjs', import.meta.url));
const index = {
  tests: {
    'tests/unit/test_boss_fight.gd': 'var spec: BossSpec = BossSpec.new()',
    'tests/unit/test_log.gd': 'Log.info("x")',
    'tests/unit/test_scene.gd': 'load("res://features/hud/hud.tscn")',
  },
  classNames: () => [],
  reach: buildReach({
    sources: {
      'features/bosses/boss_spec.gd': 'class_name BossSpec\nconst TABLE := "res://data/tables/bosses.json"',
      'features/bosses/king.gd': 'const ART := "res://features/bosses/king/art/p%d/%s.png"',
      'features/hud/hud.tscn': '[ext_resource path="res://features/hud/icon.png"]',
      'core/log/log.gd': 'extends Node',
    },
    autoloads: { Log: 'core/log/log.gd' },
  }),
};

test('reachOf returns the chain per reached test', () => {
  const r = reachOf(['project/data/tables/bosses.json'], index);
  assert.deepEqual(Object.keys(r.reached), ['tests/unit/test_boss_fight.gd']);
  assert.equal(r.full, null);
  assert.equal(formatChain(r.reached['tests/unit/test_boss_fight.gd'][0]),
    'data/tables/bosses.json <- features/bosses/boss_spec.gd (res:// path) <- tests/unit/test_boss_fight.gd (names BossSpec)');
});

test('using an autoload does not pull in the tests of the autoload (the hop runs toward users only)', () => {
  const ri = buildReach({ sources: { 'core/log/log.gd': '', 'features/a.gd': 'class_name A\nLog.info("a")' },
    autoloads: { Log: 'core/log/log.gd' } });
  const ix = { tests: { 'tests/unit/test_a.gd': 'A.new()', 'tests/unit/test_log.gd': 'Log.x()' }, classNames: () => [], reach: ri };
  assert.deepEqual(Object.keys(reachOf(['project/features/a.gd'], ix).reached), ['tests/unit/test_a.gd']);
});

test('an autoload script runs in every test, so it maps FULL', () => {
  assert.equal(reachOf(['project/core/log/log.gd'], index).full,
    'project/core/log/log.gd is autoload Log: it runs in every test');
});

test('a formatted literal is cut to its directory; a referrer no test reaches is FULL', () => {
  const r = reachOf(['project/features/bosses/king/art/p55/idle.png'], index);
  assert.equal(r.full, 'project/features/bosses/king/art/p55/idle.png via features/bosses/king.gd: no test reaches it');
});

test('an asset reaches the tests of the scene that references it', () => {
  const r = reachOf(['project/features/hud/icon.png'], index);
  assert.deepEqual(Object.keys(r.reached), ['tests/unit/test_scene.gd']);
  assert.equal(formatChain(r.reached['tests/unit/test_scene.gd'][0]),
    'features/hud/icon.png <- features/hud/hud.tscn (res:// path) <- tests/unit/test_scene.gd (res:// path)');
});

test('a bare res:// or one-segment directory literal is no ancestor reference', () => {
  const ri = buildReach({ sources: { 'core/a.gd': 'const R := "res://"\nconst F := "res://features/"' }, autoloads: {} });
  const r = reachOf(['project/features/q/art/x.png'], { tests: {}, classNames: () => [], reach: ri });
  assert.equal(r.full, 'unreferenced asset project/features/q/art/x.png');
});

test('parseAutoloads reads the [autoload] section only', () => {
  const godot = '[autoload]\n\nLog="*res://core/log/log.gd"\nData="*res://core/data/data.gd"\n\n[debug]\nx="res://y.gd"\n';
  assert.deepEqual(parseAutoloads(godot), { Log: 'core/log/log.gd', Data: 'core/data/data.gd' });
});

test('--why prints the chain (exit 0) and says not reached (exit 1) on the real tree', () => {
  const ok = spawnSync(process.execPath, [TEST_MAP, '--why=tests/unit/test_boss_fight.gd', 'project/data/tables/bosses.json'], { encoding: 'utf8' });
  assert.equal(ok.status, 0, ok.stdout + ok.stderr);
  assert.match(ok.stdout, /data\/tables\/bosses\.json <- features\/bosses\/boss_spec\.gd \(res:\/\/ path\) <- tests\/unit\/test_boss_fight\.gd \(names BossSpec\)/);
  const no = spawnSync(process.execPath, [TEST_MAP, '--why=tests/unit/test_boss_fight.gd', 'project/dev/bench/bench_driver.gd'], { encoding: 'utf8' });
  assert.equal(no.status, 1, no.stdout + no.stderr);
  assert.match(no.stdout, /not reached/);
});

test('--history=N prints the replay figures', () => {
  const r = spawnSync(process.execPath, [TEST_MAP, '--history=5'], { encoding: 'utf8' });
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /commits touching project\/: \d+/);
  assert.match(r.stdout, /FULL: \d+ \(\d+%\)/);
  assert.match(r.stdout, /mean selected files: [\d.]+/);
});
