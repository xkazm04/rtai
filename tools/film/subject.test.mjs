import assert from 'node:assert/strict';
import { test } from 'node:test';
import { killedId, subjectRow } from './subject.mjs';

// kills-new n16 REQUEST: a signature kill hides the victim's rig, so --subject=dead read him off screen.
const probe = { events: { kill: [63] }, view: [1280, 800], rows: [
  { tick: 62, fighters: [{ id: 0, role: 'rivet', alive: true, pos: [10, 10], screen: [640, 400], draw: [60, 80] },
    { id: 4, role: 'hostile', alive: false, pos: [0, 0], screen: [1, 1], draw: [30, 14], on_screen: true },
    { id: 7, role: 'hostile', alive: true, pos: [13, 10], screen: [700, 400], draw: [20, 30], on_screen: true }] },
  { tick: 63, fighters: [{ id: 0, role: 'rivet', alive: true, pos: [10, 10], screen: [640, 400], draw: [60, 80] },
    { id: 4, role: 'hostile', alive: false, pos: [0, 0], screen: [1, 1], draw: [30, 14], on_screen: true },
    { id: 7, role: 'hostile', alive: false, pos: [13, 10], screen: [9010, 8368], draw: [-1, -1], on_screen: false }] },
] };

test('kill = the first kill victim (not an older body), placed from the sim when his card is gone', () => {
  assert.equal(killedId(probe), 7);
  const at63 = subjectRow(probe.rows[1], 'kill', { probe, ppm: 32, view: probe.view });
  assert.deepEqual([at63.id, at63.screen, at63.on_screen, at63.placed], [7, [736, 400], true, 'sim']);
  assert.equal(subjectRow(probe.rows[1], 'dead').id, 4, 'dead picks the older on-screen body: why kill exists');
  const carded = subjectRow(probe.rows[0], 'kill', { probe, ppm: 32 });
  assert.deepEqual([carded.screen, carded.placed], [[700, 400], undefined], 'with a card his drawn point stands');
});

test('kill without a kill, or without numbers, is null (unverifiable upstream, never a pass)', () => {
  assert.equal(subjectRow(probe.rows[1], 'kill', { probe: { ...probe, events: { kill: [] } }, ppm: 32 }), null);
  assert.equal(subjectRow(probe.rows[1], 'kill', null), null);
});
