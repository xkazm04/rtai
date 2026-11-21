#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { mkdirSync, readdirSync } from 'node:fs';
import { isAbsolute, join, relative, resolve, sep } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { ROOT, readJson } from '../lib/repo.mjs';
import { nodeCommand, parseArgs as batchArgs } from './commands.mjs';
import { fmt } from './report_tables.mjs';
import { artifact } from './tune.mjs';
import { isTuneBranch, nightOf } from './tune_git.mjs';
import { atomicWrite, git, withLock } from './tune_state.mjs';

const tool = (name) => 'tools/gauntlet/' + name + '.mjs';
const portable = (path) => path.split(sep).join('/');

function recipe(argv, root) {
  const strings = ['out', 'profile', 'pick', 'controls', 'seeds'].map((key) => [key, { type: 'string' }]);
  const { values } = parseArgs({ args: argv, options: { ...Object.fromEntries(strings), 'dry-run': { type: 'boolean' } } });
  if (!values.seeds) throw new Error('--seeds=N is required');
  const profile = values.profile ?? 'average', pick = values.pick ?? 'greedy', controls = values.controls ?? 'wheel';
  const flags = ['--seeds=' + values.seeds, '--profile=' + profile, '--pick=' + pick, '--controls=' + controls, '--seed0=1', '--jobs=1'];
  batchArgs(flags); // Validate the identical seed range and policy used for both runs.
  const dir = resolve(values.out ?? join(root, 'build/gauntlet/night-' + nightOf()));
  artifact(root, join(dir, 'plan.json'));
  const rel = relative(root, dir);
  if (!rel) throw new Error('choose a dedicated night output directory');
  const inside = !isAbsolute(rel) && rel !== '..' && !rel.startsWith('..' + sep);
  const out = portable(inside ? rel : dir);
  const scope = inside && !/^(build|evidence)\//i.test(out) ? ['--night-output=' + out] : [];
  const before = out + '/before', after = out + '/after', plan = out + '/plan.json';
  const batches = (arm) => [tool('batch'), ...flags, '--out=' + arm];
  const report = (arm) => [tool('report'), '--batch=' + arm + '/batch.json'];
  const steps = [batches(before), report(before),
    [tool('tune'), 'propose', '--batch=' + before + '/batch.json', '--out=' + plan, '--profile=' + (profile === 'all' ? 'average' : profile)],
    [tool('tune'), 'apply', '--plan=' + plan, ...scope], batches(after),
    [tool('tune'), 'confirm', '--before=' + before + '/batch.json', '--after=' + after + '/batch.json', '--plan=' + plan, '--revert', ...scope],
    [...report(after), '--baseline=' + before + '/batch.json']];
  return { dir, out, steps, profile, pick, controls, seeds: Number(values.seeds), dryRun: values['dry-run'] };
}

function summary(job, branch, ledger) {
  const lines = ['# Gauntlet night', '', branch + ', ' + job.profile + ', ' + job.pick + ', ' + job.controls
    + ', seeds 1 through ' + job.seeds + '. Matched ' + ledger.matched_runs + ' of ' + ledger.before_runs
    + ' before and ' + ledger.after_runs + ' after runs.', '',
    '[Before batch](before/batch.json) · [Before report](before/report.md) · [Plan](plan.json) · '
    + '[Confirm batch](after/batch.json) · [Confirm report](after/report.md) · [Seed pairs and verdicts](after/tune-ledger.md)', ''];
  if (ledger.changes.length) {
    lines.push('| Action | Knob | Before | After | Baseline | Measured miss | Confirmed before → after (pairs) | Improvement (CI95) | A/A floor (pairs) | Verdict | Apply SHA | Revert SHA |',
      '|---|---|---:|---:|---:|---|---:|---:|---:|---|---|---|');
    for (const c of ledger.changes) {
      const action = c.revert_commit ? 'Reverted' : !c.commit ? 'Skipped' : c.verdict === 'kept' ? 'Kept' : 'Awaiting revert';
      const measured = fmt(c.measured_before) + ' → ' + fmt(c.measured_after) + ' (' + c.pairs + ')';
      const cells = [action, c.id, c.before, c.after, c.baseline, c.miss, measured, fmt(c.improvement) + ' (' + c.ci95.map(fmt).join(' to ') + ')',
        fmt(c.floor) + ' (' + c.aa_pairs + ')', c.verdict, c.commit ?? '—', c.revert_commit ?? '—'];
      lines.push('| ' + cells.map((s) => String(s).replaceAll('|', '\\|').replace(/[\r\n]+/g, ' ')).join(' | ') + ' |');
    }
  } else lines.push('The plan contained no changes.');
  return lines.join('\n') + '\n';
}

function runNode(argv, cwd) {
  const result = spawnSync(process.execPath, argv, { cwd, stdio: 'inherit', windowsHide: true });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(nodeCommand(argv) + ' stopped (' + (result.signal ?? 'exit ' + result.status) + ')');
}

export function night(argv, { root = ROOT, run = runNode, log = console.log,
  branch = () => git(root, 'branch', '--show-current').trim() } = {}) {
  const job = recipe(argv, root);
  if (job.dryRun) {
    for (const [i, args] of job.steps.entries()) {
      if (i === 3) log('Only n22-tune* branches continue after propose.');
      log(nodeCommand(args));
    }
    log('Writes ' + job.out + '/night.md on completion.');
    return;
  }
  return withLock(root, () => {
    mkdirSync(job.dir, { recursive: true });
    if (readdirSync(job.dir).length) throw new Error('night output must be empty: ' + job.dir);
    const current = branch();
    for (const [i, args] of job.steps.entries()) {
      if (i === 3 && !isTuneBranch(current)) {
        log('Stopped after propose on ' + (current || 'detached HEAD') + '. Apply requires n22-tune*.');
        return;
      }
      if (branch() !== current) throw new Error('branch changed during the night');
      log(nodeCommand(args));
      try { run(args, root); }
      catch (err) {
        if (i >= 3) log('Check apply commits on ' + current + '. Evidence is in ' + job.out
          + '. Use --dry-run with the same options to see the remaining commands.');
        throw err;
      }
    }
    const ledger = readJson(join(job.dir, 'after/tune-ledger.json'));
    atomicWrite(join(job.dir, 'night.md'), summary(job, current, ledger));
    log('Wrote ' + job.out + '/night.md');
  }, 'night');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { night(process.argv.slice(2)); }
  catch (err) { console.error('night: ' + err.message); process.exitCode = 1; }
}
