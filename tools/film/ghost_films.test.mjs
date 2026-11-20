import assert from 'node:assert/strict';
import test from 'node:test';
import { resolve } from 'node:path';
import { plan, stem } from './ghost_films.mjs';

const args = ['--ghost=kerf', '--look=spectral', '--out=build/ghosts'];

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
