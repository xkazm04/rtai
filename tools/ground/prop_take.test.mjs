import { test } from 'node:test';
import assert from 'node:assert/strict';
import { drawnEdge, gauntletProbes, passProbe, stopProbe, stopsMarkdown, yardProbes } from './prop_take_lib.mjs';
import { godotArgs, parse } from './prop_take.mjs';

const box = { x0: 10, x1: 14, y0: 2, y1: 4 };

test('drawnEdge: the drawing starts inside the footprint by the mismatch', () => {
  const mm = { west: 0.5, east: 0.25, north: 1, south: -0.5 };
  assert.equal(drawnEdge(box, mm, 'W'), 10.5);
  assert.equal(drawnEdge(box, mm, 'E'), 13.75);
  assert.equal(drawnEdge(box, mm, 'N'), 3);
  assert.equal(drawnEdge(box, mm, 'S'), 4.5);
  assert.equal(drawnEdge(box, undefined, 'S'), 4);
});

test('stopProbe walks at the named side along the centre line', () => {
  const p = stopProbe({ id: 'c', box, mm: { south: -0.5 }, side: 'S', gap: 3, arena: 'yard' });
  assert.deepEqual(p.start, [12, 7]);
  assert.deepEqual(p.dir, [0, -1]);
  assert.equal(p.edge, 4.5);
  assert.equal(p.box_edge, 4);
  assert.equal(stopProbe({ id: 'c', box, side: 'W', arena: 'gauntlet', segment: 'k' }).segment, 'k');
});

test('passProbe uses its pass line as the edge', () => {
  const p = passProbe({ id: 'a', prop: 'a', start: [1, 2], dir: [1, 0], passTo: 5, arena: 'yard' });
  assert.equal(p.mode, 'pass');
  assert.equal(p.edge, 5);
});

test('yardProbes and gauntletProbes build the briefed set', () => {
  const cover = ['conveyor_door', 'conveyor_turn', 'conveyor_return', 'fuel_vessel'].map((id, i) => ({ id, at: [20 + i * 3, 10], size_m: [2, 1] }));
  const debris = ['arch_feed', 'span_door_feed', 'drag_door', 'belt_feed'].map((id, i) => ({ id, at: [30, 5 + i], size_m: [8, 4] }));
  const y = yardProbes({ layout: { cover, debris } }, []);
  assert.equal(y.length, 8);
  assert.equal(y.filter((p) => p.mode === 'pass').length, 4);
  const props = [{ kind: 'wall_high', at: [1, 1], size: [3, 1] }, { kind: 'cover_high', at: [5, 1], size: [3, 1] }, { kind: 'cover_low', at: [9, 1], size: [3, 1] }, { kind: 'cover_low', at: [13, 1], size: [3, 1] }, { kind: 'cover_low', at: [17, 1], size: [3, 1] }, { kind: 'cover_low', at: [21, 1], size: [3, 1] }, { kind: 'cover_low', at: [25, 1], size: [3, 1] }];
  const fixtures = [{ art: 'payphone', at: [11, -6.7] }, { art: 'street_sign', at: [22, -6.6] }];
  const segs = ['kiosk_plaza', 'market_stalls', 'plain_block'].map((id) => ({ id, props, dressing: { fixtures } }));
  const g = gauntletProbes(segs, []);
  assert.equal(g.length, 7);
  assert.ok(g.every((p) => p.segment));
});

test('stopsMarkdown reads negative stop_m as inside the drawing', () => {
  const md = stopsMarkdown('t', [{ id: 'a', arena: 'yard', mode: 'stop', edge: 1 }, { id: 'b', arena: 'yard', mode: 'pass', edge: 1 }], [{ id: 'a', verdict: 'stopped', stop_m: -0.5, walked_m: 2 }, { id: 'b', verdict: 'passed', stop_m: -0.1, walked_m: 3 }]);
  assert.match(md, /stopped INSIDE the drawing/);
  assert.match(md, /passed through/);
});

test('parse and godotArgs', () => {
  assert.ok(parse(['--rev=x']).error);
  assert.ok(parse(['--rev=x', '--out=o', '--arena=moon']).error);
  assert.equal(parse(['--rev=x', '--out=o']).f.arena, 'yard');
  assert.ok(godotArgs('gauntlet', 'a.avi', '3').includes('--pick-view'));
  assert.ok(!godotArgs('yard', 'a.avi', '3').includes('--pick-view'));
});
