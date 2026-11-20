import { resolve } from 'node:path';
import { parseArgs } from 'node:util';

const GHOSTS = ['tonnage', 'dent', 'kerf', 'ohm'];
const TAKES = ['move', 'attack', 'close'];
export const START = 68;
export const FRAMES = 300;
export const TURN = 163;

export function plan(argv) {
  const options = Object.fromEntries(['ghost', 'look', 'out', 'takes', 'stills', 'prefix', 'name'].map(k => [k, { type: 'string' }]));
  options.all = { type: 'boolean' };
  const { values: v } = parseArgs({ args: argv, options });
  if (!['legacy', 'spectral'].includes(v.look)) throw Error('--look requires legacy or spectral');
  if (!v.out) throw Error('--out requires a directory');
  if (v.all) {
    for (const key of ['ghost', 'takes', 'stills', 'prefix']) {
      if (v[key] !== undefined) throw Error('--' + key + ' cannot be combined with --all');
    }
    const name = v.name ?? 'all_ghosts_32';
    if (!/^[a-z0-9][a-z0-9_-]*$/i.test(name)) throw Error('--name requires a plain filename stem');
    const chapters = GHOSTS.flatMap(ghost => ['move', 'attack'].map(take => ({ ghost, take })));
    return { all: true, out: resolve(v.out), look: v.look, name, chapters };
  }
  if (v.name !== undefined) throw Error('--name requires --all');
  if (!GHOSTS.includes(v.ghost)) throw Error('--ghost requires ' + GHOSTS.join(', '));
  const takes = [...new Set((v.takes ?? TAKES.join(',')).split(','))];
  if (takes.some(t => !TAKES.includes(t) && t !== 'morph')) throw Error('--takes requires move, attack, close or morph');
  const stills = v.stills === undefined ? [] : [...new Set(v.stills.split(','))];
  if (stills.some(t => !/^\d+$/.test(t) || +t < START || +t >= START + FRAMES)) {
    throw Error('--stills requires arena ticks 68 through 367');
  }
  const prefix = v.prefix ?? '';
  if (!/^[a-z0-9_-]*$/i.test(prefix)) throw Error('--prefix must be a filename prefix');
  return { ghost: v.ghost, look: v.look, out: resolve(v.out), takes, stills: stills.map(Number), prefix };
}

export function stem(p, take, tick) {
  const name = p.prefix + p.ghost;
  return take === 'turn' ? name + '_turn_64_t' + tick : name + '_' + take + '_' + (take === 'close' ? 64 : 32);
}
