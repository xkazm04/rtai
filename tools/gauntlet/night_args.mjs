import { join } from 'node:path';
import { parseArgs } from 'node:util';
import { parseArgs as batchArgs } from './commands.mjs';
import { lanePath } from './night_paths.mjs';
import { checkLocation } from './night_worktree.mjs';
import { floorMode } from './tune_floor.mjs';

export const tool = (name) => 'tools/gauntlet/' + name + '.mjs';

export function parseNight(argv, root) {
  const strings = ['worktree', 'branch', 'out', 'profile', 'pick', 'controls', 'seeds', 'waves', 'floor-mode'];
  const options = Object.fromEntries(strings.map((key) => [key, { type: 'string' }]));
  options['dry-run'] = options.remove = { type: 'boolean' };
  const { values: v } = parseArgs({ args: argv, options });
  const job = { path: v.worktree, branch: v.branch, remove: v.remove, dryRun: v['dry-run'] };
  checkLocation(root, job.path, job.branch);
  if (v.remove) return job;
  const previewBuild = job.dryRun && v.out && v.out.replaceAll('\\', '/').includes('/build/n23/');
  const dir = lanePath(root, v.out, previewBuild ? 'build/n23' : 'evidence/n23-loop');
  const profile = v.profile ?? 'average', pick = v.pick ?? 'greedy', controls = v.controls ?? 'wheel';
  const flags = ['--seeds=' + (v.seeds ?? ''), '--profile=' + profile, '--pick=' + pick,
    '--controls=' + controls, '--seed0=1', '--jobs=1'];
  if (v.waves !== undefined) flags.push('--waves=' + v.waves);
  const batch = batchArgs(flags);
  return { ...job, dir, profile, pick, controls, seeds: batch.seeds, flags, mode: floorMode(v['floor-mode']) };
}

export function recipe(job) {
  const { dir, profile, flags, mode } = job;
  const before = join(dir, 'before'), after = join(dir, 'after'), neutral = join(dir, 'null'), plan = join(dir, 'plan.json');
  const batch = (arm) => [tool('batch'), ...flags, '--out=' + arm];
  const file = (arm) => join(arm, 'batch.json');
  const report = (arm) => [tool('report'), '--batch=' + file(arm)];
  return [batch(before), [...batch(neutral), '--salt=1'], report(before),
    [tool('tune'), 'propose', '--batch=' + file(before), '--out=' + plan, '--profile=' + profile],
    [tool('tune'), 'apply', '--plan=' + plan], batch(after),
    [tool('tune'), 'confirm', '--before=' + file(before), '--after=' + file(after), '--null=' + file(neutral),
      '--floor-mode=' + mode, '--plan=' + plan, '--revert'],
    [...report(after), '--baseline=' + file(before)]];
}
