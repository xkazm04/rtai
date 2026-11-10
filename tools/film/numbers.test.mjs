import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { EXIT, main, parseArgv, summarize } from './numbers.mjs';

const rivet = (tick, feet, head) => ({ tick, fighters: [{ id: 1, role: 'rivet', alive: true, on_screen: true, feet_y: feet, head_y: head, draw: [40, 80], screen: [640, 400], facing_off: 3 }] });

test('a window gives each measure its range, and -1 means no card, not a height', () => {
  const { reasons, stats } = summarize([rivet(10, 400, 330), rivet(11, 412, 333), rivet(12, -1, -1), rivet(13, 406, 331)], 'rivet', '10-13');
  assert.deepEqual(reasons, []);
  assert.deepEqual(stats.measures.feet_y, { min: 400, max: 412, range: 12 });
  assert.equal(stats.measures.head_y.range, 3);
  assert.equal(stats.no_card_ticks, 1);
});

test('a 999 facing (no rig) is not an angle', () => {
  const { stats } = summarize([{ tick: 0, fighters: [{ role: 'rivet', feet_y: 400, facing_off: 999 }] }], 'rivet');
  assert.equal(stats.measures.facing_off, undefined);
});

test('ticks outside the window are not measured', () => {
  const { stats } = summarize([rivet(5, 900, 0), rivet(10, 400, 300)], 'rivet', '10-20');
  assert.equal(stats.measures.feet_y.range, 0);
  assert.equal(stats.from, 10);
});

test('what cannot be read is a reason, never numbers', () => {
  assert.match(summarize([rivet(1, 400, 300)], 'rivet', '50-60').reasons[0], /no ticks/);
  assert.match(summarize([rivet(1, 400, 300)], 'dead').reasons[0], /no dead/);
  assert.match(summarize([{ tick: 1, fighters: [{ role: 'rivet', feet_y: -1, head_y: -1, facing_off: 999 }] }], 'rivet').reasons[0], /no card/);
});

test('arguments are checked before anything is read', () => {
  for (const bad of [[], ['d', '--ticks=5'], ['d', '--subject=nobody'], ['d', '--bogus'], ['d', 'e']]) assert.ok(parseArgv(bad).error, bad.join(' '));
  assert.deepEqual(parseArgv(['d', '--subject=id:4', '--ticks=1-9']).flags, { subject: 'id:4', ticks: '1-9' });
});

test('a film with no probe is unverifiable, a damaged one too, a missing directory is usage', (t) => {
  const dir = mkdtempSync(join(tmpdir(), 'numbers-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const out = [];
  assert.equal(main([dir], { out: (s) => out.push(s), err: (s) => out.push(s) }), EXIT.unverifiable);
  writeFileSync(join(dir, 'probe.json'), '{"rows":');
  assert.equal(main([dir], { out: () => {}, err: () => {} }), EXIT.unverifiable);
  assert.equal(main([join(dir, 'nope')], { out: () => {}, err: () => {} }), EXIT.usage);
  assert.match(out[0], /UNVERIFIABLE/);
});

test('a real probe prints its ranges, and --json holds the same numbers', (t) => {
  const dir = mkdtempSync(join(tmpdir(), 'numbers-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  writeFileSync(join(dir, 'probe.json'), JSON.stringify({ rows: [rivet(1, 400, 300), rivet(2, 410, 301)] }));
  const lines = [];
  assert.equal(main([dir, '--json'], { out: (s) => lines.push(s) }), EXIT.pass);
  assert.equal(JSON.parse(lines[0]).measures.feet_y.range, 10);
  lines.length = 0;
  assert.equal(main([dir], { out: (s) => lines.push(s) }), EXIT.pass);
  assert.ok(lines.some((l) => /feet_y\s+400 \.\. 410\s+range 10/.test(l)));
});

test('a screen position of -1 or 999 is a position, not a sentinel', () => {
  const row = (x) => ({ tick: 1, fighters: [{ role: 'rivet', feet_y: 400, screen: [x, 400] }] });
  assert.equal(summarize([row(-1), row(999)], 'rivet').stats.measures.screen_x.range, 1000);
});
