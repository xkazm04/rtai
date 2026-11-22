#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { mkdirSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { ROOT, readJson } from '../lib/repo.mjs';
import { nodeCommand } from './commands.mjs';
import { checkAfterPlan, checkInputs, checkMeasuredTables } from './night_batches.mjs';
import { parseNight, recipe, tool } from './night_args.mjs';
import { physical } from './night_paths.mjs';
import { summary } from './night_summary.mjs';
import { inWorktree, requireClean } from './night_worktree.mjs';
import { atomicWrite, digest, git, withLock } from './tune_state.mjs';

function runNode(argv, cwd) {
  const result = spawnSync(process.execPath, argv, { cwd, stdio: 'inherit', windowsHide: true });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(nodeCommand(argv) + ' stopped (' + (result.signal ?? 'exit ' + result.status) + ')');
}

function execute(job, tree, run, log) {
  checkInputs(tree, job);
  const applied = job.resume && checkAfterPlan(tree, job);
  const steps = recipe(job).filter((args) => !(applied && args[1] === 'apply'));
  log('Worktree ' + tree + ' on ' + job.branch + '. Output ' + job.dir);
  if (job.dryRun) {
    for (const cmd of steps) log(nodeCommand(cmd));
    log('Writes ' + join(job.dir, 'night.md') + ' on completion.');
    return;
  }
  mkdirSync(job.dir, { recursive: true });
  if (!job.resume && readdirSync(job.dir).length) throw new Error('night output must be empty: ' + job.dir);
  for (const args of steps) {
    if (git(tree, 'branch', '--show-current').trim() !== job.branch) throw new Error('branch changed during the night');
    if (args[1] === 'apply' && job.inputs.after && !job.resume) checkAfterPlan(tree, job);
    log(nodeCommand(args));
    if (args[0] === tool('batch') || args[0] === tool('ablate')) {
      withLock(tree, () => {
        requireClean(tree);
        const head = git(tree, 'rev-parse', 'HEAD');
        run(args, tree);
        if (job.rev) checkMeasuredTables(tree, job, args[1].slice('--name='.length));
        requireClean(tree);
        if (head !== git(tree, 'rev-parse', 'HEAD')) throw new Error('HEAD changed during batch');
      });
    } else run(args, tree);
  }
  const ledger = readJson(join(job.dir, 'after/tune-ledger.json'));
  atomicWrite(join(job.dir, 'night.md'), summary(job, job.branch, ledger));
  log('Wrote ' + join(job.dir, 'night.md'));
}

export function night(argv, { root = ROOT, run = runNode, log = console.log } = {}) {
  const job = parseNight(argv, root);
  if (job.remove) {
    inWorktree(root, job);
    log('Removed ' + job.path + ' and ' + job.branch);
    return;
  }
  // Different tune branches can run concurrently, but cannot write the same cycle directory.
  const dir = physical(job.dir);
  const outputKey = process.platform === 'win32' ? dir.toLowerCase() : dir;
  withLock(root, () => inWorktree(root, job, (tree) => execute(job, tree, run, log)),
    'night-output-' + digest(outputKey).slice(0, 16));
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try { night(process.argv.slice(2)); }
  catch (err) { console.error('night: ' + err.message); process.exitCode = 1; }
}
