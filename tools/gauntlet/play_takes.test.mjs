import { test } from 'node:test';
import assert from 'node:assert/strict';
import { encodeArgs, MAIN, parse, probeProblem, scoutArgs, sides, sideSpec, takeArgs } from './play_takes.mjs';

const BASE = ['--seed=3', '--wave=6', '--seconds=30', '--out=C:/m/n31/foes', '--name=wave6_side'];
const HEAD = 'f'.repeat(40);
const MAIN_SHA = 'ba8e470b0' + 'a'.repeat(31);

test('parse: defaults are main on the left, HEAD on the right, average, 32 px/m, 1 s lead', () => {
  const a = parse(BASE);
  assert.equal(a.seed, 3);
  assert.equal(a.wave, 6);
  assert.equal(a.seconds, 30);
  assert.equal(a.profile, 'average');
  assert.equal(a.ppm, 32);
  assert.equal(a.lead, 1);
  assert.deepEqual(a.left, { kind: 'rev', value: MAIN });
  assert.deepEqual(a.right, { kind: 'rev', value: 'HEAD' });
});

test('parse: refuses out-of-range seconds, relative out, bad ppm, bad name', () => {
  assert.throws(() => parse([...BASE.slice(0, 2), '--seconds=41', ...BASE.slice(3)]), /seconds/);
  assert.throws(() => parse([...BASE.slice(0, 2), '--seconds=14', ...BASE.slice(3)]), /seconds/);
  assert.throws(() => parse(BASE.map((x) => (x.startsWith('--out') ? '--out=rel/dir' : x))), /--out/);
  assert.throws(() => parse([...BASE, '--ppm=48']), /ppm/);
  assert.throws(() => parse(BASE.map((x) => (x.startsWith('--name') ? '--name=Bad Name' : x))), /--name/);
  assert.throws(() => parse([...BASE, '--profile=pro']), /profile/);
});

test('sideSpec: rev, flags, HEAD and live; junk refused', () => {
  assert.deepEqual(sideSpec('rev:abc123', 'left'), { kind: 'rev', value: 'abc123' });
  assert.deepEqual(sideSpec('flags:--foe-moves=legacy', 'left'), { kind: 'flags', value: '--foe-moves=legacy' });
  assert.deepEqual(sideSpec('live', 'right'), { kind: 'live', value: '' });
  assert.throws(() => sideSpec('main', 'left'), /--left/);
  assert.throws(() => sideSpec('flags:rm -rf', 'right'), /flags/);
});

test('sides: main | HEAD labels, flags run at the launch HEAD', () => {
  const s = sides(parse(BASE), { head: HEAD, mainSha: MAIN_SHA, resolve: () => MAIN_SHA });
  assert.deepEqual(s.map((x) => [x.key, x.rev, x.label]), [['left', MAIN_SHA, 'main'], ['right', HEAD, 'HEAD']]);
  const f = sides(parse([...BASE, '--left=flags:--foe-moves=legacy']), { head: HEAD, mainSha: MAIN_SHA });
  assert.deepEqual(f[0], { key: 'left', rev: HEAD, flags: ['--foe-moves=legacy'], label: '--foe-moves=legacy' });
});

test('plan: the scout and the take share the run flags; the take opens lead s before the spawn', () => {
  const a = parse(BASE);
  const [, right] = sides(a, { head: HEAD, mainSha: MAIN_SHA });
  const scout = scoutArgs(a, right);
  assert.equal(scout[0], 'res://dev/foes_n31/play_take.tscn');
  for (const f of ['--seed=3', '--bot=average', '--pick=greedy', '--controls=wheel', '--pick-view', '--take-wave=6']) assert.ok(scout.includes(f), f);
  const take = takeArgs(a, right, 5000, 'C:\\b\\right');
  assert.deepEqual(take.slice(0, 2), ['--rendering-driver', 'd3d12']);
  assert.equal(take[take.indexOf('--position') + 1], '0,1440');
  assert.ok(take.includes('--take-tick=4939'));
  assert.ok(take.includes('--take-s=30'));
  assert.ok(take.includes('--frames-out=C:/b/right'));
  assert.ok(take.includes('--zoom-ppm=32'));
  assert.equal(take[take.indexOf('--quit-after') + 1], String(30 * 60 + 600));
  assert.ok(takeArgs(a, right, 10, 'C:/x').includes('--take-tick=0'));
});

test('encode: crf 28 slow for all, labelled side by side of the centre 960 px', () => {
  const e = encodeArgs(parse(BASE), { left: 'L', right: 'R' });
  assert.equal(e.left.at(-1), 'wave6_side_left.mp4');
  assert.equal(e.left[e.left.indexOf('-crf') + 1], '28');
  assert.equal(e.side[e.side.indexOf('-crf') + 1], '28');
  assert.equal(e.side[e.side.indexOf('-preset') + 1], 'slow');
  assert.equal(e.side[e.side.indexOf('-maxrate') + 1], '6M');
  assert.equal(e.side[e.side.indexOf('-bufsize') + 1], '12M');
  assert.equal(e.side[e.side.indexOf('-frames:v') + 1], '1800');
  const graph = e.side[e.side.indexOf('-filter_complex') + 1];
  assert.match(graph, /crop=960:1080:480:0,drawtext=.*textfile=label_left\.txt/);
  assert.match(graph, /hstack=inputs=2/);
});

test('probeProblem: size, fps and duration within 0.1 s', () => {
  const ok = { width: 1920, height: 1080, avg_frame_rate: '60/1', duration: '30.000000' };
  assert.equal(probeProblem(ok, 30), '');
  assert.match(probeProblem({ ...ok, duration: '29.85' }, 30), /duration/);
  assert.match(probeProblem({ ...ok, avg_frame_rate: '30/1' }, 30), /fps/);
  assert.match(probeProblem({ ...ok, width: 1280 }, 30), /size/);
});
