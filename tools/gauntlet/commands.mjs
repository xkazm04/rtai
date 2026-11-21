import { join, resolve } from 'node:path';
import { parseArgs as parseOptions } from 'node:util';
import { MAX_SEED, PROFILES } from './contract.mjs';

const textFlags = ['seeds', 'seed0', 'profile', 'pick', 'waves', 'jobs', 'out', 'runner', 'controls', 'from'];

function integer(name, value, min, max = Number.MAX_SAFE_INTEGER) {
  const n = Number(value);
  if (!/^\d+$/.test(value) || !Number.isSafeInteger(n) || n < min || n > max)
    throw new Error('--' + name + ' must be an integer in ' + min + '..' + max);
  return n;
}

function choice(name, value, allowed) {
  if (!allowed.includes(value)) throw new Error('--' + name + ' must be ' + allowed.join('|'));
  return value;
}

export function parseArgs(argv) {
  const options = Object.fromEntries(textFlags.map((name) => [name, { type: 'string' }]));
  options['dry-run'] = { type: 'boolean' };
  const { values: v } = parseOptions({ args: argv, options });
  const profile = choice('profile', v.profile, [...PROFILES, 'all']);
  const pick = choice('pick', v.pick, ['random', 'greedy']);
  const runner = choice('runner', v.runner ?? 'gauntlet', ['gauntlet', 'pit']);
  const controls = v.from && !v.controls ? null : choice('controls', v.controls ?? 'legacy', ['wheel', 'legacy']);
  if (runner === 'pit' && controls === 'wheel') throw new Error('the pit probe supports --controls=legacy only');
  const jobs = integer('jobs', v.jobs ?? '1', 1);
  if (jobs > 2) throw new Error('--jobs maximum is 2; the machine is shared by four lanes');
  if (!v.from && !v.seeds) throw new Error('--seeds=N is required for a live batch');
  const seeds = v.seeds === undefined ? null : integer('seeds', v.seeds, 1);
  const seed0 = integer('seed0', v.seed0 ?? '1', 0, MAX_SEED);
  if (seeds !== null && seeds - 1 > MAX_SEED - seed0) throw new Error('last seed exceeds uint32');
  if (v.from && v['dry-run']) throw new Error('--from and --dry-run select different input modes');
  if (v.from && v.seed0 !== undefined && seeds === null) throw new Error('--seed0 needs --seeds in offline mode');
  return { profile, pick, runner, controls, jobs, seeds, seed0,
    waves: v.waves === undefined ? null : integer('waves', v.waves, 1),
    out: resolve(v.out ?? 'build/gauntlet/batch'), from: v.from ? resolve(v.from) : null,
    dryRun: v['dry-run'] ?? false };
}

/** Exact dev entry arguments for running or replaying one seed. */
export function entryArgs({ runner, profile, seed, pick, controls, waves }, result) {
  const args = runner === 'pit' ? ['bot_pit_probe', '--profile=' + profile, '--seed=' + seed]
    : ['gauntlet', '--seed=' + seed];
  if (runner !== 'pit') {
    if (profile !== 'human') args.push('--bot=' + profile, '--pick=' + pick);
    args.push('--controls=' + controls);
  }
  if (waves != null) args.push('--waves=' + waves);
  if (result) args.push('--result=' + result);
  return args;
}

export function* plan(args) {
  const profiles = args.profile === 'all' ? PROFILES : [args.profile];
  for (const profile of profiles) {
    for (let seed = args.seed0; seed < args.seed0 + args.seeds; seed++) {
      const file = join(args.out, 'runs', profile + '-' + seed + '.json');
      yield { profile, seed, file, argv: entryArgs({ ...args, profile, seed }, file) };
    }
  }
}

// Single quotes also preserve spaces and literal dollar signs in the lane's PowerShell.
export function nodeCommand(argv) {
  const quote = (arg) => /^[\w./:=\\-]+$/.test(arg) ? arg : "'" + arg.replaceAll("'", "''") + "'";
  return ['node', ...argv].map(quote).join(' ');
}

export const commandLine = (argv) => nodeCommand(['tools/dev/run.mjs', ...argv]);
