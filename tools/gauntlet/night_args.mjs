import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { parseArgs } from 'node:util';
import { readJson } from '../lib/repo.mjs';
import { parseArgs as batchArgs } from './commands.mjs';
import { lanePath } from './night_paths.mjs';
import { checkLocation } from './night_worktree.mjs';
import { deathMetric } from './tune_propose.mjs';
import { floorMode } from './tune_floor.mjs';

export const tool = (name) => 'tools/gauntlet/' + name + '.mjs';

function armPaths(root, dir, v) {
  const plan = join(dir, 'plan.json');
  const resume = Boolean(v['after-from'] && existsSync(plan));
  const inputs = {}, files = {};
  for (const role of ['before', 'null', 'after']) {
    const arg = v[role === 'after' ? 'after-from' : role];
    const local = join(dir, role, 'batch.json');
    inputs[role] = arg !== undefined || (resume && existsSync(local));
    files[role] = arg === undefined ? local : lanePath(root, arg, 'evidence');
  }
  if (inputs.null && !inputs.before) throw new Error('--null requires --before');
  if (resume && (!inputs.before || !inputs.null)) throw new Error('resuming a plan needs its before and null batches');
  return { plan, inputs, files, resume };
}

function design(v, arms) {
  const base = arms.inputs.before ? readJson(arms.files.before).args : {};
  const flag = (key, fallback) => '--' + key + '=' + (v[key] ?? base[key] ?? fallback);
  const flags = [flag('seeds', ''), flag('profile', 'average'), flag('pick', 'greedy'),
    flag('controls', 'wheel'), flag('seed0', 1), '--jobs=' + (v.jobs ?? 1)];
  if (v.waves !== undefined || base.waves != null) flags.push(flag('waves'));
  if (base.runner) flags.push('--runner=' + base.runner);
  if (base.pickFilter) flags.push('--pick-filter=' + base.pickFilter);
  if (base.salt) flags.push('--salt=' + base.salt);
  return { flags, batch: batchArgs(flags) };
}

export function parseNight(argv, root) {
  const strings = ['worktree', 'branch', 'out', 'profile', 'pick', 'controls', 'seeds', 'waves', 'floor-mode',
    'before', 'null', 'after-from', 'metric', 'jobs'];
  const options = Object.fromEntries(strings.map((key) => [key, { type: 'string' }]));
  options['dry-run'] = options.remove = { type: 'boolean' };
  const { values: v } = parseArgs({ args: argv, options });
  const job = { path: v.worktree, branch: v.branch, remove: v.remove, dryRun: v['dry-run'] };
  checkLocation(root, job.path, job.branch);
  if (v.remove) return job;
  const previewBuild = job.dryRun && v.out && v.out.replaceAll('\\', '/').includes('/build/n23/');
  const dir = lanePath(root, v.out, previewBuild ? 'build/n23' : 'evidence/n23-loop');
  const arms = armPaths(root, dir, v);
  const { flags, batch } = design(v, arms);
  const metric = deathMetric(v.metric);
  const mode = floorMode(v['floor-mode']);
  if (metric && (mode !== 'null-salt' || batch.runner !== 'gauntlet')) throw new Error('death needs the street and null-salt floor');
  return { ...job, ...arms, dir, batch, flags, metric, mode };
}

export function recipe(job) {
  const { dir, batch, flags, mode, files, inputs, plan } = job;
  const measure = (arm) => [tool('batch'), ...flags, '--out=' + join(dir, arm)];
  const neutral = measure('null').filter((arg) => !arg.startsWith('--salt='));
  const report = (arm) => [tool('report'), '--batch=' + files[arm], '--out=' + join(dir, arm)];
  return [
    ...(!inputs.before ? [measure('before')] : []),
    ...(!inputs.null ? [[...neutral, '--salt=' + (batch.salt === 1 ? 0 : 1)]] : []),
    ...(!job.resume || !existsSync(join(dir, 'before/report.md')) ? [report('before')] : []),
    ...(!job.resume ? [[tool('tune'), 'propose', '--batch=' + files.before, '--out=' + plan, '--profile=' + batch.profile,
      ...(job.metric ? ['--metric=' + job.metric] : [])]] : []),
    [tool('tune'), 'apply', '--plan=' + plan],
    ...(!inputs.after ? [measure('after')] : []),
    [tool('tune'), 'confirm', '--before=' + files.before, '--after=' + files.after, '--null=' + files.null,
      '--floor-mode=' + mode, '--plan=' + plan, '--ledger-dir=' + join(dir, 'after'), '--revert'],
    [...report('after'), '--baseline=' + files.before]];
}
