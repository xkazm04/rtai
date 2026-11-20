import assert from 'node:assert/strict';
import test from 'node:test';
import { resolve } from 'node:path';
import { encodeArgs, plan, stem } from './ghost_films.mjs';

const args = ['--ghost=kerf', '--look=spectral', '--out=build/ghosts'];

test('movies convert full-range MJPEG to limited-range H.264 and tag it', () => {
  const graph = '[c0][c1]concat=n=2:v=1:a=0';
  const args = encodeArgs(graph);
  const value = flag => args[args.indexOf(flag) + 1];
  assert.equal(value('-filter_complex'), graph + ',scale=in_range=pc:out_range=tv,format=yuv420p[out]');
  assert.equal(value('-map'), '[out]');
  assert.equal(value('-c:v'), 'libx264');
  assert.equal(value('-pix_fmt'), 'yuv420p');
  assert.equal(value('-color_range'), 'tv');
  const still = encodeArgs(graph, 163);
  assert.equal(still[still.indexOf('-filter_complex') + 1], graph + '[out]');
  assert.ok(!still.includes('-color_range'));
});

test('default takes and native-scale output names', () => {
  const p = plan(args);
  assert.deepEqual(p.takes, ['move', 'attack', 'close']);
  assert.deepEqual(p.stills, []);
  assert.equal(p.out, resolve('build/ghosts'));
  assert.deepEqual(p.takes.map(t => stem(p, t)), ['kerf_move_32', 'kerf_attack_32', 'kerf_close_64']);
});

test('selection, prefix and exact tick filenames', () => {
  const p = plan([...args, '--takes=move,close,move', '--stills=163,205,163', '--prefix=flight_']);
  assert.deepEqual(p.takes, ['move', 'close']);
  assert.deepEqual(p.stills, [163, 205]);
  assert.equal(stem(p, 'turn', 163), 'flight_kerf_turn_64_t163');
  assert.equal(stem(p, 'close'), 'flight_kerf_close_64');
});

test('invalid inputs are rejected before the engine runs', () => {
  for (const option of ['--ghost=unknown', '--look=p70', '--takes=run', '--stills=67', '--stills=368', '--stills=11.3',
    '--prefix=../escape', '--invalid=1']) assert.throws(() => plan([...args, option]));
  assert.throws(() => plan(args.slice(0, 2)), /out/);
});

test('morph has its own native 32 px/m take', () => {
  const p = plan([...args, '--takes=morph', '--prefix=flight_']);
  assert.deepEqual(p.takes, ['morph']);
  assert.equal(stem(p, 'morph'), 'flight_kerf_morph_32');
});

test('all selects eight ordered chapters and a single named reel', () => {
  const base = ['--all', '--look=spectral', '--out=build/ghosts'];
  assert.equal(plan(base).name, 'all_ghosts_32');
  const reel = plan([...base, '--name=morning']);
  assert.equal(reel.name, 'morning');
  assert.equal(reel.look, 'spectral');
  assert.deepEqual(reel.chapters.map(c => c.ghost + '/' + c.take), [
    'tonnage/move', 'tonnage/attack', 'dent/move', 'dent/attack',
    'kerf/move', 'kerf/attack', 'ohm/move', 'ohm/attack',
  ]);
  for (const arg of ['--ghost=kerf', '--takes=move', '--stills=163', '--prefix=x', '--name=../escape']) {
    assert.throws(() => plan([...base, arg]));
  }
  assert.throws(() => plan([...args, '--name=morning']), /--all/);
});
